USE Festival_Final_OLAP;
GO

BEGIN TRY
    BEGIN TRANSACTION;
    -- 3. AHORA CARGAMOS LAS DIMENSIONES
    
    -- DIM_Tiempo: Generación de fechas para el periodo del festival y fechas relacionadas
    PRINT 'Cargando DIM_Tiempo...';
    
    -- Declaro variables para definir el rango de fechas
    DECLARE @FechaInicio DATE = '2022-08-01'; -- 2 meses antes del primer festival
    DECLARE @FechaFin DATE = '2024-12-31';    -- Hasta fin del año del último festival
    
    -- Tabla temporal para generar fechas
    DECLARE @Fechas TABLE (FechaCalendario DATE);
    
    -- Generar secuencia de fechas
    WHILE @FechaInicio <= @FechaFin
    BEGIN
        INSERT INTO @Fechas (FechaCalendario) VALUES (@FechaInicio);
        SET @FechaInicio = DATEADD(DAY, 1, @FechaInicio);
    END
    
    -- Insertar en DIM_Tiempo con todos los atributos calculados
    INSERT INTO DIM_Tiempo (
        fecha, dia, dia_semana, semana, mes, nombre_mes, 
        trimestre, anio, es_fin_semana, es_festivo, temporada_festival
    )
    SELECT 
        F.FechaCalendario,
        DAY(F.FechaCalendario),
        DATENAME(WEEKDAY, F.FechaCalendario),
        DATEPART(WEEK, F.FechaCalendario),
        MONTH(F.FechaCalendario),
        DATENAME(MONTH, F.FechaCalendario),
        DATEPART(QUARTER, F.FechaCalendario),
        YEAR(F.FechaCalendario),
        CASE WHEN DATENAME(WEEKDAY, F.FechaCalendario) IN ('Saturday', 'Sunday') THEN 1 ELSE 0 END,
        0, -- Por defecto no es festivo, esto requeriría una tabla de festivos específica
        CASE 
            WHEN EXISTS (
                SELECT 1 FROM Festival_Final_OLTP.dbo.Edicion_Festival 
                WHERE F.FechaCalendario BETWEEN fecha_inicio AND fecha_fin
            ) THEN 'festival'
            WHEN EXISTS (
                SELECT 1 FROM Festival_Final_OLTP.dbo.Edicion_Festival 
                WHERE F.FechaCalendario BETWEEN DATEADD(MONTH, -2, fecha_inicio) AND DATEADD(DAY, -1, fecha_inicio)
            ) THEN 'pre-festival'
            WHEN EXISTS (
                SELECT 1 FROM Festival_Final_OLTP.dbo.Edicion_Festival 
                WHERE F.FechaCalendario BETWEEN DATEADD(DAY, 1, fecha_fin) AND DATEADD(MONTH, 1, fecha_fin)
            ) THEN 'post-festival'
            ELSE NULL
        END
    FROM @Fechas F
    ORDER BY F.FechaCalendario;
    
    -- DIM_Edicion
    PRINT 'Cargando DIM_Edicion...';
    
    INSERT INTO DIM_Edicion (
        edicion_id, anio, tema, director_festival, fecha_inicio, fecha_fin, duracion_dias
    )
    SELECT 
        ef.edicion_id,
        ef.anio,
        ef.tema,
        ef.director_festival,
        ef.fecha_inicio,
        ef.fecha_fin,
        DATEDIFF(DAY, ef.fecha_inicio, ef.fecha_fin) + 1
    FROM Festival_Final_OLTP.dbo.Edicion_Festival ef;
    
    -- DIM_CategoriaGasto
    PRINT 'Cargando DIM_CategoriaGasto...';
    
    INSERT INTO DIM_CategoriaGasto (
        nombre_categoria, tipo_gasto, es_amortizable, frecuencia
    )
    SELECT DISTINCT
        categoria_gasto,
        CASE 
            WHEN categoria_gasto IN ('Infraestructura', 'Personal', 'Alojamiento') THEN 'operativo'
            WHEN categoria_gasto IN ('Marketing', 'Premios') THEN 'promocional'
            WHEN categoria_gasto IN ('Logística', 'Transporte') THEN 'logístico'
            WHEN categoria_gasto IN ('Catering') THEN 'servicio'
            ELSE 'otro'
        END,
        CASE WHEN categoria_gasto = 'Infraestructura' THEN 1 ELSE 0 END,
        CASE 
            WHEN categoria_gasto IN ('Personal', 'Infraestructura') THEN 'recurrente'
            WHEN categoria_gasto IN ('Premios', 'Catering') THEN 'anual'
            ELSE 'variable'
        END
    FROM Festival_Final_OLTP.dbo.Gasto_Festival;
    
    -- DIM_Geografia
    PRINT 'Cargando DIM_Geografia...';
    
    -- Primero ingresamos ubicaciones de las salas
    INSERT INTO DIM_Geografia (pais, ciudad, continente, region)
    SELECT DISTINCT
        'España', -- Por defecto las salas están en España
        SUBSTRING(s.ubicacion, 1, CHARINDEX(',', s.ubicacion + ',') - 1),
        'Europa',
        'Sur de Europa'
    FROM Festival_Final_OLTP.dbo.Sala s;
    
    -- Luego países de patrocinadores
    INSERT INTO DIM_Geografia (pais, ciudad, continente, region)
    SELECT DISTINCT
        p.pais,
        NULL, -- No tenemos ciudades específicas para patrocinadores
        CASE 
            WHEN p.pais IN ('España', 'Italia', 'Francia', 'Portugal', 'Alemania', 'Reino Unido') THEN 'Europa'
            WHEN p.pais IN ('Estados Unidos', 'Canadá', 'México') THEN 'América'
            WHEN p.pais IN ('Japón', 'China', 'Corea del Sur') THEN 'Asia'
            ELSE 'Otros'
        END,
        CASE 
            WHEN p.pais IN ('España', 'Italia', 'Portugal') THEN 'Sur de Europa'
            WHEN p.pais IN ('Francia', 'Alemania', 'Reino Unido') THEN 'Europa Occidental'
            WHEN p.pais IN ('Estados Unidos', 'Canadá') THEN 'América del Norte'
            WHEN p.pais = 'México' THEN 'América Central'
            ELSE 'Otras regiones'
        END
    FROM Festival_Final_OLTP.dbo.Patrocinador p
    WHERE p.pais NOT IN (SELECT DISTINCT pais FROM DIM_Geografia);
    
    -- Luego países de asistentes
    INSERT INTO DIM_Geografia (pais, ciudad, continente, region)
    SELECT DISTINCT
        a.pais,
        a.ciudad,
        CASE 
            WHEN a.pais IN ('España', 'Italia', 'Francia', 'Portugal', 'Alemania', 'Reino Unido') THEN 'Europa'
            WHEN a.pais IN ('Estados Unidos', 'Canadá', 'México', 'Argentina', 'Chile', 'Colombia') THEN 'América'
            WHEN a.pais IN ('Japón', 'China', 'Corea del Sur') THEN 'Asia'
            ELSE 'Otros'
        END,
        CASE 
            WHEN a.pais IN ('España', 'Italia', 'Portugal') THEN 'Sur de Europa'
            WHEN a.pais IN ('Francia', 'Alemania', 'Reino Unido') THEN 'Europa Occidental'
            WHEN a.pais IN ('Estados Unidos', 'Canadá') THEN 'América del Norte'
            WHEN a.pais IN ('México', 'Colombia') THEN 'América Central'
            WHEN a.pais IN ('Argentina', 'Chile') THEN 'América del Sur'
            ELSE 'Otras regiones'
        END
    FROM Festival_Final_OLTP.dbo.Asistente a
    WHERE NOT EXISTS (
        SELECT 1 FROM DIM_Geografia g 
        WHERE g.pais = a.pais AND 
              (g.ciudad = a.ciudad OR (g.ciudad IS NULL AND a.ciudad IS NULL))
    );
    
    -- Países de personas/invitados (origen y destino de traslados)
    INSERT INTO DIM_Geografia (pais, ciudad, continente, region)
    SELECT DISTINCT
        p.nacionalidad,
        NULL, -- No tenemos ciudades específicas para personas
        CASE 
            WHEN p.nacionalidad IN ('Española', 'Italiana', 'Francesa', 'Portuguesa', 'Alemana', 'Británica') THEN 'Europa'
            WHEN p.nacionalidad IN ('Estadounidense', 'Canadiense', 'Mexicana') THEN 'América'
            WHEN p.nacionalidad IN ('Japonesa', 'China', 'Surcoreana') THEN 'Asia'
            ELSE 'Otros'
        END,
        CASE 
            WHEN p.nacionalidad IN ('Española', 'Italiana', 'Portuguesa') THEN 'Sur de Europa'
            WHEN p.nacionalidad IN ('Francesa', 'Alemana', 'Británica') THEN 'Europa Occidental'
            WHEN p.nacionalidad IN ('Estadounidense', 'Canadiense') THEN 'América del Norte'
            WHEN p.nacionalidad = 'Mexicana' THEN 'América Central'
            ELSE 'Otras regiones'
        END
    FROM Festival_Final_OLTP.dbo.Persona p
    WHERE p.nacionalidad NOT IN (SELECT DISTINCT pais FROM DIM_Geografia);
    
    -- Destinos de traslados
    INSERT INTO DIM_Geografia (pais, ciudad, continente, region)
    SELECT DISTINCT
        'España', -- Asumimos que todos los traslados son dentro de España
        t.origen,
        'Europa',
        'Sur de Europa'
    FROM Festival_Final_OLTP.dbo.Traslado t
    WHERE t.origen NOT IN (SELECT DISTINCT ciudad FROM DIM_Geografia WHERE pais = 'España')
    UNION
    SELECT DISTINCT
        'España',
        t.destino,
        'Europa',
        'Sur de Europa'
    FROM Festival_Final_OLTP.dbo.Traslado t
    WHERE t.destino NOT IN (SELECT DISTINCT ciudad FROM DIM_Geografia WHERE pais = 'España');
    
    -- DIM_MetodoPago
    PRINT 'Cargando DIM_MetodoPago...';
    
    INSERT INTO DIM_MetodoPago (
        nombre_metodo, tipo_metodo, requiere_procesamiento, comision_porcentaje
    )
    VALUES 
        ('Efectivo', 'efectivo', 0, 0),
        ('Tarjeta de crédito', 'tarjeta', 1, 2.5),
        ('Tarjeta de débito', 'tarjeta', 1, 1.5),
        ('PayPal', 'electrónico', 1, 3.0),
        ('Transferencia bancaria', 'transferencia', 1, 0.5);
    
    -- DIM_Pelicula
    PRINT 'Cargando DIM_Pelicula...';
    
    INSERT INTO DIM_Pelicula (
        pelicula_id, titulo, anio_produccion, duracion, pais_origen, 
        clasificacion_edad, formato_proyeccion, nombre_director_principal,
        estado_seleccion, generos, idioma_original, 
        tiene_subtitulos_espanol, tiene_subtitulos_ingles
    )
    SELECT 
        p.pelicula_id, 
        p.titulo, 
        p.anio, 
        p.duracion, 
        p.pais_origen, 
        p.clasificacion_edad, 
        p.formato_proyeccion,
        (SELECT TOP 1 per.nombre + ' ' + per.apellidos 
         FROM Festival_Final_OLTP.dbo.Pelicula_Persona_Rol ppr 
         JOIN Festival_Final_OLTP.dbo.Persona per ON ppr.persona_id = per.persona_id 
         JOIN Festival_Final_OLTP.dbo.Rol_Cinematografico rc ON ppr.rol_id = rc.rol_id 
         WHERE ppr.pelicula_id = p.pelicula_id AND rc.nombre = 'Director' 
         ORDER BY per.nombre),
        p.estado_seleccion,
        STUFF((SELECT ', ' + gc.nombre 
               FROM Festival_Final_OLTP.dbo.Pelicula_Genero pg 
               JOIN Festival_Final_OLTP.dbo.Genero_Cinematografico gc ON pg.genero_id = gc.genero_id 
               WHERE pg.pelicula_id = p.pelicula_id 
               FOR XML PATH('')), 1, 2, ''),
        (SELECT TOP 1 i.nombre 
         FROM Festival_Final_OLTP.dbo.Pelicula_Idioma pi 
         JOIN Festival_Final_OLTP.dbo.Idioma i ON pi.idioma_id = i.idioma_id 
         WHERE pi.pelicula_id = p.pelicula_id AND pi.tipo = 'original'),
        CASE WHEN EXISTS (
            SELECT 1 FROM Festival_Final_OLTP.dbo.Pelicula_Idioma pi 
            JOIN Festival_Final_OLTP.dbo.Idioma i ON pi.idioma_id = i.idioma_id 
            WHERE pi.pelicula_id = p.pelicula_id AND pi.tipo = 'subtitulos' AND i.codigo_iso = 'ES'
        ) THEN 1 ELSE 0 END,
        CASE WHEN EXISTS (
            SELECT 1 FROM Festival_Final_OLTP.dbo.Pelicula_Idioma pi 
            JOIN Festival_Final_OLTP.dbo.Idioma i ON pi.idioma_id = i.idioma_id 
            WHERE pi.pelicula_id = p.pelicula_id AND pi.tipo = 'subtitulos' AND i.codigo_iso = 'EN'
        ) THEN 1 ELSE 0 END
    FROM Festival_Final_OLTP.dbo.Pelicula p;
    
    -- DIM_Categoria
    PRINT 'Cargando DIM_Categoria...';
    
    INSERT INTO DIM_Categoria (
        categoria_id, nombre_categoria, descripcion, tipo_categoria, edicion_anio
    )
    SELECT 
        cc.categoria_id,
        cc.nombre,
        cc.descripcion,
        'Competición oficial', -- Todas son de competición oficial en este modelo
        ef.anio
    FROM Festival_Final_OLTP.dbo.Categoria_Competicion cc
    JOIN Festival_Final_OLTP.dbo.Edicion_Festival ef ON cc.edicion_festival = ef.edicion_id;
    
    -- DIM_Sala
    PRINT 'Cargando DIM_Sala...';
    
    INSERT INTO DIM_Sala (
        sala_id, nombre_sala, ubicacion, capacidad, tipo_sala, caracteristicas_tecnicas
    )
    SELECT 
        s.sala_id,
        s.nombre,
        s.ubicacion,
        s.capacidad,
        CASE 
            WHEN s.nombre LIKE '%Principal%' THEN 'principal'
            WHEN s.nombre LIKE '%VIP%' THEN 'vip'
            WHEN s.nombre LIKE '%Exterior%' THEN 'exterior'
            ELSE 'secundaria'
        END,
        s.caracteristicas_tecnicas
    FROM Festival_Final_OLTP.dbo.Sala s;
    
    -- DIM_Persona
    PRINT 'Cargando DIM_Persona...';
    
    INSERT INTO DIM_Persona (
        persona_id, nombre_completo, email, nacionalidad, roles_principales, biografia
    )
    SELECT 
        p.persona_id,
        p.nombre + ' ' + p.apellidos,
        p.email,
        p.nacionalidad,
        STUFF((SELECT ', ' + rc.nombre 
               FROM Festival_Final_OLTP.dbo.Pelicula_Persona_Rol ppr 
               JOIN Festival_Final_OLTP.dbo.Rol_Cinematografico rc ON ppr.rol_id = rc.rol_id 
               WHERE ppr.persona_id = p.persona_id 
               GROUP BY rc.nombre
               FOR XML PATH('')), 1, 2, ''),
        p.biografia
    FROM Festival_Final_OLTP.dbo.Persona p;
    
    -- DIM_Asistente
    PRINT 'Cargando DIM_Asistente...';
    
    INSERT INTO DIM_Asistente (
        asistente_id, nombre_completo, email, telefono, tipo_asistente, 
        pais, ciudad, tiene_acreditacion, tipo_acreditacion
    )
    SELECT 
        a.asistente_id,
        a.nombre + ' ' + a.apellidos,
        a.email,
        a.telefono,
        a.tipo_asistente,
        a.pais,
        a.ciudad,
        CASE WHEN ac.acreditacion_id IS NOT NULL THEN 1 ELSE 0 END,
        ac.tipo_acreditacion
    FROM Festival_Final_OLTP.dbo.Asistente a
    LEFT JOIN Festival_Final_OLTP.dbo.Acreditacion ac ON a.asistente_id = ac.asistente_id;
    
    -- DIM_Entrada
    PRINT 'Cargando DIM_Entrada...';
    
    INSERT INTO DIM_Entrada (
        tipo_entrada_id, nombre, descripcion, precio_base, es_abono, metodo_pago
    )
    SELECT 
        te.tipo_entrada_id,
        te.nombre,
        te.descripcion,
        te.precio_base,
        0, -- No es abono
        NULL -- El método de pago se reflejará en cada venta
    FROM Festival_Final_OLTP.dbo.Tipo_Entrada te
    UNION
    SELECT 
        1000 + ROW_NUMBER() OVER (ORDER BY tipo_abono), -- Asignamos IDs a partir de 1000 para los abonos
        tipo_abono,
        'Abono: ' + tipo_abono,
        precio,
        1, -- Es abono
        NULL
    FROM Festival_Final_OLTP.dbo.Abono
    GROUP BY tipo_abono, precio; -- Agrupamos para evitar duplicados
    
    -- DIM_Evento
    PRINT 'Cargando DIM_Evento...';
    
    -- Usamos CTEs para mejor manejo de los tipos de datos
    WITH EventosParalelos AS (
        SELECT 
            ep.evento_id,
            CAST(ep.nombre AS NVARCHAR(200)) AS nombre_evento,
            CAST(ep.tipo AS NVARCHAR(100)) AS tipo_evento,
            CAST(ep.descripcion AS NVARCHAR(MAX)) AS descripcion,
            CAST(ep.ubicacion AS NVARCHAR(200)) AS ubicacion,
            ep.aforo_maximo,
            ep.requiere_inscripcion
        FROM Festival_Final_OLTP.dbo.Evento_Paralelo ep
    ),
    Proyecciones AS (
        SELECT 
            10000 + pr.proyeccion_id AS evento_id,
            CAST(p.titulo + ' (Proyección)' AS NVARCHAR(200)) AS nombre_evento,
            CAST('Proyección' AS NVARCHAR(100)) AS tipo_evento,
            CAST(p.sinopsis AS NVARCHAR(MAX)) AS descripcion,
            CAST(s.nombre + ', ' + s.ubicacion AS NVARCHAR(200)) AS ubicacion,
            s.capacidad AS aforo_maximo,
            0 AS requiere_inscripcion
        FROM Festival_Final_OLTP.dbo.Proyeccion pr
        JOIN Festival_Final_OLTP.dbo.Pelicula p ON pr.pelicula_id = p.pelicula_id
        JOIN Festival_Final_OLTP.dbo.Sala s ON pr.sala_id = s.sala_id
    )
    INSERT INTO DIM_Evento (
        evento_id, nombre_evento, tipo_evento, descripcion, ubicacion, 
        aforo_maximo, requiere_inscripcion
    )
    SELECT * FROM EventosParalelos
    UNION ALL
    SELECT * FROM Proyecciones;
            
    -- DIM_Jurado
    PRINT 'Cargando DIM_Jurado...';
    
    INSERT INTO DIM_Jurado (
        jurado_id, nombre_jurado, edicion_anio, categorias_evaluacion, miembros
    )
    SELECT 
        j.jurado_id,
        j.nombre,
        ef.anio,
        STUFF((SELECT ', ' + cc.nombre 
               FROM Festival_Final_OLTP.dbo.Jurado_Categoria jc 
               JOIN Festival_Final_OLTP.dbo.Categoria_Competicion cc ON jc.categoria_id = cc.categoria_id 
               WHERE jc.jurado_id = j.jurado_id 
               FOR XML PATH('')), 1, 2, ''),
        STUFF((SELECT ', ' + p.nombre + ' ' + p.apellidos + ' (' + mj.cargo + ')' 
               FROM Festival_Final_OLTP.dbo.Miembro_Jurado mj 
               JOIN Festival_Final_OLTP.dbo.Persona p ON mj.persona_id = p.persona_id 
               WHERE mj.jurado_id = j.jurado_id 
               FOR XML PATH('')), 1, 2, '')
    FROM Festival_Final_OLTP.dbo.Jurado j
    JOIN Festival_Final_OLTP.dbo.Edicion_Festival ef ON j.edicion_festival = ef.edicion_id;
    
    -- DIM_Patrocinador
    PRINT 'Cargando DIM_Patrocinador...';
    
    INSERT INTO DIM_Patrocinador (
        patrocinador_id, nombre, contacto_principal, tipo, pais, 
        sector_industria, es_recurrente, categorias_patrocinio
    )
    SELECT 
        p.patrocinador_id,
        p.nombre,
        p.contacto_principal,
        p.tipo,
        p.pais,
        p.sector_industria,
        CASE WHEN COUNT(DISTINCT pa.edicion_festival) > 1 THEN 1 ELSE 0 END,
        STUFF((SELECT ', ' + pa.tipo_aportacion 
               FROM Festival_Final_OLTP.dbo.Patrocinio pa 
               WHERE pa.patrocinador_id = p.patrocinador_id 
               GROUP BY pa.tipo_aportacion
               FOR XML PATH('')), 1, 2, '')
    FROM Festival_Final_OLTP.dbo.Patrocinador p
    LEFT JOIN Festival_Final_OLTP.dbo.Patrocinio pa ON p.patrocinador_id = pa.patrocinador_id
    GROUP BY p.patrocinador_id, p.nombre, p.contacto_principal, p.tipo, p.pais, p.sector_industria;
    
    -- 4. AHORA CARGAMOS LAS TABLAS DE HECHOS
    
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
        (SELECT edicion_id FROM Festival_Final_OLTP.dbo.Edicion_Festival ef 
         WHERE pr.fecha BETWEEN ef.fecha_inicio AND ef.fecha_fin),
        DATEDIFF(MINUTE, pr.hora_inicio, pr.hora_fin),
        pr.sesion_qa,
        s.capacidad,
        COUNT(e.entrada_id),
        CASE WHEN s.capacidad > 0 THEN 
            CAST(COUNT(e.entrada_id) * 100.0 / s.capacidad AS DECIMAL(5,2)) 
        ELSE 0 END,
        SUM(e.precio_final)
    FROM Festival_Final_OLTP.dbo.Proyeccion pr
    JOIN Festival_Final_OLTP.dbo.Sala s ON pr.sala_id = s.sala_id
    JOIN DIM_Tiempo dt ON pr.fecha = dt.fecha
    LEFT JOIN Festival_Final_OLTP.dbo.Entrada e ON pr.proyeccion_id = e.proyeccion_id
    GROUP BY pr.proyeccion_id, dt.tiempo_id, pr.pelicula_id, pr.sala_id, pr.fecha, pr.hora_inicio, pr.hora_fin, pr.sesion_qa, s.capacidad;
    
    -- FACT_Ventas_Entradas
    PRINT 'Cargando FACT_Ventas_Entradas...';
    
    -- Primero obtenemos el mapping de metodo_pago a metodo_pago_id
    CREATE TABLE #MetodoPagoMapping (
        nombre_metodo VARCHAR(50),
        metodo_pago_id INT
    );
    
    INSERT INTO #MetodoPagoMapping
    SELECT nombre_metodo, metodo_pago_id FROM DIM_MetodoPago;
    
    -- Luego obtenemos el mapping de geografía para asistentes
    CREATE TABLE #GeografiaMapping (
        asistente_id INT,
        geografia_id INT
    );
    
    INSERT INTO #GeografiaMapping
    SELECT 
        a.asistente_id,
        g.geografia_id
    FROM Festival_Final_OLTP.dbo.Asistente a
    JOIN DIM_Geografia g ON a.pais = g.pais AND a.ciudad = g.ciudad;
    
    -- Ahora insertamos en FACT_Ventas_Entradas
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
        (SELECT edicion_id FROM Festival_Final_OLTP.dbo.Edicion_Festival ef 
         WHERE CAST(e.fecha_venta AS DATE) BETWEEN ef.fecha_inicio AND ef.fecha_fin),
        mpm.metodo_pago_id,
        e.precio_final,
        e.abono_id,
        e.usado,
        DATEDIFF(DAY, e.fecha_venta, pr.fecha),
        gm.geografia_id
    FROM Festival_Final_OLTP.dbo.Entrada e
    JOIN Festival_Final_OLTP.dbo.Proyeccion pr ON e.proyeccion_id = pr.proyeccion_id
    JOIN DIM_Tiempo dt ON CAST(e.fecha_venta AS DATE) = dt.fecha
    LEFT JOIN #MetodoPagoMapping mpm ON e.metodo_pago = mpm.nombre_metodo
    LEFT JOIN #GeografiaMapping gm ON e.asistente_id = gm.asistente_id;
    
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
        (SELECT TOP 1 jc.categoria_id FROM Festival_Final_OLTP.dbo.Jurado_Categoria jc 
         WHERE jc.jurado_id = e.jurado_id),
        j.edicion_festival,
        dt.tiempo_id,
        e.puntuacion,
        ROW_NUMBER() OVER (PARTITION BY e.jurado_id ORDER BY e.puntuacion DESC),
        e.comentarios
    FROM Festival_Final_OLTP.dbo.Evaluacion e
    JOIN Festival_Final_OLTP.dbo.Jurado j ON e.jurado_id = j.jurado_id
    JOIN DIM_Tiempo dt ON CAST(e.fecha_evaluacion AS DATE) = dt.fecha;
    
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
        (SELECT TOP 1 jc.jurado_id FROM Festival_Final_OLTP.dbo.Jurado_Categoria jc 
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
    JOIN Festival_Final_OLTP.dbo.Premio p ON po.premio_id = p.premio_id
    JOIN DIM_Tiempo dt ON po.fecha_otorgamiento = dt.fecha;
    
    -- FACT_Eventos_Paralelos
    PRINT 'Cargando FACT_Eventos_Paralelos...';
    
    -- Primero insertamos los eventos con inscripciones de asistentes
    INSERT INTO FACT_Eventos_Paralelos (
        evento_id, tiempo_id, persona_id, asistente_id, edicion_id,
        aforo_maximo, inscripciones_realizadas, asistencia_real, valoracion_promedio
    )
    SELECT 
        ie.evento_id,
        dt.tiempo_id,
        NULL, -- No hay persona/presentador específico en esta tabla
        ie.asistente_id,
        (SELECT edicion_id FROM Festival_Final_OLTP.dbo.Edicion_Festival ef 
         WHERE ep.fecha BETWEEN ef.fecha_inicio AND ef.fecha_fin),
        ep.aforo_maximo,
        COUNT(*) OVER (PARTITION BY ie.evento_id),
        SUM(CASE WHEN ie.asistio = 1 THEN 1 ELSE 0 END) OVER (PARTITION BY ie.evento_id),
        NULL -- No tenemos valoraciones en el OLTP
    FROM Festival_Final_OLTP.dbo.Inscripcion_Evento ie
    JOIN Festival_Final_OLTP.dbo.Evento_Paralelo ep ON ie.evento_id = ep.evento_id
    JOIN DIM_Tiempo dt ON ep.fecha = dt.fecha;
    
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
        (SELECT TOP 1 dt.tiempo_id FROM DIM_Tiempo dt 
         JOIN Festival_Final_OLTP.dbo.Edicion_Festival ef ON ef.edicion_id = pa.edicion_festival 
         WHERE dt.fecha = ef.fecha_inicio),
        CASE WHEN pa.tipo_aportacion = 'Económica' THEN pa.valor_monetario ELSE 0 END,
        CASE WHEN pa.tipo_aportacion != 'Económica' THEN pa.valor_monetario ELSE 0 END,
        pa.tipo_aportacion,
        pa.valor_monetario * 1.5, -- Estimación simple del retorno: 1.5 veces el valor
        pa.tipo_aportacion,
        (SELECT TOP 1 g.geografia_id FROM DIM_Geografia g 
         JOIN Festival_Final_OLTP.dbo.Patrocinador p ON p.patrocinador_id = pa.patrocinador_id 
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
        (SELECT edicion_id FROM Festival_Final_OLTP.dbo.Edicion_Festival ef 
         WHERE ra.fecha_entrada BETWEEN ef.fecha_inicio AND ef.fecha_fin),
        dt_entrada.tiempo_id,
        dt_salida.tiempo_id,
        a.nombre_establecimiento,
        a.categoria,
        DATEDIFF(DAY, ra.fecha_entrada, ra.fecha_salida),
        ra.precio,
        ra.precio / NULLIF(DATEDIFF(DAY, ra.fecha_entrada, ra.fecha_salida), 0),
        (SELECT TOP 1 g.geografia_id FROM DIM_Geografia g 
         WHERE g.ciudad = SUBSTRING(a.direccion, 1, CHARINDEX(',', a.direccion + ',') - 1) AND g.pais = 'España')
    FROM Festival_Final_OLTP.dbo.Reserva_Alojamiento ra
    JOIN Festival_Final_OLTP.dbo.Alojamiento a ON ra.alojamiento_id = a.alojamiento_id
    JOIN DIM_Tiempo dt_entrada ON ra.fecha_entrada = dt_entrada.fecha
    JOIN DIM_Tiempo dt_salida ON ra.fecha_salida = dt_salida.fecha;
    
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
        (SELECT edicion_id FROM Festival_Final_OLTP.dbo.Edicion_Festival ef 
         WHERE t.fecha BETWEEN ef.fecha_inicio AND ef.fecha_fin),
        dt.tiempo_id,
        (SELECT TOP 1 g.geografia_id FROM DIM_Geografia g WHERE g.ciudad = t.origen AND g.pais = 'España'),
        (SELECT TOP 1 g.geografia_id FROM DIM_Geografia g WHERE g.ciudad = t.destino AND g.pais = 'España'),
        t.tipo_transporte,
        t.costo,
        CASE 
            WHEN t.tipo_transporte = 'Coche Privado' THEN 45
            WHEN t.tipo_transporte = 'Taxi' THEN 30
            WHEN t.tipo_transporte = 'Shuttle Festival' THEN 60
            ELSE 45
        END, -- Estimación de duración en minutos
        CASE WHEN t.tipo_transporte IN ('Coche Privado', 'Shuttle Festival') THEN 1 ELSE 0 END
    FROM Festival_Final_OLTP.dbo.Traslado t
    JOIN DIM_Tiempo dt ON t.fecha = dt.fecha;
    
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
        (SELECT TOP 1 g.geografia_id FROM DIM_Geografia g WHERE g.pais = 'España' AND g.ciudad IS NULL), -- Asumimos gastos en España
        CASE WHEN EXISTS (
            SELECT 1 FROM Festival_Final_OLTP.dbo.Gasto_Festival gf2 
            WHERE gf2.categoria_gasto = gf.categoria_gasto AND gf2.edicion_festival != gf.edicion_festival
        ) THEN 1 ELSE 0 END,
        1 -- Asumimos que todos los gastos fueron presupuestados
    FROM Festival_Final_OLTP.dbo.Gasto_Festival gf
    JOIN DIM_Tiempo dt ON gf.fecha_gasto = dt.fecha
    JOIN DIM_CategoriaGasto cg ON gf.categoria_gasto = cg.nombre_categoria;
    
    -- Limpieza de tablas temporales
    DROP TABLE #MetodoPagoMapping;
    DROP TABLE #GeografiaMapping;
    
    -- Reactivar restricciones de clave foránea
    PRINT 'Reactivando restricciones de clave foránea...';
    EXEC sp_MSforeachtable "ALTER TABLE ? CHECK CONSTRAINT ALL";
    
    COMMIT TRANSACTION;
    PRINT 'ETL process completed successfully.';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;
    
    PRINT 'Error occurred: ' + ERROR_MESSAGE();
    PRINT 'Line number: ' + CAST(ERROR_LINE() AS VARCHAR(10));
END CATCH;
GO