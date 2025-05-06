-- Diseño detallado del esquema OLAP
USE master;
GO

IF NOT EXISTS (SELECT name FROM master.dbo.sysdatabases WHERE name = 'Festival_Final_OLAP')
BEGIN
    CREATE DATABASE Festival_Final_OLAP;
    PRINT 'Database Festival_Final_OLAP created.';
END
ELSE
    PRINT 'Database Festival_Final_OLAP already exists.';
GO

USE Festival_Final_OLAP;
GO

-- Dimensiones

-- DIM_Tiempo
CREATE TABLE DIM_Tiempo (
    tiempo_id INT IDENTITY(1,1) PRIMARY KEY,
    fecha DATE NOT NULL,
    dia INT NOT NULL,
    dia_semana VARCHAR(15) NOT NULL,
    semana INT NOT NULL,
    mes INT NOT NULL,
    nombre_mes VARCHAR(15) NOT NULL,
    trimestre INT NOT NULL,
    anio INT NOT NULL,
    es_fin_semana BIT NOT NULL,
    es_festivo BIT NOT NULL,
    temporada_festival VARCHAR(20) CHECK (temporada_festival IN ('pre-festival', 'festival', 'post-festival'))
);

-- DIM_Pelicula
CREATE TABLE DIM_Pelicula (
    pelicula_id INT PRIMARY KEY,
    titulo VARCHAR(200) NOT NULL,
    anio_produccion INT NOT NULL,
    duracion INT NOT NULL,
    pais_origen VARCHAR(100) NOT NULL,
    clasificacion_edad VARCHAR(50),
    formato_proyeccion VARCHAR(50),
    nombre_director_principal VARCHAR(255),
    estado_seleccion VARCHAR(20) NOT NULL,
    generos VARCHAR(500),
    idioma_original VARCHAR(100),
    tiene_subtitulos_espanol BIT,
    tiene_subtitulos_ingles BIT
);

-- DIM_Categoria
CREATE TABLE DIM_Categoria (
    categoria_id INT PRIMARY KEY,
    nombre_categoria VARCHAR(150) NOT NULL,
    descripcion NVARCHAR(MAX),
    tipo_categoria VARCHAR(100),
    edicion_anio INT NOT NULL
);

-- DIM_Sala
CREATE TABLE DIM_Sala (
    sala_id INT PRIMARY KEY,
    nombre_sala VARCHAR(100) NOT NULL,
    ubicacion VARCHAR(200) NOT NULL,
    capacidad INT NOT NULL,
    tipo_sala VARCHAR(50),
    caracteristicas_tecnicas NVARCHAR(MAX)
);

-- DIM_Persona
CREATE TABLE DIM_Persona (
    persona_id INT PRIMARY KEY,
    nombre_completo VARCHAR(255) NOT NULL,
    email VARCHAR(150),
    nacionalidad VARCHAR(100),
    roles_principales VARCHAR(500), -- Roles como director, actor, etc.
    biografia NVARCHAR(MAX)
);

-- DIM_Asistente
CREATE TABLE DIM_Asistente (
    asistente_id INT PRIMARY KEY,
    nombre_completo VARCHAR(255) NOT NULL,
    email VARCHAR(150) NOT NULL,
    telefono VARCHAR(50),
    tipo_asistente VARCHAR(20) NOT NULL,
    pais VARCHAR(100),
    ciudad VARCHAR(100),
    tiene_acreditacion BIT,
    tipo_acreditacion VARCHAR(100)
);

-- DIM_Entrada
CREATE TABLE DIM_Entrada (
    tipo_entrada_id INT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    descripcion NVARCHAR(MAX),
    precio_base DECIMAL(8,2) NOT NULL,
    es_abono BIT,
    metodo_pago VARCHAR(50)
);

-- DIM_Evento
CREATE TABLE DIM_Evento (
    evento_id INT PRIMARY KEY,
    nombre_evento VARCHAR(200) NOT NULL,
    tipo_evento VARCHAR(100) NOT NULL,
    descripcion NVARCHAR(MAX),
    ubicacion VARCHAR(200),
    aforo_maximo INT,
    requiere_inscripcion BIT
);

-- DIM_Jurado
CREATE TABLE DIM_Jurado (
    jurado_id INT PRIMARY KEY,
    nombre_jurado VARCHAR(150) NOT NULL,
    edicion_anio INT NOT NULL,
    categorias_evaluacion VARCHAR(500),
    miembros VARCHAR(MAX)
);

-- DIM_Edicion
CREATE TABLE DIM_Edicion (
    edicion_id INT PRIMARY KEY,
    anio INT NOT NULL,
    tema VARCHAR(200),
    director_festival VARCHAR(200),
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NOT NULL,
    duracion_dias INT
);

-- DIM_Patrocinador (dimensión mejorada)
CREATE TABLE DIM_Patrocinador (
    patrocinador_id INT PRIMARY KEY,
    nombre VARCHAR(200) NOT NULL,
    contacto_principal VARCHAR(200),
    tipo VARCHAR(100) NOT NULL,
    pais VARCHAR(100),
    sector_industria VARCHAR(100),
    es_recurrente BIT,
    categorias_patrocinio VARCHAR(500)
);

-- DIM_MetodoPago (nueva dimensión)
CREATE TABLE DIM_MetodoPago (
    metodo_pago_id INT IDENTITY(1,1) PRIMARY KEY,
    nombre_metodo VARCHAR(50) NOT NULL,
    tipo_metodo VARCHAR(20) NOT NULL, -- efectivo, tarjeta, electrónico
    requiere_procesamiento BIT,
    comision_porcentaje DECIMAL(5,2)
);

-- DIM_Geografia (nueva dimensión)
CREATE TABLE DIM_Geografia (
    geografia_id INT IDENTITY(1,1) PRIMARY KEY,
    pais VARCHAR(100) NOT NULL,
    ciudad VARCHAR(100),
    continente VARCHAR(50),
    region VARCHAR(100)
);

-- DIM_CategoriaGasto (nueva dimensión)
CREATE TABLE DIM_CategoriaGasto (
    categoria_gasto_id INT IDENTITY(1,1) PRIMARY KEY,
    nombre_categoria VARCHAR(100) NOT NULL,
    tipo_gasto VARCHAR(50) NOT NULL, -- operativo, técnico, logístico, promocional
    es_amortizable BIT,
    frecuencia VARCHAR(50) -- recurrente, único, anual
);

-- Tablas de Hechos

-- FACT_Proyecciones
CREATE TABLE FACT_Proyecciones (
    proyeccion_id INT PRIMARY KEY,
    tiempo_id INT REFERENCES DIM_Tiempo(tiempo_id),
    pelicula_id INT REFERENCES DIM_Pelicula(pelicula_id),
    sala_id INT REFERENCES DIM_Sala(sala_id),
    edicion_id INT REFERENCES DIM_Edicion(edicion_id),
    duracion_proyeccion INT,
    tiene_qa BIT,
    aforo_total INT,
    entradas_vendidas INT,
    porcentaje_ocupacion DECIMAL(5,2),
    ingresos_totales DECIMAL(10,2)
);

-- FACT_Ventas_Entradas
CREATE TABLE FACT_Ventas_Entradas (
    venta_id INT IDENTITY(1,1) PRIMARY KEY,
    tiempo_id INT REFERENCES DIM_Tiempo(tiempo_id),
    proyeccion_id INT,
    asistente_id INT REFERENCES DIM_Asistente(asistente_id),
    tipo_entrada_id INT REFERENCES DIM_Entrada(tipo_entrada_id),
    edicion_id INT REFERENCES DIM_Edicion(edicion_id),
    metodo_pago_id INT REFERENCES DIM_MetodoPago(metodo_pago_id), -- Nueva referencia
    precio_final DECIMAL(8,2) NOT NULL,
    abono_id INT, -- Referencia al abono si se usó uno
    fue_utilizada BIT,
    tiempo_compra_anticipada INT, -- En días
    geografia_id INT REFERENCES DIM_Geografia(geografia_id) -- Nueva referencia para origen de compra
);

-- FACT_Evaluaciones_Jurado
CREATE TABLE FACT_Evaluaciones_Jurado (
    evaluacion_id INT PRIMARY KEY,
    pelicula_id INT REFERENCES DIM_Pelicula(pelicula_id),
    jurado_id INT REFERENCES DIM_Jurado(jurado_id),
    persona_id INT REFERENCES DIM_Persona(persona_id),
    categoria_id INT REFERENCES DIM_Categoria(categoria_id),
    edicion_id INT REFERENCES DIM_Edicion(edicion_id),
    tiempo_id INT REFERENCES DIM_Tiempo(tiempo_id),
    puntuacion DECIMAL(4,2) NOT NULL,
    posicion_ranking INT,
    comentarios NVARCHAR(MAX)
);

-- FACT_Premios
CREATE TABLE FACT_Premios (
    premio_id INT PRIMARY KEY,
    pelicula_id INT REFERENCES DIM_Pelicula(pelicula_id),
    categoria_id INT REFERENCES DIM_Categoria(categoria_id),
    jurado_id INT REFERENCES DIM_Jurado(jurado_id),
    edicion_id INT REFERENCES DIM_Edicion(edicion_id),
    tiempo_id INT REFERENCES DIM_Tiempo(tiempo_id),
    dotacion_economica DECIMAL(10,2),
    prestigio_premio VARCHAR(20) CHECK (prestigio_premio IN ('alto', 'medio', 'bajo')),
    nombre_premio VARCHAR(200)
);

-- FACT_Eventos_Paralelos
CREATE TABLE FACT_Eventos_Paralelos (
    evento_participacion_id INT IDENTITY(1,1) PRIMARY KEY,
    evento_id INT REFERENCES DIM_Evento(evento_id),
    tiempo_id INT REFERENCES DIM_Tiempo(tiempo_id),
    persona_id INT REFERENCES DIM_Persona(persona_id), -- Para ponentes/presentadores
    asistente_id INT REFERENCES DIM_Asistente(asistente_id), -- Para asistentes
    edicion_id INT REFERENCES DIM_Edicion(edicion_id),
    aforo_maximo INT,
    inscripciones_realizadas INT,
    asistencia_real INT,
    valoracion_promedio DECIMAL(3,2)
);

-- FACT_Patrocinios (actualizada)
CREATE TABLE FACT_Patrocinios (
    patrocinio_id INT PRIMARY KEY,
    patrocinador_id INT REFERENCES DIM_Patrocinador(patrocinador_id),
    edicion_id INT REFERENCES DIM_Edicion(edicion_id),
    tiempo_id INT REFERENCES DIM_Tiempo(tiempo_id),
    valor_monetario DECIMAL(10,2),
    valor_en_especie DECIMAL(10,2),
    categoria_patrocinio VARCHAR(100),
    retorno_estimado DECIMAL(10,2),
    tipo_aportacion VARCHAR(100), -- económica, material, servicios
    geografia_id INT REFERENCES DIM_Geografia(geografia_id) -- Para análisis regional
);

-- FACT_Alojamientos (nueva tabla de hechos)
CREATE TABLE FACT_Alojamientos (
    reserva_id INT PRIMARY KEY,
    persona_id INT REFERENCES DIM_Persona(persona_id),
    edicion_id INT REFERENCES DIM_Edicion(edicion_id),
    tiempo_entrada_id INT REFERENCES DIM_Tiempo(tiempo_id),
    tiempo_salida_id INT REFERENCES DIM_Tiempo(tiempo_id),
    tipo_establecimiento VARCHAR(50),
    categoria_establecimiento VARCHAR(50),
    duracion_estancia INT, -- En días
    precio_total DECIMAL(10,2),
    precio_por_noche DECIMAL(10,2),
    ubicacion_id INT REFERENCES DIM_Geografia(geografia_id)
);

-- FACT_Traslados (nueva tabla de hechos)
CREATE TABLE FACT_Traslados (
    traslado_id INT PRIMARY KEY,
    persona_id INT REFERENCES DIM_Persona(persona_id),
    edicion_id INT REFERENCES DIM_Edicion(edicion_id),
    tiempo_id INT REFERENCES DIM_Tiempo(tiempo_id),
    origen_id INT REFERENCES DIM_Geografia(geografia_id),
    destino_id INT REFERENCES DIM_Geografia(geografia_id),
    tipo_transporte VARCHAR(100),
    costo DECIMAL(10,2),
    duracion_estimada INT, -- En minutos
    es_traslado_oficial BIT
);

-- FACT_Gastos_Festival (nueva tabla de hechos)
CREATE TABLE FACT_Gastos_Festival (
    gasto_id INT PRIMARY KEY,
    edicion_id INT REFERENCES DIM_Edicion(edicion_id),
    tiempo_id INT REFERENCES DIM_Tiempo(tiempo_id),
    categoria_gasto_id INT REFERENCES DIM_CategoriaGasto(categoria_gasto_id),
    monto DECIMAL(10,2) NOT NULL,
    proveedor VARCHAR(200),
    tiene_factura BIT,
    geografia_id INT REFERENCES DIM_Geografia(geografia_id), -- Ubicación del gasto
    es_recurrente BIT,
    es_presupuestado BIT
);