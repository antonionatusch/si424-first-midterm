/*1. Obtener las películas más populares basadas en la venta de entradas*/
SELECT TOP 10
    p.pelicula_id, 
    p.titulo, 
    p.anio, 
    COUNT(e.entrada_id) AS entradas_vendidas,
    s.capacidad, 
    CAST(COUNT(e.entrada_id) * 100.0 / NULLIF(s.capacidad, 0) AS DECIMAL(5,2)) AS porcentaje_ocupacion
FROM Pelicula p
JOIN Proyeccion pr ON p.pelicula_id = pr.pelicula_id
JOIN Sala s ON pr.sala_id = s.sala_id
JOIN Entrada e ON pr.proyeccion_id = e.proyeccion_id
WHERE e.usado = 1
GROUP BY p.pelicula_id, p.titulo, p.anio, pr.proyeccion_id, s.capacidad
ORDER BY entradas_vendidas DESC;
GO

/*2. Consulta para el programa de proyecciones con detalles de películas y Q&A*/
SELECT 
    pr.fecha, 
    pr.hora_inicio, 
    pr.hora_fin, 
    s.nombre AS sala, 
    s.ubicacion,
    p.titulo, 
    p.duracion, 
    p.pais_origen, 
    p.clasificacion_edad,
    STUFF((
        SELECT ', ' + g.nombre
        FROM Pelicula_Genero pg2
        JOIN Genero_Cinematografico g ON pg2.genero_id = g.genero_id
        WHERE pg2.pelicula_id = p.pelicula_id
        FOR XML PATH('')
    ), 1, 2, '') AS generos,
    CASE WHEN qa.qa_id IS NOT NULL THEN 'Sí' ELSE 'No' END AS tiene_qa,
    CASE WHEN qa.qa_id IS NOT NULL THEN qa.moderador ELSE NULL END AS moderador_qa,
    STUFF((
        SELECT ', ' + per.nombre + ' ' + per.apellidos
        FROM QA_Participante qap
        JOIN Persona per ON qap.persona_id = per.persona_id
        WHERE qap.qa_id = qa.qa_id
        FOR XML PATH('')
    ), 1, 2, '') AS participantes_qa
FROM Proyeccion pr
JOIN Pelicula p ON pr.pelicula_id = p.pelicula_id
JOIN Sala s ON pr.sala_id = s.sala_id
LEFT JOIN QA_Sesion qa ON pr.proyeccion_id = qa.proyeccion_id
GROUP BY 
    pr.proyeccion_id, 
    pr.fecha, 
    pr.hora_inicio, 
    pr.hora_fin, 
    s.nombre, 
    s.ubicacion, 
    p.pelicula_id,
    p.titulo, 
    p.duracion, 
    p.pais_origen, 
    p.clasificacion_edad, 
    qa.qa_id, 
    qa.moderador
ORDER BY pr.fecha, pr.hora_inicio;
GO

/*3. Consulta para generar un informe de evaluaciones de los jurados*/
SELECT 
    cat.nombre AS categoria,
    j.nombre AS jurado,
    p.titulo AS pelicula,
    AVG(e.puntuacion) AS puntuacion_media,
    MIN(e.puntuacion) AS puntuacion_minima,
    MAX(e.puntuacion) AS puntuacion_maxima,
    COUNT(DISTINCT e.persona_id) AS numero_evaluadores,
    STUFF((
        SELECT ', ' + pers.nombre + ' ' + pers.apellidos
        FROM Evaluacion e2
        JOIN Persona pers ON e2.persona_id = pers.persona_id
        WHERE e2.pelicula_id = p.pelicula_id AND e2.jurado_id = j.jurado_id
        FOR XML PATH('')
    ), 1, 2, '') AS evaluadores
FROM Evaluacion e
JOIN Pelicula p ON e.pelicula_id = p.pelicula_id
JOIN Jurado j ON e.jurado_id = j.jurado_id
JOIN Jurado_Categoria jc ON j.jurado_id = jc.jurado_id
JOIN Categoria_Competicion cat ON jc.categoria_id = cat.categoria_id
JOIN Persona pers ON e.persona_id = pers.persona_id
GROUP BY cat.nombre, j.nombre, j.jurado_id, p.titulo, p.pelicula_id
ORDER BY cat.nombre, puntuacion_media DESC;
GO

/*4. Consulta para obtener estadísticas completas por país de origen*/
SELECT 
    p.pais_origen,
    COUNT(DISTINCT p.pelicula_id) AS total_peliculas,
    SUM(CASE WHEN p.estado_seleccion = 'seleccionada' THEN 1 ELSE 0 END) AS peliculas_seleccionadas,
    SUM(CASE WHEN p.estado_seleccion = 'premiada' THEN 1 ELSE 0 END) AS peliculas_premiadas,
    COUNT(DISTINCT pr.proyeccion_id) AS total_proyecciones,
    COUNT(DISTINCT e.entrada_id) AS entradas_vendidas,
    (SELECT COUNT(DISTINCT premio_otorgado_id) 
     FROM Premio_Otorgado po 
     WHERE po.pelicula_id IN (SELECT pelicula_id FROM Pelicula WHERE pais_origen = p.pais_origen)
     AND po.edicion_festival = ef.edicion_id) AS premios_ganados
FROM Pelicula p
LEFT JOIN Proyeccion pr ON p.pelicula_id = pr.pelicula_id
LEFT JOIN Entrada e ON pr.proyeccion_id = e.proyeccion_id
JOIN Edicion_Festival ef ON ef.anio = (SELECT MAX(anio) FROM Edicion_Festival)
GROUP BY p.pais_origen, ef.edicion_id
ORDER BY total_peliculas DESC;
GO

/*5. Consulta para la gestión de invitados especiales, alojamiento y traslados*/
SELECT 
    p.persona_id,
    p.nombre + ' ' + p.apellidos AS nombre_completo,
    p.email,
    p.telefono,
    STUFF((
        SELECT ', ' + r2.nombre
        FROM Pelicula_Persona_Rol ppr2
        JOIN Rol_Cinematografico r2 ON ppr2.rol_id = r2.rol_id
        WHERE ppr2.persona_id = p.persona_id
        FOR XML PATH('')
    ), 1, 2, '') AS roles,
    STUFF((
        SELECT ', ' + pel2.titulo
        FROM Pelicula_Persona_Rol ppr2
        JOIN Pelicula pel2 ON ppr2.pelicula_id = pel2.pelicula_id
        WHERE ppr2.persona_id = p.persona_id
        FOR XML PATH('')
    ), 1, 2, '') AS peliculas_relacionadas,
    STUFF((
        SELECT ', ' + a.nombre_establecimiento + ' (' + CONVERT(VARCHAR, ra.fecha_entrada, 23) + ' al ' + CONVERT(VARCHAR, ra.fecha_salida, 23) + ')'
        FROM Reserva_Alojamiento ra
        JOIN Alojamiento a ON ra.alojamiento_id = a.alojamiento_id
        WHERE ra.persona_id = p.persona_id
        FOR XML PATH('')
    ), 1, 2, '') AS alojamientos,
    (SELECT COUNT(*) FROM Traslado t WHERE t.persona_id = p.persona_id) AS numero_traslados,
    CASE 
        WHEN EXISTS (SELECT 1 FROM Miembro_Jurado mj WHERE mj.persona_id = p.persona_id) THEN 'Sí'
        ELSE 'No'
    END AS es_jurado,
    CASE 
        WHEN EXISTS (SELECT 1 FROM QA_Participante qap 
                     JOIN QA_Sesion qa ON qap.qa_id = qa.qa_id
                     WHERE qap.persona_id = p.persona_id) THEN 'Sí'
        ELSE 'No'
    END AS participa_qa
FROM Persona p
WHERE EXISTS (SELECT 1 FROM Reserva_Alojamiento ra WHERE ra.persona_id = p.persona_id)
   OR EXISTS (SELECT 1 FROM Traslado t WHERE t.persona_id = p.persona_id)
   OR EXISTS (SELECT 1 FROM Miembro_Jurado mj WHERE mj.persona_id = p.persona_id)
GROUP BY p.persona_id, p.nombre, p.apellidos, p.email, p.telefono
ORDER BY nombre_completo;
GO