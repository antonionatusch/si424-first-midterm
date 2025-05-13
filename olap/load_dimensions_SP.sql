USE Festival_Final_OLAP;
GO

-- 1) Si ya existe, lo borramos
IF OBJECT_ID('dbo.usp_LoadDimensions', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_LoadDimensions;
GO

-- 2) Creamos el procedimiento que carga solo las dimensiones
CREATE PROCEDURE dbo.usp_LoadDimensions
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        ------------------------------------------------------------------------
        -- 1) DIM_Tiempo
        ------------------------------------------------------------------------
        PRINT 'Cargando DIM_Tiempo...';
        DECLARE @FechaInicio DATE = '2022-08-01';
        DECLARE @FechaFin   DATE = '2024-12-31';
        DECLARE @Fechas     TABLE (FechaCalendario DATE);

        WHILE @FechaInicio <= @FechaFin
        BEGIN
            INSERT INTO @Fechas VALUES(@FechaInicio);
            SET @FechaInicio = DATEADD(DAY,1,@FechaInicio);
        END

        INSERT INTO DIM_Tiempo (
            fecha, dia, dia_semana, semana, mes, nombre_mes, 
            trimestre, anio, es_fin_semana, es_festivo, temporada_festival
        )
        SELECT
            F.FechaCalendario,
            DAY(F.FechaCalendario),
            DATENAME(WEEKDAY, F.FechaCalendario),
            DATEPART(WEEK,     F.FechaCalendario),
            MONTH(F.FechaCalendario),
            DATENAME(MONTH,     F.FechaCalendario),
            DATEPART(QUARTER,  F.FechaCalendario),
            YEAR(F.FechaCalendario),
            CASE WHEN DATENAME(WEEKDAY, F.FechaCalendario) IN ('Saturday','Sunday') THEN 1 ELSE 0 END,
            0,
            CASE 
                WHEN EXISTS (
                    SELECT 1 
                      FROM Festival_Final_OLTP.dbo.Edicion_Festival ef
                     WHERE F.FechaCalendario BETWEEN ef.fecha_inicio AND ef.fecha_fin
                ) THEN 'festival'
                WHEN EXISTS (
                    SELECT 1 
                      FROM Festival_Final_OLTP.dbo.Edicion_Festival ef
                     WHERE F.FechaCalendario BETWEEN DATEADD(MONTH,-2,ef.fecha_inicio)
                                                AND DATEADD(DAY, -1,ef.fecha_inicio)
                ) THEN 'pre-festival'
                WHEN EXISTS (
                    SELECT 1 
                      FROM Festival_Final_OLTP.dbo.Edicion_Festival ef
                     WHERE F.FechaCalendario BETWEEN DATEADD(DAY, 1,ef.fecha_fin)
                                                AND DATEADD(MONTH, 1,ef.fecha_fin)
                ) THEN 'post-festival'
                ELSE NULL
            END
        FROM @Fechas F
        ORDER BY F.FechaCalendario;

        ------------------------------------------------------------------------
        -- 2) DIM_Edicion
        ------------------------------------------------------------------------
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
            DATEDIFF(DAY,ef.fecha_inicio,ef.fecha_fin) + 1
        FROM Festival_Final_OLTP.dbo.Edicion_Festival ef;

        ------------------------------------------------------------------------
        -- 3) DIM_CategoriaGasto
        ------------------------------------------------------------------------
        PRINT 'Cargando DIM_CategoriaGasto...';
        INSERT INTO DIM_CategoriaGasto (
            nombre_categoria, tipo_gasto, es_amortizable, frecuencia
        )
        SELECT DISTINCT
            gf.categoria_gasto,
            CASE
                WHEN gf.categoria_gasto IN ('Infraestructura','Personal','Alojamiento') THEN 'operativo'
                WHEN gf.categoria_gasto IN ('Marketing','Premios')                    THEN 'promocional'
                WHEN gf.categoria_gasto IN ('Logística','Transporte')                THEN 'logístico'
                WHEN gf.categoria_gasto = 'Catering'                                 THEN 'servicio'
                ELSE 'otro'
            END,
            CASE WHEN gf.categoria_gasto = 'Infraestructura' THEN 1 ELSE 0 END,
            CASE
                WHEN gf.categoria_gasto IN ('Personal','Infraestructura') THEN 'recurrente'
                WHEN gf.categoria_gasto IN ('Premios','Catering')         THEN 'anual'
                ELSE 'variable'
            END
        FROM Festival_Final_OLTP.dbo.Gasto_Festival gf;

        ------------------------------------------------------------------------
        -- 4) DIM_Geografia
        ------------------------------------------------------------------------
        PRINT 'Cargando DIM_Geografia...';

        -- 4.1) Salas (todas en España)
        INSERT INTO DIM_Geografia(pais, ciudad, continente, region)
        SELECT DISTINCT
            'España',
            LEFT(s.ubicacion,CHARINDEX(',',s.ubicacion+',')-1),
            'Europa',
            'Sur de Europa'
        FROM Festival_Final_OLTP.dbo.Sala s;

        -- 4.2) Patrocinadores
        INSERT INTO DIM_Geografia(pais, ciudad, continente, region)
        SELECT DISTINCT
            p.pais,
            NULL,
            CASE
                WHEN p.pais IN ('España','Italia','Francia','Portugal','Alemania','Reino Unido') THEN 'Europa'
                WHEN p.pais IN ('Estados Unidos','Canadá','México')                            THEN 'América'
                WHEN p.pais IN ('Japón','China','Corea del Sur')                               THEN 'Asia'
                ELSE 'Otros'
            END,
            CASE
                WHEN p.pais IN ('España','Italia','Portugal')       THEN 'Sur de Europa'
                WHEN p.pais IN ('Francia','Alemania','Reino Unido') THEN 'Europa Occidental'
                WHEN p.pais IN ('Estados Unidos','Canadá')          THEN 'América del Norte'
                WHEN p.pais = 'México'                              THEN 'América Central'
                ELSE 'Otras regiones'
            END
        FROM Festival_Final_OLTP.dbo.Patrocinador p
        WHERE p.pais NOT IN (SELECT pais FROM DIM_Geografia);

        -- 4.3) Asistentes
        INSERT INTO DIM_Geografia(pais, ciudad, continente, region)
        SELECT DISTINCT
            a.pais,
            a.ciudad,
            CASE
                WHEN a.pais IN ('España','Italia','Francia','Portugal','Alemania','Reino Unido') THEN 'Europa'
                WHEN a.pais IN ('Estados Unidos','Canadá','México','Argentina','Chile','Colombia') THEN 'América'
                WHEN a.pais IN ('Japón','China','Corea del Sur')                                THEN 'Asia'
                ELSE 'Otros'
            END,
            CASE
                WHEN a.pais IN ('España','Italia','Portugal')       THEN 'Sur de Europa'
                WHEN a.pais IN ('Francia','Alemania','Reino Unido') THEN 'Europa Occidental'
                WHEN a.pais IN ('Estados Unidos','Canadá')          THEN 'América del Norte'
                WHEN a.pais IN ('México','Colombia')                THEN 'América Central'
                WHEN a.pais IN ('Argentina','Chile')                THEN 'América del Sur'
                ELSE 'Otras regiones'
            END
        FROM Festival_Final_OLTP.dbo.Asistente a
        WHERE NOT EXISTS (
            SELECT 1 
              FROM DIM_Geografia g
             WHERE g.pais = a.pais 
               AND (g.ciudad = a.ciudad OR (g.ciudad IS NULL AND a.ciudad IS NULL))
        );

        -- 4.4) Personas (nacionalidades)
        INSERT INTO DIM_Geografia(pais, ciudad, continente, region)
        SELECT DISTINCT
            p.nacionalidad,
            NULL,
            CASE
                WHEN p.nacionalidad IN ('Española','Italiana','Francesa','Portuguesa','Alemana','Británica') THEN 'Europa'
                WHEN p.nacionalidad IN ('Estadounidense','Canadiense','Mexicana')                             THEN 'América'
                WHEN p.nacionalidad IN ('Japonesa','China','Surcoreana')                                     THEN 'Asia'
                ELSE 'Otros'
            END,
            CASE
                WHEN p.nacionalidad IN ('Española','Italiana','Portuguesa') THEN 'Sur de Europa'
                WHEN p.nacionalidad IN ('Francesa','Alemana','Británica') THEN 'Europa Occidental'
                WHEN p.nacionalidad IN ('Estadounidense','Canadiense')   THEN 'América del Norte'
                WHEN p.nacionalidad = 'Mexicana'                         THEN 'América Central'
                ELSE 'Otras regiones'
            END
        FROM Festival_Final_OLTP.dbo.Persona p
        WHERE p.nacionalidad NOT IN (SELECT pais FROM DIM_Geografia);

        -- 4.5) Traslados (origen/destino en España)
        INSERT INTO DIM_Geografia(pais, ciudad, continente, region)
        SELECT DISTINCT 'España', t.origen,  'Europa','Sur de Europa'
        FROM Festival_Final_OLTP.dbo.Traslado t
        WHERE t.origen NOT IN (SELECT ciudad FROM DIM_Geografia WHERE pais='España')
        UNION
        SELECT DISTINCT 'España', t.destino,'Europa','Sur de Europa'
        FROM Festival_Final_OLTP.dbo.Traslado t
        WHERE t.destino NOT IN (SELECT ciudad FROM DIM_Geografia WHERE pais='España');

        ------------------------------------------------------------------------
        -- 5) DIM_MetodoPago
        ------------------------------------------------------------------------
        PRINT 'Cargando DIM_MetodoPago...';
        INSERT INTO DIM_MetodoPago (
            nombre_metodo, tipo_metodo, requiere_procesamiento, comision_porcentaje
        )
        VALUES
          ('Efectivo',              'efectivo',     0, 0.0),
          ('Tarjeta de crédito',    'tarjeta',      1, 2.5),
          ('Tarjeta de débito',     'tarjeta',      1, 1.5),
          ('PayPal',                'electrónico',  1, 3.0),
          ('Transferencia bancaria','transferencia',1, 0.5);

        ------------------------------------------------------------------------
        -- 6) DIM_Pelicula
        ------------------------------------------------------------------------
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
            (
              SELECT TOP 1 per.nombre + ' ' + per.apellidos
                FROM Festival_Final_OLTP.dbo.Pelicula_Persona_Rol ppr
                JOIN Festival_Final_OLTP.dbo.Persona per
                  ON ppr.persona_id = per.persona_id
                JOIN Festival_Final_OLTP.dbo.Rol_Cinematografico rc
                  ON ppr.rol_id = rc.rol_id
               WHERE ppr.pelicula_id = p.pelicula_id
                 AND rc.nombre = 'Director'
               ORDER BY per.nombre
            ),
            p.estado_seleccion,
            STUFF((
              SELECT ', ' + gc.nombre
                FROM Festival_Final_OLTP.dbo.Pelicula_Genero pg
                JOIN Festival_Final_OLTP.dbo.Genero_Cinematografico gc
                  ON pg.genero_id = gc.genero_id
               WHERE pg.pelicula_id = p.pelicula_id
               FOR XML PATH('')),1,2,''),
            (
              SELECT TOP 1 i.nombre
                FROM Festival_Final_OLTP.dbo.Pelicula_Idioma pi
                JOIN Festival_Final_OLTP.dbo.Idioma i
                  ON pi.idioma_id = i.idioma_id
               WHERE pi.pelicula_id = p.pelicula_id
                 AND pi.tipo = 'original'
            ),
            CASE WHEN EXISTS (
              SELECT 1
                FROM Festival_Final_OLTP.dbo.Pelicula_Idioma pi
                JOIN Festival_Final_OLTP.dbo.Idioma i
                  ON pi.idioma_id = i.idioma_id
               WHERE pi.pelicula_id = p.pelicula_id
                 AND pi.tipo = 'subtitulos'
                 AND i.codigo_iso = 'ES'
            ) THEN 1 ELSE 0 END,
            CASE WHEN EXISTS (
              SELECT 1
                FROM Festival_Final_OLTP.dbo.Pelicula_Idioma pi
                JOIN Festival_Final_OLTP.dbo.Idioma i
                  ON pi.idioma_id = i.idioma_id
               WHERE pi.pelicula_id = p.pelicula_id
                 AND pi.tipo = 'subtitulos'
                 AND i.codigo_iso = 'EN'
            ) THEN 1 ELSE 0 END
        FROM Festival_Final_OLTP.dbo.Pelicula p;

        ------------------------------------------------------------------------
        -- 7) DIM_Categoria
        ------------------------------------------------------------------------
        PRINT 'Cargando DIM_Categoria...';
        INSERT INTO DIM_Categoria (
            categoria_id, nombre_categoria, descripcion, tipo_categoria, edicion_anio
        )
        SELECT
            cc.categoria_id,
            cc.nombre,
            cc.descripcion,
            'Competición oficial',
            ef.anio
        FROM Festival_Final_OLTP.dbo.Categoria_Competicion cc
        JOIN Festival_Final_OLTP.dbo.Edicion_Festival ef
          ON cc.edicion_festival = ef.edicion_id;

        ------------------------------------------------------------------------
        -- 8) DIM_Sala
        ------------------------------------------------------------------------
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
                WHEN s.nombre LIKE '%VIP%'       THEN 'vip'
                WHEN s.nombre LIKE '%Exterior%'  THEN 'exterior'
                ELSE 'secundaria'
            END,
            s.caracteristicas_tecnicas
        FROM Festival_Final_OLTP.dbo.Sala s;

        ------------------------------------------------------------------------
        -- 9) DIM_Persona
        ------------------------------------------------------------------------
        PRINT 'Cargando DIM_Persona...';
        INSERT INTO DIM_Persona (
            persona_id, nombre_completo, email, nacionalidad, roles_principales, biografia
        )
        SELECT
            p.persona_id,
            p.nombre + ' ' + p.apellidos,
            p.email,
            p.nacionalidad,
            STUFF((
              SELECT ', ' + rc.nombre
                FROM Festival_Final_OLTP.dbo.Pelicula_Persona_Rol ppr
                JOIN Festival_Final_OLTP.dbo.Rol_Cinematografico rc
                  ON ppr.rol_id = rc.rol_id
               WHERE ppr.persona_id = p.persona_id
               GROUP BY rc.nombre
               FOR XML PATH('')
            ),1,2,''),
            p.biografia
        FROM Festival_Final_OLTP.dbo.Persona p;

        ------------------------------------------------------------------------
        -- 10) DIM_Asistente
        ------------------------------------------------------------------------
        PRINT 'Cargando DIM_Asistente...';
        INSERT INTO DIM_Asistente (
            asistente_id, nombre_completo, email, telefono,
            tipo_asistente, pais, ciudad, tiene_acreditacion, tipo_acreditacion
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
        LEFT JOIN Festival_Final_OLTP.dbo.Acreditacion ac
          ON a.asistente_id = ac.asistente_id;

        ------------------------------------------------------------------------
        -- 11) DIM_Entrada
        ------------------------------------------------------------------------
        PRINT 'Cargando DIM_Entrada...';
        INSERT INTO DIM_Entrada (
            tipo_entrada_id, nombre, descripcion, precio_base, es_abono, metodo_pago
        )
        SELECT tipo_entrada_id, nombre, descripcion, precio_base, 0, NULL
          FROM Festival_Final_OLTP.dbo.Tipo_Entrada
        UNION ALL
        SELECT 1000 + ROW_NUMBER() OVER(ORDER BY tipo_abono),
               tipo_abono,
               'Abono: ' + tipo_abono,
               precio,
               1,
               NULL
          FROM Festival_Final_OLTP.dbo.Abono
         GROUP BY tipo_abono, precio;

        ------------------------------------------------------------------------
        -- 12) DIM_Evento
        ------------------------------------------------------------------------
        PRINT 'Cargando DIM_Evento...';
        WITH EventosParalelos AS (
          SELECT
            ep.evento_id,
            CAST(ep.nombre AS NVARCHAR(200))      AS nombre_evento,
            CAST(ep.tipo   AS NVARCHAR(100))      AS tipo_evento,
            CAST(ep.descripcion AS NVARCHAR(MAX)) AS descripcion,
            CAST(ep.ubicacion  AS NVARCHAR(200))  AS ubicacion,
            ep.aforo_maximo,
            ep.requiere_inscripcion
          FROM Festival_Final_OLTP.dbo.Evento_Paralelo ep
        ),
        Proyecciones AS (
          SELECT
            10000 + pr.proyeccion_id              AS evento_id,
            CAST(p.titulo + ' (Proyección)' AS NVARCHAR(200)) AS nombre_evento,
            'Proyección'                          AS tipo_evento,
            p.sinopsis                            AS descripcion,
            s.nombre + ', ' + s.ubicacion         AS ubicacion,
            s.capacidad                           AS aforo_maximo,
            0                                     AS requiere_inscripcion
          FROM Festival_Final_OLTP.dbo.Proyeccion pr
          JOIN Festival_Final_OLTP.dbo.Pelicula p
            ON pr.pelicula_id = p.pelicula_id
          JOIN Festival_Final_OLTP.dbo.Sala s
            ON pr.sala_id = s.sala_id
        )
        INSERT INTO DIM_Evento (
            evento_id, nombre_evento, tipo_evento,
            descripcion, ubicacion, aforo_maximo, requiere_inscripcion
        )
        SELECT * FROM EventosParalelos
        UNION ALL
        SELECT * FROM Proyecciones;

        ------------------------------------------------------------------------
        -- 13) DIM_Jurado
        ------------------------------------------------------------------------
        PRINT 'Cargando DIM_Jurado...';
        INSERT INTO DIM_Jurado (
            jurado_id, nombre_jurado, edicion_anio,
            categorias_evaluacion, miembros
        )
        SELECT
            j.jurado_id,
            j.nombre,
            ef.anio,
            STUFF((
              SELECT ', ' + cc.nombre
                FROM Festival_Final_OLTP.dbo.Jurado_Categoria jc
                JOIN Festival_Final_OLTP.dbo.Categoria_Competicion cc
                  ON jc.categoria_id = cc.categoria_id
               WHERE jc.jurado_id = j.jurado_id
               FOR XML PATH('')
            ),1,2,''),
            STUFF((
              SELECT ', ' + per.nombre + ' ' + per.apellidos + ' (' + mj.cargo + ')'
                FROM Festival_Final_OLTP.dbo.Miembro_Jurado mj
                JOIN Festival_Final_OLTP.dbo.Persona per
                  ON mj.persona_id = per.persona_id
               WHERE mj.jurado_id = j.jurado_id
               FOR XML PATH('')
            ),1,2,'')
        FROM Festival_Final_OLTP.dbo.Jurado j
        JOIN Festival_Final_OLTP.dbo.Edicion_Festival ef
          ON j.edicion_festival = ef.edicion_id;

        ------------------------------------------------------------------------
        -- 14) DIM_Patrocinador
        ------------------------------------------------------------------------
        PRINT 'Cargando DIM_Patrocinador...';
        INSERT INTO DIM_Patrocinador (
            patrocinador_id, nombre, contacto_principal,
            tipo, pais, sector_industria,
            es_recurrente, categorias_patrocinio
        )
        SELECT
            p.patrocinador_id,
            p.nombre,
            p.contacto_principal,
            p.tipo,
            p.pais,
            p.sector_industria,
            CASE WHEN COUNT(DISTINCT pa.edicion_festival)>1 THEN 1 ELSE 0 END,
            STUFF((
              SELECT ', ' + pa.tipo_aportacion
                FROM Festival_Final_OLTP.dbo.Patrocinio pa
               WHERE pa.patrocinador_id = p.patrocinador_id
               GROUP BY pa.tipo_aportacion
               FOR XML PATH('')
            ),1,2,'')
        FROM Festival_Final_OLTP.dbo.Patrocinador p
        LEFT JOIN Festival_Final_OLTP.dbo.Patrocinio pa
          ON p.patrocinador_id = pa.patrocinador_id
        GROUP BY
          p.patrocinador_id,
          p.nombre,
          p.contacto_principal,
          p.tipo,
          p.pais,
          p.sector_industria;

        ------------------------------------------------------------------------
        -- FIN de las dimensiones
        ------------------------------------------------------------------------
        COMMIT TRANSACTION;
        PRINT 'Carga de dimensiones completada correctamente.';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        DECLARE @ErrMsg NVARCHAR(4000)=ERROR_MESSAGE(), @ErrLine INT=ERROR_LINE();
        THROW;  -- relanza el error al SSIS
    END CATCH
END
GO

-- 3) Probamos llamando al procedimiento
--EXEC dbo.usp_LoadDimensions;
--GO
