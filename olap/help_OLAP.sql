USE Festival_Final_OLAP;
GO

-- Primero eliminamos las tablas de hechos (que referencian a otras tablas)
PRINT 'Eliminando tablas de hechos...';

-- Desactivar temporalmente la verificación de claves foráneas para facilitar el borrado
PRINT 'Desactivando verificación de claves foráneas...';
EXEC sp_MSforeachtable "ALTER TABLE ? NOCHECK CONSTRAINT ALL";

IF OBJECT_ID('FACT_Gastos_Festival', 'U') IS NOT NULL
    DROP TABLE FACT_Gastos_Festival;
    
IF OBJECT_ID('FACT_Traslados', 'U') IS NOT NULL
    DROP TABLE FACT_Traslados;
    
IF OBJECT_ID('FACT_Alojamientos', 'U') IS NOT NULL
    DROP TABLE FACT_Alojamientos;
    
IF OBJECT_ID('FACT_Patrocinios', 'U') IS NOT NULL
    DROP TABLE FACT_Patrocinios;
    
IF OBJECT_ID('FACT_Eventos_Paralelos', 'U') IS NOT NULL
    DROP TABLE FACT_Eventos_Paralelos;
    
IF OBJECT_ID('FACT_Premios', 'U') IS NOT NULL
    DROP TABLE FACT_Premios;
    
IF OBJECT_ID('FACT_Evaluaciones_Jurado', 'U') IS NOT NULL
    DROP TABLE FACT_Evaluaciones_Jurado;
    
IF OBJECT_ID('FACT_Ventas_Entradas', 'U') IS NOT NULL
    DROP TABLE FACT_Ventas_Entradas;
    
IF OBJECT_ID('FACT_Proyecciones', 'U') IS NOT NULL
    DROP TABLE FACT_Proyecciones;

-- Luego eliminamos las tablas de dimensiones
PRINT 'Eliminando tablas de dimensiones...';

IF OBJECT_ID('DIM_CategoriaGasto', 'U') IS NOT NULL
    DROP TABLE DIM_CategoriaGasto;
    
IF OBJECT_ID('DIM_Geografia', 'U') IS NOT NULL
    DROP TABLE DIM_Geografia;
    
IF OBJECT_ID('DIM_MetodoPago', 'U') IS NOT NULL
    DROP TABLE DIM_MetodoPago;
    
IF OBJECT_ID('DIM_Patrocinador', 'U') IS NOT NULL
    DROP TABLE DIM_Patrocinador;
    
IF OBJECT_ID('DIM_Edicion', 'U') IS NOT NULL
    DROP TABLE DIM_Edicion;
    
IF OBJECT_ID('DIM_Jurado', 'U') IS NOT NULL
    DROP TABLE DIM_Jurado;
    
IF OBJECT_ID('DIM_Evento', 'U') IS NOT NULL
    DROP TABLE DIM_Evento;
    
IF OBJECT_ID('DIM_Entrada', 'U') IS NOT NULL
    DROP TABLE DIM_Entrada;
    
IF OBJECT_ID('DIM_Asistente', 'U') IS NOT NULL
    DROP TABLE DIM_Asistente;
    
IF OBJECT_ID('DIM_Persona', 'U') IS NOT NULL
    DROP TABLE DIM_Persona;
    
IF OBJECT_ID('DIM_Sala', 'U') IS NOT NULL
    DROP TABLE DIM_Sala;
    
IF OBJECT_ID('DIM_Categoria', 'U') IS NOT NULL
    DROP TABLE DIM_Categoria;
    
IF OBJECT_ID('DIM_Pelicula', 'U') IS NOT NULL
    DROP TABLE DIM_Pelicula;
    
IF OBJECT_ID('DIM_Tiempo', 'U') IS NOT NULL
    DROP TABLE DIM_Tiempo;

PRINT 'Todas las tablas han sido eliminadas con éxito.';
GO


PRINT '===== VERIFICACIÓN DE TABLAS DE DIMENSIONES =====';

-- DIM_Tiempo
PRINT '1. DIM_Tiempo:';
SELECT COUNT(*) AS 'Total registros en DIM_Tiempo' FROM DIM_Tiempo;
SELECT TOP 5 tiempo_id, fecha, anio, mes, nombre_mes, temporada_festival 
FROM DIM_Tiempo 
ORDER BY fecha;

-- DIM_Edicion
PRINT '2. DIM_Edicion:';
SELECT COUNT(*) AS 'Total registros en DIM_Edicion' FROM DIM_Edicion;
SELECT edicion_id, anio, tema, director_festival, fecha_inicio, fecha_fin, duracion_dias 
FROM DIM_Edicion;

-- DIM_CategoriaGasto
PRINT '3. DIM_CategoriaGasto:';
SELECT COUNT(*) AS 'Total registros en DIM_CategoriaGasto' FROM DIM_CategoriaGasto;
SELECT categoria_gasto_id, nombre_categoria, tipo_gasto, es_amortizable, frecuencia 
FROM DIM_CategoriaGasto;

-- DIM_Geografia
PRINT '4. DIM_Geografia:';
SELECT COUNT(*) AS 'Total registros en DIM_Geografia' FROM DIM_Geografia;
SELECT TOP 10 geografia_id, pais, ciudad, continente, region 
FROM DIM_Geografia 
ORDER BY pais, ciudad;

-- DIM_MetodoPago
PRINT '5. DIM_MetodoPago:';
SELECT COUNT(*) AS 'Total registros en DIM_MetodoPago' FROM DIM_MetodoPago;
SELECT metodo_pago_id, nombre_metodo, tipo_metodo, requiere_procesamiento, comision_porcentaje 
FROM DIM_MetodoPago;

-- DIM_Pelicula
PRINT '6. DIM_Pelicula:';
SELECT COUNT(*) AS 'Total registros en DIM_Pelicula' FROM DIM_Pelicula;
SELECT TOP 10 pelicula_id, titulo, anio_produccion, duracion, pais_origen, 
       nombre_director_principal, generos
FROM DIM_Pelicula;

-- DIM_Categoria
PRINT '7. DIM_Categoria:';
SELECT COUNT(*) AS 'Total registros en DIM_Categoria' FROM DIM_Categoria;
SELECT categoria_id, nombre_categoria, descripcion, tipo_categoria, edicion_anio 
FROM DIM_Categoria;

-- DIM_Sala
PRINT '8. DIM_Sala:';
SELECT COUNT(*) AS 'Total registros en DIM_Sala' FROM DIM_Sala;
SELECT sala_id, nombre_sala, ubicacion, capacidad, tipo_sala 
FROM DIM_Sala;

-- DIM_Persona
PRINT '9. DIM_Persona:';
SELECT COUNT(*) AS 'Total registros en DIM_Persona' FROM DIM_Persona;
SELECT TOP 10 persona_id, nombre_completo, nacionalidad, roles_principales 
FROM DIM_Persona;

-- DIM_Asistente
PRINT '10. DIM_Asistente:';
SELECT COUNT(*) AS 'Total registros en DIM_Asistente' FROM DIM_Asistente;
SELECT TOP 10 asistente_id, nombre_completo, tipo_asistente, pais, 
       tiene_acreditacion, tipo_acreditacion 
FROM DIM_Asistente;

-- DIM_Entrada
PRINT '11. DIM_Entrada:';
SELECT COUNT(*) AS 'Total registros en DIM_Entrada' FROM DIM_Entrada;
SELECT tipo_entrada_id, nombre, precio_base, es_abono 
FROM DIM_Entrada;

-- DIM_Evento
PRINT '12. DIM_Evento:';
SELECT COUNT(*) AS 'Total registros en DIM_Evento' FROM DIM_Evento;
SELECT TOP 10 evento_id, nombre_evento, tipo_evento, ubicacion, aforo_maximo 
FROM DIM_Evento;

-- DIM_Jurado
PRINT '13. DIM_Jurado:';
SELECT COUNT(*) AS 'Total registros en DIM_Jurado' FROM DIM_Jurado;
SELECT jurado_id, nombre_jurado, edicion_anio, categorias_evaluacion 
FROM DIM_Jurado;

-- DIM_Patrocinador
PRINT '14. DIM_Patrocinador:';
SELECT COUNT(*) AS 'Total registros en DIM_Patrocinador' FROM DIM_Patrocinador;
SELECT TOP 10 patrocinador_id, nombre, tipo, pais, sector_industria, es_recurrente 
FROM DIM_Patrocinador;

PRINT '===== VERIFICACIÓN DE TABLAS DE HECHOS =====';

-- FACT_Proyecciones
PRINT '1. FACT_Proyecciones:';
SELECT COUNT(*) AS 'Total registros en FACT_Proyecciones' FROM FACT_Proyecciones;
SELECT TOP 10 proyeccion_id, tiempo_id, pelicula_id, sala_id, edicion_id, 
       duracion_proyeccion, tiene_qa, entradas_vendidas, porcentaje_ocupacion, ingresos_totales
FROM FACT_Proyecciones;

-- FACT_Ventas_Entradas
PRINT '2. FACT_Ventas_Entradas:';
SELECT COUNT(*) AS 'Total registros en FACT_Ventas_Entradas' FROM FACT_Ventas_Entradas;
SELECT TOP 10 venta_id, tiempo_id, proyeccion_id, asistente_id, tipo_entrada_id, 
       metodo_pago_id, precio_final, fue_utilizada
FROM FACT_Ventas_Entradas;

-- FACT_Evaluaciones_Jurado
PRINT '3. FACT_Evaluaciones_Jurado:';
SELECT COUNT(*) AS 'Total registros en FACT_Evaluaciones_Jurado' FROM FACT_Evaluaciones_Jurado;
SELECT TOP 10 evaluacion_id, pelicula_id, jurado_id, persona_id, categoria_id,
       puntuacion, posicion_ranking
FROM FACT_Evaluaciones_Jurado;

-- FACT_Premios
PRINT '4. FACT_Premios:';
SELECT COUNT(*) AS 'Total registros en FACT_Premios' FROM FACT_Premios;
SELECT premio_id, pelicula_id, categoria_id, jurado_id, edicion_id,
       dotacion_economica, prestigio_premio, nombre_premio
FROM FACT_Premios;

-- FACT_Eventos_Paralelos
PRINT '5. FACT_Eventos_Paralelos:';
SELECT COUNT(*) AS 'Total registros en FACT_Eventos_Paralelos' FROM FACT_Eventos_Paralelos;
SELECT TOP 10 evento_id, tiempo_id, asistente_id, aforo_maximo, inscripciones_realizadas, asistencia_real
FROM FACT_Eventos_Paralelos;

-- FACT_Patrocinios
PRINT '6. FACT_Patrocinios:';
SELECT COUNT(*) AS 'Total registros en FACT_Patrocinios' FROM FACT_Patrocinios;
SELECT patrocinio_id, patrocinador_id, edicion_id, valor_monetario, valor_en_especie, 
       categoria_patrocinio, retorno_estimado
FROM FACT_Patrocinios;

-- FACT_Alojamientos
PRINT '7. FACT_Alojamientos:';
SELECT COUNT(*) AS 'Total registros en FACT_Alojamientos' FROM FACT_Alojamientos;
SELECT reserva_id, persona_id, edicion_id, tiempo_entrada_id, tiempo_salida_id,
       tipo_establecimiento, duracion_estancia, precio_total
FROM FACT_Alojamientos;

-- FACT_Traslados
PRINT '8. FACT_Traslados:';
SELECT COUNT(*) AS 'Total registros en FACT_Traslados' FROM FACT_Traslados;
SELECT TOP 10 traslado_id, persona_id, edicion_id, origen_id, destino_id, 
       tipo_transporte, costo, duracion_estimada
FROM FACT_Traslados;

-- FACT_Gastos_Festival
PRINT '9. FACT_Gastos_Festival:';
SELECT COUNT(*) AS 'Total registros en FACT_Gastos_Festival' FROM FACT_Gastos_Festival;
SELECT TOP 10 gasto_id, edicion_id, categoria_gasto_id, monto, proveedor, tiene_factura
FROM FACT_Gastos_Festival;

PRINT '===== VERIFICACIÓN DE RELACIONES ENTRE TABLAS =====';

-- Verificar proyecciones por película
PRINT 'Películas con más proyecciones:';
SELECT p.titulo, COUNT(fp.proyeccion_id) AS total_proyecciones
FROM DIM_Pelicula p
JOIN FACT_Proyecciones fp ON p.pelicula_id = fp.pelicula_id
GROUP BY p.titulo
ORDER BY total_proyecciones DESC;

-- Verificar recaudación por película
PRINT 'Películas con mayor recaudación:';
SELECT p.titulo, SUM(fp.ingresos_totales) AS recaudacion_total
FROM DIM_Pelicula p
JOIN FACT_Proyecciones fp ON p.pelicula_id = fp.pelicula_id
GROUP BY p.titulo
ORDER BY recaudacion_total DESC;

-- Verificar ocupación promedio por sala
PRINT 'Ocupación promedio por sala:';
SELECT s.nombre_sala, AVG(fp.porcentaje_ocupacion) AS ocupacion_promedio
FROM DIM_Sala s
JOIN FACT_Proyecciones fp ON s.sala_id = fp.sala_id
GROUP BY s.nombre_sala
ORDER BY ocupacion_promedio DESC;

-- Verificar gastos por categoría
PRINT 'Gastos por categoría:';
SELECT cg.nombre_categoria, SUM(fg.monto) AS total_gastos
FROM DIM_CategoriaGasto cg
JOIN FACT_Gastos_Festival fg ON cg.categoria_gasto_id = fg.categoria_gasto_id
GROUP BY cg.nombre_categoria
ORDER BY total_gastos DESC;

-- Verificar métodos de pago más utilizados
PRINT 'Métodos de pago más utilizados:';
SELECT mp.nombre_metodo, COUNT(fv.venta_id) AS total_ventas, SUM(fv.precio_final) AS importe_total
FROM DIM_MetodoPago mp
JOIN FACT_Ventas_Entradas fv ON mp.metodo_pago_id = fv.metodo_pago_id
GROUP BY mp.nombre_metodo
ORDER BY total_ventas DESC;

-- Verificar evaluaciones por jurado
PRINT 'Evaluaciones por jurado:';
SELECT j.nombre_jurado, COUNT(fe.evaluacion_id) AS total_evaluaciones, AVG(fe.puntuacion) AS puntuacion_media
FROM DIM_Jurado j
JOIN FACT_Evaluaciones_Jurado fe ON j.jurado_id = fe.jurado_id
GROUP BY j.nombre_jurado
ORDER BY total_evaluaciones DESC;

-- Verificar asistentes por país
PRINT 'Distribución de asistentes por país:';
SELECT g.pais, COUNT(DISTINCT a.asistente_id) AS total_asistentes
FROM DIM_Geografia g
JOIN FACT_Ventas_Entradas fv ON g.geografia_id = fv.geografia_id
JOIN DIM_Asistente a ON fv.asistente_id = a.asistente_id
GROUP BY g.pais
ORDER BY total_asistentes DESC;

PRINT 'Verificación completada.';
GO