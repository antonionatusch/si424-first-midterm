USE OLAP_Claude;
GO

/*===========================================
  =====           DIMENSIONES           =====
  ===========================================*/

-- ============================================
-- Fechas de Proyección (FACT_Proyecciones, FACT_Ventas_Entradas)
-- ============================================
INSERT INTO DIM_Tiempo (
    tiempo_id, fecha, dia, dia_semana, semana, mes, trimestre, año, es_fin_semana, es_festivo, temporada_festival
)
SELECT 
    tiempo_id, fecha,
    DAY(fecha),
    DATENAME(WEEKDAY, fecha),
    DATEPART(WEEK, fecha),
    MONTH(fecha),
    DATEPART(QUARTER, fecha),
    YEAR(fecha),
    CASE WHEN DATENAME(WEEKDAY, fecha) IN ('Saturday', 'Sunday') THEN 1 ELSE 0 END,
    0,
    'Proyección'
FROM (
    SELECT DISTINCT 
        CONVERT(INT, CONVERT(VARCHAR(8), fecha, 112)) AS tiempo_id,
        fecha
    FROM OLTP_Claude.dbo.Proyeccion
) AS fechas
WHERE tiempo_id NOT IN (SELECT tiempo_id FROM DIM_Tiempo);
GO

-- ============================================
-- Fechas de Venta de Entradas (FACT_Ventas_Entradas)
-- ============================================
INSERT INTO DIM_Tiempo (
    tiempo_id, fecha, dia, dia_semana, semana, mes, trimestre, año, es_fin_semana, es_festivo, temporada_festival
)
SELECT 
    tiempo_id, fecha,
    DAY(fecha),
    DATENAME(WEEKDAY, fecha),
    DATEPART(WEEK, fecha),
    MONTH(fecha),
    DATEPART(QUARTER, fecha),
    YEAR(fecha),
    CASE WHEN DATENAME(WEEKDAY, fecha) IN ('Saturday', 'Sunday') THEN 1 ELSE 0 END,
    0,
    'Venta Entrada'
FROM (
    SELECT DISTINCT 
        CONVERT(INT, CONVERT(VARCHAR(8), fecha_venta, 112)) AS tiempo_id,
        fecha_venta AS fecha
    FROM OLTP_Claude.dbo.Entrada
) AS fechas
WHERE tiempo_id NOT IN (SELECT tiempo_id FROM DIM_Tiempo);
GO

-- ============================================
-- Fechas de Evaluación (FACT_Evaluaciones_Jurado)
-- ============================================
INSERT INTO DIM_Tiempo (
    tiempo_id, fecha, dia, dia_semana, semana, mes, trimestre, año, es_fin_semana, es_festivo, temporada_festival
)
SELECT 
    tiempo_id, fecha,
    DAY(fecha),
    DATENAME(WEEKDAY, fecha),
    DATEPART(WEEK, fecha),
    MONTH(fecha),
    DATEPART(QUARTER, fecha),
    YEAR(fecha),
    CASE WHEN DATENAME(WEEKDAY, fecha) IN ('Saturday', 'Sunday') THEN 1 ELSE 0 END,
    0,
    'Evaluación'
FROM (
    SELECT DISTINCT 
        CONVERT(INT, CONVERT(VARCHAR(8), fecha_evaluacion, 112)) AS tiempo_id,
        fecha_evaluacion AS fecha
    FROM OLTP_Claude.dbo.Evaluacion
) AS fechas
WHERE tiempo_id NOT IN (SELECT tiempo_id FROM DIM_Tiempo);
GO

-- ============================================
-- Fechas de Premio Otorgado (FACT_Premios)
-- ============================================
INSERT INTO DIM_Tiempo (
    tiempo_id, fecha, dia, dia_semana, semana, mes, trimestre, año, es_fin_semana, es_festivo, temporada_festival
)
SELECT 
    tiempo_id, fecha,
    DAY(fecha),
    DATENAME(WEEKDAY, fecha),
    DATEPART(WEEK, fecha),
    MONTH(fecha),
    DATEPART(QUARTER, fecha),
    YEAR(fecha),
    CASE WHEN DATENAME(WEEKDAY, fecha) IN ('Saturday', 'Sunday') THEN 1 ELSE 0 END,
    0,
    'Premio'
FROM (
    SELECT DISTINCT 
        CONVERT(INT, CONVERT(VARCHAR(8), fecha_otorgamiento, 112)) AS tiempo_id,
        fecha_otorgamiento AS fecha
    FROM OLTP_Claude.dbo.Premio_Otorgado
) AS fechas
WHERE tiempo_id NOT IN (SELECT tiempo_id FROM DIM_Tiempo);
GO

INSERT INTO FACT_Patrocinios (
    patrocinio_id,
    patrocinador_id,
    edicion_id,
    tiempo_id,
    valor_monetario,
    valor_en_especie,
    categoria_patrocinio,
    retorno_estimado
)
SELECT 
    p.patrocinio_id,
    p.patrocinador_id,
    p.edicion_festival,
    CONVERT(INT, CONVERT(VARCHAR(8), ef.fecha_inicio, 112)),
    p.valor_monetario,
    0,
    p.tipo_aportacion,
    ISNULL(p.valor_monetario, 0) * 1.2
FROM OLTP_Claude.dbo.Patrocinio p
JOIN OLTP_Claude.dbo.Edicion_Festival ef ON p.edicion_festival = ef.edicion_id;
GO

-- ============================================
-- Fechas de Eventos Paralelos (FACT_Eventos_Paralelos)
-- ============================================
INSERT INTO DIM_Tiempo (
    tiempo_id, fecha, dia, dia_semana, semana, mes, trimestre, año, es_fin_semana, es_festivo, temporada_festival
)
SELECT 
    tiempo_id, fecha,
    DAY(fecha),
    DATENAME(WEEKDAY, fecha),
    DATEPART(WEEK, fecha),
    MONTH(fecha),
    DATEPART(QUARTER, fecha),
    YEAR(fecha),
    CASE WHEN DATENAME(WEEKDAY, fecha) IN ('Saturday', 'Sunday') THEN 1 ELSE 0 END,
    0,
    'Evento Paralelo'
FROM (
    SELECT DISTINCT 
        CONVERT(INT, CONVERT(VARCHAR(8), fecha, 112)) AS tiempo_id,
        fecha
    FROM OLTP_Claude.dbo.Evento_Paralelo
) AS fechas
WHERE tiempo_id NOT IN (SELECT tiempo_id FROM DIM_Tiempo);
GO

INSERT INTO DIM_Pelicula (
    pelicula_id,
    titulo,
    año_produccion,
    duracion,
    pais_origen,
    clasificacion_edad,
    formato_proyeccion,
    nombre_director_principal
)
SELECT 
    p.pelicula_id,
    p.titulo,
    p.año,
    p.duracion,
    p.pais_origen,
    p.clasificacion_edad,
    p.formato_proyeccion,
    ISNULL(directores.nombre + ' ' + directores.apellidos, 'Desconocido')
FROM OLTP_Claude.dbo.Pelicula p
LEFT JOIN (
    SELECT pr.pelicula_id, per.nombre, per.apellidos
    FROM OLTP_Claude.dbo.Pelicula_Persona_Rol pr
    JOIN OLTP_Claude.dbo.Persona per ON pr.persona_id = per.persona_id
    JOIN OLTP_Claude.dbo.Rol_Cinematografico rol ON pr.rol_id = rol.rol_id
    WHERE rol.nombre = 'Director'
) AS directores ON p.pelicula_id = directores.pelicula_id;
GO

INSERT INTO DIM_Edicion (
    edicion_id,
    año_edicion,
    tema,
    director_festival,
    fechas
)
SELECT 
    ef.edicion_id,
    ef.año,
    ef.tema,
    ef.director_festival,
    FORMAT(ef.fecha_inicio, 'yyyy-MM-dd') + ' a ' + FORMAT(ef.fecha_fin, 'yyyy-MM-dd') AS fechas
FROM OLTP_Claude.dbo.Edicion_Festival ef;
GO

INSERT INTO DIM_Entrada (
    entrada_id,
    tipo_entrada,
    canal_venta,
    precio_base,
    descuento_aplicado
)
SELECT 
    e.entrada_id,
    te.nombre AS tipo_entrada,
    'venta directa' AS canal_venta,  -- reemplazar según lógica de negocio
    te.precio_base,
    te.precio_base - e.precio_final AS descuento_aplicado
FROM OLTP_Claude.dbo.Entrada e
JOIN OLTP_Claude.dbo.Tipo_Entrada te ON e.tipo_entrada_id = te.tipo_entrada_id;
GO

INSERT INTO DIM_Sala (
    sala_id,
    nombre_sala,
    ubicacion,
    capacidad,
    tipo_sala
)
SELECT 
    s.sala_id,
    s.nombre,
    s.ubicacion,
    s.capacidad,
    CASE 
        WHEN s.nombre LIKE '%Principal%' THEN 'Premium'
        WHEN s.nombre LIKE '%Aire Libre%' THEN 'Especial'
        WHEN s.capacidad > 150 THEN 'Grande'
        WHEN s.capacidad BETWEEN 80 AND 150 THEN 'Mediana'
        ELSE 'Pequeña'
    END AS tipo_sala
FROM OLTP_Claude.dbo.Sala s;
GO

INSERT INTO DIM_Asistente (
    asistente_id,
    tipo_asistente,
    rango_edad,
    genero,
    procedencia_geografica
)
SELECT 
    a.asistente_id,
    a.tipo_asistente,
    'desconocido', -- Ir complementando según la lógica de negocio
    'desconocido',
    'desconocido'
FROM OLTP_Claude.dbo.Asistente a;
GO

INSERT INTO DIM_Categoria (
    categoria_id,
    nombre_categoria,
    descripcion,
    tipo_categoria
)
SELECT 
    c.categoria_id,
    c.nombre,
    c.descripcion,
    CASE 
        WHEN c.nombre LIKE '%Actor%' THEN 'Actuación'
        WHEN c.nombre LIKE '%Actriz%' THEN 'Actuación'
        WHEN c.nombre LIKE '%Director%' THEN 'Dirección'
        WHEN c.nombre LIKE '%Público%' THEN 'Audiencia'
        ELSE 'General'
    END AS tipo_categoria
FROM OLTP_Claude.dbo.Categoria_Competicion c;
GO

INSERT INTO DIM_Jurado (
    jurado_id,
    nombre_jurado,
    categoria_evaluacion,
    numero_miembros
)
SELECT 
    j.jurado_id,
    j.nombre,
    'General',  -- Valor por defecto o ajustar según la lógica de negocio
    (SELECT COUNT(*) 
     FROM OLTP_Claude.dbo.Miembro_Jurado mj 
     WHERE mj.jurado_id = j.jurado_id)
FROM OLTP_Claude.dbo.Jurado j;
GO

INSERT INTO DIM_Persona (persona_id, nombre_completo, pais_origen, tipo_persona)
SELECT 
    p.persona_id,
    p.nombre + ' ' + p.apellidos AS nombre_completo,
    p.nacionalidad AS pais_origen,
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM OLTP_Claude.dbo.Pelicula_Persona_Rol pr 
            WHERE pr.persona_id = p.persona_id AND pr.rol_id = 1
        ) THEN 'Director'
        WHEN EXISTS (
            SELECT 1 FROM OLTP_Claude.dbo.Pelicula_Persona_Rol pr 
            WHERE pr.persona_id = p.persona_id AND pr.rol_id = 2
        ) THEN 'Actor Principal'
        WHEN EXISTS (
            SELECT 1 FROM OLTP_Claude.dbo.Miembro_Jurado mj 
            WHERE mj.persona_id = p.persona_id
        ) THEN 'Jurado'
        ELSE 'Otro'
    END AS tipo_persona
FROM OLTP_Claude.dbo.Persona p;
GO

INSERT INTO DIM_Evento (evento_id, nombre_evento, tipo_evento, requiere_inscripcion)
SELECT 
    e.evento_id,
    e.nombre,
    e.tipo,
    e.requiere_inscripcion
FROM OLTP_Claude.dbo.Evento_Paralelo e;
GO

INSERT INTO DIM_Patrocinador (
    patrocinador_id,
    nombre,
    tipo,
    contacto_principal,
    telefono,
    email,
    sector_industria,
    pais_origen
)
SELECT 
    p.patrocinador_id,
    p.nombre,
    p.tipo,
    p.contacto_principal,
    p.telefono,
    p.email,
    NULL AS sector_industria,     -- Actualizar luego con datos más específicos
    'Bolivia' AS pais_origen      -- Asumimos que son de Bolivia por defecto
FROM OLTP_Claude.dbo.Patrocinador p;
GO

/*===========================================
  =====             HECHOS              =====
  ===========================================*/

INSERT INTO FACT_Proyecciones (
    proyeccion_id,
    tiempo_id,
    pelicula_id,
    sala_id,
    edicion_id,
    duracion_proyeccion,
    tiene_qa,
    aforo_total,
    entradas_vendidas,
    porcentaje_ocupacion,
    ingresos_totales
)
SELECT 
    p.proyeccion_id,
    CONVERT(INT, CONVERT(VARCHAR(8), p.fecha, 112)) AS tiempo_id,
    p.pelicula_id,
    p.sala_id,
    ef.edicion_id,
    DATEDIFF(MINUTE, p.hora_inicio, p.hora_fin),
    p.sesion_qa,
    s.capacidad,
    COUNT(e.entrada_id),
    CAST(COUNT(e.entrada_id) * 100.0 / NULLIF(s.capacidad, 0) AS DECIMAL(5,2)),
    SUM(ISNULL(e.precio_final, 0))
FROM OLTP_Claude.dbo.Proyeccion p
JOIN OLTP_Claude.dbo.Sala s ON p.sala_id = s.sala_id
JOIN OLTP_Claude.dbo.Edicion_Festival ef ON YEAR(p.fecha) = ef.año
LEFT JOIN OLTP_Claude.dbo.Entrada e ON e.proyeccion_id = p.proyeccion_id
GROUP BY 
    p.proyeccion_id, p.fecha, p.pelicula_id, p.sala_id, ef.edicion_id,
    p.hora_inicio, p.hora_fin, p.sesion_qa, s.capacidad;
GO

INSERT INTO FACT_Ventas_Entradas (
    venta_id,
    tiempo_id,
    pelicula_id,
    sala_id,
    tiempo_proyeccion_id,
    asistente_id,
    entrada_id,
    edicion_id,
    precio_final,
    canal_venta,
    fue_utilizada,
    tiempo_compra_anticipada
)
SELECT 
    e.entrada_id,
    CONVERT(INT, CONVERT(VARCHAR(8), e.fecha_venta, 112)),
    p.pelicula_id,
    p.sala_id,
    CONVERT(INT, CONVERT(VARCHAR(8), p.fecha, 112)),
    e.asistente_id,
    e.entrada_id,
    ef.edicion_id,
    e.precio_final,
    'Online',
    e.usado,
    DATEDIFF(DAY, e.fecha_venta, p.fecha)
FROM OLTP_Claude.dbo.Entrada e
JOIN OLTP_Claude.dbo.Proyeccion p ON e.proyeccion_id = p.proyeccion_id
JOIN OLTP_Claude.dbo.Edicion_Festival ef ON YEAR(p.fecha) = ef.año;
GO

INSERT INTO FACT_Evaluaciones_Jurado (
    evaluacion_id,
    pelicula_id,
    jurado_id,
    persona_id,
    categoria_id,
    edicion_id,
    tiempo_id,
    puntuacion,
    posicion_ranking
)
SELECT 
    e.evaluacion_id,
    e.pelicula_id,
    e.jurado_id,
    e.persona_id,
    NULL, -- O dejar como valor nulo si no tienes la categoría
    j.edicion_festival,
    CONVERT(INT, CONVERT(VARCHAR(8), e.fecha_evaluacion, 112)) AS tiempo_id,
    e.puntuacion,
    NULL
FROM OLTP_Claude.dbo.Evaluacion e
JOIN OLTP_Claude.dbo.Jurado j ON e.jurado_id = j.jurado_id;
GO

INSERT INTO FACT_Premios (
    premio_id,
    pelicula_id,
    categoria_id,
    jurado_id,
    edicion_id,
    tiempo_id,
    dotacion_economica,
    prestigio_premio
)
SELECT 
    po.premio_id,
    po.pelicula_id,
    pr.categoria_id,
    (
        SELECT TOP 1 jc.jurado_id
        FROM OLTP_Claude.dbo.Jurado_Categoria jc
        WHERE jc.categoria_id = pr.categoria_id
    ) AS jurado_id,
    po.edicion_festival,
    CONVERT(INT, CONVERT(VARCHAR(8), po.fecha_otorgamiento, 112)) AS tiempo_id,
    pr.dotacion,
    -- Aquí puedes ajustar el prestigio si tienes una lógica para ello:
    CASE 
        WHEN pr.dotacion >= 40000 THEN 'Alto'
        WHEN pr.dotacion BETWEEN 20000 AND 39999 THEN 'Medio'
        ELSE 'Bajo'
    END AS prestigio_premio
FROM OLTP_Claude.dbo.Premio_Otorgado po
JOIN OLTP_Claude.dbo.Premio pr ON po.premio_id = pr.premio_id;
GO

INSERT INTO FACT_Eventos_Paralelos (
    evento_participacion_id,
    evento_id,
    tiempo_id,
    persona_id,
    asistente_id,
    edicion_id,
    aforo_maximo,
    inscripciones_realizadas,
    asistencia_real,
    valoracion_promedio
)
SELECT 
    ie.inscripcion_id, -- Lo usamos como identificador único
    e.evento_id,
    CONVERT(INT, CONVERT(VARCHAR(8), e.fecha, 112)) AS tiempo_id,
    NULL AS persona_id, -- Puedes agregar lógica si hay participantes tipo persona (por ejemplo, moderadores)
    ie.asistente_id,
    ef.edicion_id,
    e.aforo_maximo,
    (SELECT COUNT(*) FROM OLTP_Claude.dbo.Inscripcion_Evento ie2 WHERE ie2.evento_id = e.evento_id) AS inscripciones_realizadas,
    (SELECT COUNT(*) FROM OLTP_Claude.dbo.Inscripcion_Evento ie3 WHERE ie3.evento_id = e.evento_id AND ie3.asistio = 1) AS asistencia_real,
    NULL AS valoracion_promedio -- Si tienes encuestas de satisfacción podrías calcularla
FROM OLTP_Claude.dbo.Evento_Paralelo e
JOIN OLTP_Claude.dbo.Inscripcion_Evento ie ON e.evento_id = ie.evento_id
JOIN OLTP_Claude.dbo.Edicion_Festival ef ON YEAR(e.fecha) = ef.año
WHERE CONVERT(INT, CONVERT(VARCHAR(8), e.fecha, 112)) IN (
    SELECT tiempo_id FROM OLAP_Claude.dbo.DIM_Tiempo
);
SELECT DISTINCT CONVERT(INT, CONVERT(VARCHAR(8), fecha_inicio, 112)) AS tiempo_id
FROM OLTP_Claude.dbo.Edicion_Festival;

SELECT tiempo_id FROM OLAP_Claude.dbo.DIM_Tiempo
WHERE tiempo_id IN (
    SELECT DISTINCT CONVERT(INT, CONVERT(VARCHAR(8), fecha_inicio, 112))
    FROM OLTP_Claude.dbo.Edicion_Festival
);
GO

INSERT INTO FACT_Patrocinios (
    patrocinio_id,
    patrocinador_id,
    edicion_id,
    tiempo_id,
    valor_monetario,
    valor_en_especie,
    categoria_patrocinio,
    retorno_estimado
)
SELECT 
    p.patrocinio_id,
    p.patrocinador_id,
    p.edicion_festival,
    -- Convertimos la fecha actual (o asumida) en formato INT para tiempo_id
    CONVERT(INT, CONVERT(VARCHAR(8), ef.fecha_inicio, 112)) AS tiempo_id,
    p.valor_monetario,
    0 AS valor_en_especie, -- Si no hay una columna que lo indique, ponemos 0 por defecto
    p.tipo_aportacion AS categoria_patrocinio,
    ISNULL(p.valor_monetario, 0) * 1.2 AS retorno_estimado -- Ejemplo de cálculo estimado
FROM OLTP_Claude.dbo.Patrocinio p
JOIN OLTP_Claude.dbo.Edicion_Festival ef ON p.edicion_festival = ef.edicion_id
WHERE NOT EXISTS (
    SELECT 1 FROM OLAP_Claude.dbo.FACT_Patrocinios fp WHERE fp.patrocinio_id = p.patrocinio_id
);

/*===========================================
  =====              PROBAR             =====
  ===========================================*/

-- SELECT * FROM DIM_Tiempo;
-- SELECT * FROM DIM_Pelicula;
-- SELECT * FROM DIM_Categoria;
-- SELECT * FROM DIM_Sala;
-- SELECT * FROM DIM_Persona;
-- SELECT * FROM DIM_Asistente;
-- SELECT * FROM DIM_Entrada;
-- SELECT * FROM DIM_Evento;
-- SELECT * FROM DIM_Jurado;
-- SELECT * FROM DIM_Edicion;
-- SELECT * FROM DIM_Patrocinador;

-- SELECT * FROM FACT_Proyecciones;
-- SELECT * FROM FACT_Ventas_Entradas;
-- SELECT * FROM FACT_Evaluaciones_Jurado;
-- SELECT * FROM FACT_Premios;
-- SELECT * FROM FACT_Eventos_Paralelos;
-- SELECT * FROM FACT_Patrocinios;
