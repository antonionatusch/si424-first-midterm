USE Festival_Final_OLAP;
GO

-- 1) Si ya existe, lo borramos
IF OBJECT_ID('dbo.usp_LoadFacts','P') IS NOT NULL
    DROP PROCEDURE dbo.usp_LoadFacts;
GO

-- 2) Creamos el procedimiento que carga solo las tablas de hechos
CREATE PROCEDURE dbo.usp_LoadFacts
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        ------------------------------------------------------------------------
        -- 4) AHORA CARGAMOS LAS TABLAS DE HECHOS
        ------------------------------------------------------------------------

        -- FACT_Proyecciones
        PRINT 'Cargando FACT_Proyecciones...';
        INSERT INTO FACT_Proyecciones (
            proyeccion_id, tiempo_id, pelicula_id, sala_id, edicion_id, duracion_proyeccion,
            tiene_qa, aforo_total, entradas_vendidas, porcentaje_ocupacion, ingresos_totales
        )
        SELECT 
            pr.proyeccion_id,
            dt.tiempo_id,
            pr.pelicula_id,
            pr.sala_id,
            (SELECT edicion_id 
             FROM Festival_Final_OLTP.dbo.Edicion_Festival ef 
             WHERE pr.fecha BETWEEN ef.fecha_inicio AND ef.fecha_fin),
            DATEDIFF(MINUTE, pr.hora_inicio, pr.hora_fin),
            pr.sesion_qa,
            s.capacidad,
            COUNT(e.entrada_id),
            CASE WHEN s.capacidad > 0 
                 THEN CAST(COUNT(e.entrada_id) * 100.0 / s.capacidad AS DECIMAL(5,2)) 
                 ELSE 0 END,
            SUM(e.precio_final)
        FROM Festival_Final_OLTP.dbo.Proyeccion pr
        JOIN Festival_Final_OLTP.dbo.Sala s 
          ON pr.sala_id = s.sala_id
        JOIN DIM_Tiempo dt 
          ON pr.fecha = dt.fecha
        LEFT JOIN Festival_Final_OLTP.dbo.Entrada e 
          ON pr.proyeccion_id = e.proyeccion_id
        GROUP BY 
            pr.proyeccion_id, dt.tiempo_id, pr.pelicula_id, pr.sala_id, 
            pr.fecha, pr.hora_inicio, pr.hora_fin, pr.sesion_qa, s.capacidad;

        -- FACT_Ventas_Entradas
        PRINT 'Cargando FACT_Ventas_Entradas...';
        -- mapping de método de pago
        CREATE TABLE #MetodoPagoMapping (
            nombre_metodo VARCHAR(50),
            metodo_pago_id INT
        );
        INSERT INTO #MetodoPagoMapping
            SELECT nombre_metodo, metodo_pago_id FROM DIM_MetodoPago;
        -- mapping de geografía para asistentes
        CREATE TABLE #GeografiaMapping (
            asistente_id INT,
            geografia_id INT
        );
        INSERT INTO #GeografiaMapping
            SELECT a.asistente_id, g.geografia_id
            FROM Festival_Final_OLTP.dbo.Asistente a
            JOIN DIM_Geografia g 
              ON a.pais = g.pais 
             AND a.ciudad = g.ciudad;
        INSERT INTO FACT_Ventas_Entradas (
            tiempo_id, proyeccion_id, asistente_id, tipo_entrada_id, edicion_id,
            metodo_pago_id, precio_final, abono_id, fue_utilizada, tiempo_compra_anticipada,
            geografia_id
        )
        SELECT 
            dt.tiempo_id,
            e.proyeccion_id,
            e.asistente_id,
            e.tipo_entrada_id,
            (SELECT edicion_id 
             FROM Festival_Final_OLTP.dbo.Edicion_Festival ef 
             WHERE CAST(e.fecha_venta AS DATE) BETWEEN ef.fecha_inicio AND ef.fecha_fin),
            mpm.metodo_pago_id,
            e.precio_final,
            e.abono_id,
            e.usado,
            DATEDIFF(DAY, e.fecha_venta, pr.fecha),
            gm.geografia_id
        FROM Festival_Final_OLTP.dbo.Entrada e
        JOIN Festival_Final_OLTP.dbo.Proyeccion pr 
          ON e.proyeccion_id = pr.proyeccion_id
        JOIN DIM_Tiempo dt 
          ON CAST(e.fecha_venta AS DATE) = dt.fecha
        LEFT JOIN #MetodoPagoMapping mpm 
          ON e.metodo_pago = mpm.nombre_metodo
        LEFT JOIN #GeografiaMapping gm 
          ON e.asistente_id = gm.asistente_id;

        -- FACT_Evaluaciones_Jurado
        PRINT 'Cargando FACT_Evaluaciones_Jurado...';
        INSERT INTO FACT_Evaluaciones_Jurado (
            evaluacion_id, pelicula_id, jurado_id, persona_id, categoria_id,
            edicion_id, tiempo_id, puntuacion, posicion_ranking, comentarios
        )
        SELECT 
            e.evaluacion_id,
            e.pelicula_id,
            e.jurado_id,
            e.persona_id,
            (SELECT TOP 1 jc.categoria_id 
             FROM Festival_Final_OLTP.dbo.Jurado_Categoria jc 
             WHERE jc.jurado_id = e.jurado_id),
            j.edicion_festival,
            dt.tiempo_id,
            e.puntuacion,
            ROW_NUMBER() OVER (PARTITION BY e.jurado_id ORDER BY e.puntuacion DESC),
            e.comentarios
        FROM Festival_Final_OLTP.dbo.Evaluacion e
        JOIN Festival_Final_OLTP.dbo.Jurado j 
          ON e.jurado_id = j.jurado_id
        JOIN DIM_Tiempo dt 
          ON CAST(e.fecha_evaluacion AS DATE) = dt.fecha;

        -- FACT_Premios
        PRINT 'Cargando FACT_Premios...';
        INSERT INTO FACT_Premios (
            premio_id, pelicula_id, categoria_id, jurado_id, edicion_id,
            tiempo_id, dotacion_economica, prestigio_premio, nombre_premio
        )
        SELECT 
            po.premio_otorgado_id,
            po.pelicula_id,
            p.categoria_id,
            (SELECT TOP 1 jc.jurado_id 
             FROM Festival_Final_OLTP.dbo.Jurado_Categoria jc 
             WHERE jc.categoria_id = p.categoria_id),
            po.edicion_festival,
            dt.tiempo_id,
            p.dotacion,
            CASE 
                WHEN p.dotacion >= 25000 THEN 'alto'
                WHEN p.dotacion >= 15000 THEN 'medio'
                ELSE 'bajo'
            END,
            p.nombre
        FROM Festival_Final_OLTP.dbo.Premio_Otorgado po
        JOIN Festival_Final_OLTP.dbo.Premio p 
          ON po.premio_id = p.premio_id
        JOIN DIM_Tiempo dt 
          ON po.fecha_otorgamiento = dt.fecha;

        -- FACT_Eventos_Paralelos
        PRINT 'Cargando FACT_Eventos_Paralelos...';
        INSERT INTO FACT_Eventos_Paralelos (
            evento_id, tiempo_id, persona_id, asistente_id, edicion_id,
            aforo_maximo, inscripciones_realizadas, asistencia_real, valoracion_promedio
        )
        SELECT 
            ie.evento_id,
            dt.tiempo_id,
            NULL,
            ie.asistente_id,
            (SELECT edicion_id 
             FROM Festival_Final_OLTP.dbo.Edicion_Festival ef 
             WHERE ep.fecha BETWEEN ef.fecha_inicio AND ef.fecha_fin),
            ep.aforo_maximo,
            COUNT(*) OVER (PARTITION BY ie.evento_id),
            SUM(CASE WHEN ie.asistio = 1 THEN 1 ELSE 0 END) OVER (PARTITION BY ie.evento_id),
            NULL
        FROM Festival_Final_OLTP.dbo.Inscripcion_Evento ie
        JOIN Festival_Final_OLTP.dbo.Evento_Paralelo ep 
          ON ie.evento_id = ep.evento_id
        JOIN DIM_Tiempo dt 
          ON ep.fecha = dt.fecha;

        -- FACT_Patrocinios
        PRINT 'Cargando FACT_Patrocinios...';
        INSERT INTO FACT_Patrocinios (
            patrocinio_id, patrocinador_id, edicion_id, tiempo_id,
            valor_monetario, valor_en_especie, categoria_patrocinio,
            retorno_estimado, tipo_aportacion, geografia_id
        )
        SELECT 
            pa.patrocinio_id,
            pa.patrocinador_id,
            pa.edicion_festival,
            (SELECT TOP 1 dt.tiempo_id 
             FROM DIM_Tiempo dt 
             JOIN Festival_Final_OLTP.dbo.Edicion_Festival ef 
               ON ef.edicion_id = pa.edicion_festival 
             WHERE dt.fecha = ef.fecha_inicio),
            CASE WHEN pa.tipo_aportacion = 'Económica' THEN pa.valor_monetario ELSE 0 END,
            CASE WHEN pa.tipo_aportacion <> 'Económica' THEN pa.valor_monetario ELSE 0 END,
            pa.tipo_aportacion,
            pa.valor_monetario * 1.5,
            pa.tipo_aportacion,
            (SELECT TOP 1 g.geografia_id 
             FROM DIM_Geografia g 
             JOIN Festival_Final_OLTP.dbo.Patrocinador p 
               ON p.patrocinador_id = pa.patrocinador_id 
             WHERE g.pais = p.pais)
        FROM Festival_Final_OLTP.dbo.Patrocinio pa;

        -- FACT_Alojamientos
        PRINT 'Cargando FACT_Alojamientos...';
        INSERT INTO FACT_Alojamientos (
            reserva_id, persona_id, edicion_id, tiempo_entrada_id, tiempo_salida_id,
            tipo_establecimiento, categoria_establecimiento, duracion_estancia,
            precio_total, precio_por_noche, ubicacion_id
        )
        SELECT 
            ra.reserva_id,
            ra.persona_id,
            (SELECT edicion_id 
             FROM Festival_Final_OLTP.dbo.Edicion_Festival ef 
             WHERE ra.fecha_entrada BETWEEN ef.fecha_inicio AND ef.fecha_fin),
            dt_entrada.tiempo_id,
            dt_salida.tiempo_id,
            a.nombre_establecimiento,
            a.categoria,
            DATEDIFF(DAY, ra.fecha_entrada, ra.fecha_salida),
            ra.precio,
            ra.precio / NULLIF(DATEDIFF(DAY, ra.fecha_entrada, ra.fecha_salida),0),
            (SELECT TOP 1 g.geografia_id 
             FROM DIM_Geografia g 
             WHERE g.ciudad = SUBSTRING(a.direccion,1,CHARINDEX(',',a.direccion+',')-1) 
               AND g.pais = 'España')
        FROM Festival_Final_OLTP.dbo.Reserva_Alojamiento ra
        JOIN Festival_Final_OLTP.dbo.Alojamiento a 
          ON ra.alojamiento_id = a.alojamiento_id
        JOIN DIM_Tiempo dt_entrada 
          ON ra.fecha_entrada = dt_entrada.fecha
        JOIN DIM_Tiempo dt_salida 
          ON ra.fecha_salida  = dt_salida.fecha;

        -- FACT_Traslados
        PRINT 'Cargando FACT_Traslados...';
        INSERT INTO FACT_Traslados (
            traslado_id, persona_id, edicion_id, tiempo_id,
            origen_id, destino_id, tipo_transporte, costo,
            duracion_estimada, es_traslado_oficial
        )
        SELECT 
            t.traslado_id,
            t.persona_id,
            (SELECT edicion_id 
             FROM Festival_Final_OLTP.dbo.Edicion_Festival ef 
             WHERE t.fecha BETWEEN ef.fecha_inicio AND ef.fecha_fin),
            dt.tiempo_id,
            (SELECT TOP 1 g.geografia_id 
             FROM DIM_Geografia g 
             WHERE g.ciudad = t.origen AND g.pais = 'España'),
            (SELECT TOP 1 g.geografia_id 
             FROM DIM_Geografia g 
             WHERE g.ciudad = t.destino AND g.pais = 'España'),
            t.tipo_transporte,
            t.costo,
            CASE 
                WHEN t.tipo_transporte = 'Coche Privado' THEN 45
                WHEN t.tipo_transporte = 'Taxi'           THEN 30
                WHEN t.tipo_transporte = 'Shuttle Festival' THEN 60
                ELSE 45
            END,
            CASE WHEN t.tipo_transporte IN ('Coche Privado','Shuttle Festival') THEN 1 ELSE 0 END
        FROM Festival_Final_OLTP.dbo.Traslado t
        JOIN DIM_Tiempo dt 
          ON t.fecha = dt.fecha;

        -- FACT_Gastos_Festival
        PRINT 'Cargando FACT_Gastos_Festival...';
        INSERT INTO FACT_Gastos_Festival (
            gasto_id, edicion_id, tiempo_id, categoria_gasto_id,
            monto, proveedor, tiene_factura, geografia_id,
            es_recurrente, es_presupuestado
        )
        SELECT 
            gf.gasto_id,
            gf.edicion_festival,
            dt.tiempo_id,
            cg.categoria_gasto_id,
            gf.monto,
            gf.proveedor,
            CASE WHEN gf.numero_factura IS NOT NULL THEN 1 ELSE 0 END,
            (SELECT TOP 1 g.geografia_id 
             FROM DIM_Geografia g 
             WHERE g.pais = 'España' AND g.ciudad IS NULL),
            CASE WHEN EXISTS (
                SELECT 1 
                FROM Festival_Final_OLTP.dbo.Gasto_Festival gf2 
                WHERE gf2.categoria_gasto = gf.categoria_gasto 
                  AND gf2.edicion_festival <> gf.edicion_festival
            ) THEN 1 ELSE 0 END,
            1
        FROM Festival_Final_OLTP.dbo.Gasto_Festival gf
        JOIN DIM_Tiempo dt 
          ON gf.fecha_gasto = dt.fecha
        JOIN DIM_CategoriaGasto cg 
          ON gf.categoria_gasto = cg.nombre_categoria;

        -- limpieza de mapeos temporales
        DROP TABLE #MetodoPagoMapping;
        DROP TABLE #GeografiaMapping;

        -- reactivar constraints FK
        EXEC sp_MSforeachtable "ALTER TABLE ? CHECK CONSTRAINT ALL";

        COMMIT TRANSACTION;
        PRINT 'Carga de hechos completada correctamente.';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;  -- relanza el error al SSIS
    END CATCH
END
GO
