CREATE DATABASE OLAP_Claude;
GO

USE OLAP_Claude;
GO

/*===========================================
  =====           DIMENSIONES           =====
  ===========================================*/
CREATE TABLE DIM_Tiempo (
    tiempo_id INT PRIMARY KEY,
    fecha DATE,
    dia INT,
    dia_semana VARCHAR(20),
    semana INT,
    mes INT,
    trimestre INT,
    año INT,
    es_fin_semana BIT,
    es_festivo BIT,
    temporada_festival VARCHAR(20)
);

CREATE TABLE DIM_Pelicula (
    pelicula_id INT PRIMARY KEY,
    titulo VARCHAR(200),
    año_produccion INT,
    duracion INT,
    pais_origen VARCHAR(100),
    clasificacion_edad VARCHAR(50),
    formato_proyeccion VARCHAR(50),
    nombre_director_principal VARCHAR(200)
);

CREATE TABLE DIM_Categoria (
    categoria_id INT PRIMARY KEY,
    nombre_categoria VARCHAR(150),
    descripcion NVARCHAR(MAX),
    tipo_categoria VARCHAR(100)
);

CREATE TABLE DIM_Sala (
    sala_id INT PRIMARY KEY,
    nombre_sala VARCHAR(100),
    ubicacion VARCHAR(200),
    capacidad INT,
    tipo_sala VARCHAR(100)
);

CREATE TABLE DIM_Persona (
    persona_id INT PRIMARY KEY,
    nombre_completo VARCHAR(200),
    pais_origen VARCHAR(100),
    tipo_persona VARCHAR(100)
);

CREATE TABLE DIM_Asistente (
    asistente_id INT PRIMARY KEY,
    tipo_asistente VARCHAR(100),
    rango_edad VARCHAR(50),
    genero VARCHAR(20),
    procedencia_geografica VARCHAR(100)
);

CREATE TABLE DIM_Entrada (
    entrada_id INT PRIMARY KEY,
    tipo_entrada VARCHAR(100),
    canal_venta VARCHAR(100),
    precio_base DECIMAL(8,2),
    descuento_aplicado DECIMAL(8,2)
);

CREATE TABLE DIM_Evento (
    evento_id INT PRIMARY KEY,
    nombre_evento VARCHAR(200),
    tipo_evento VARCHAR(100),
    requiere_inscripcion BIT
);

CREATE TABLE DIM_Jurado (
    jurado_id INT PRIMARY KEY,
    nombre_jurado VARCHAR(150),
    categoria_evaluacion VARCHAR(100),
    numero_miembros INT
);

CREATE TABLE DIM_Edicion (
    edicion_id INT PRIMARY KEY,
    año_edicion INT,
    tema VARCHAR(200),
    director_festival VARCHAR(200),
    fechas VARCHAR(100)
);

CREATE TABLE DIM_Patrocinador (
    patrocinador_id INT PRIMARY KEY,
    nombre NVARCHAR(200) NOT NULL,
    tipo NVARCHAR(100) NOT NULL,
    contacto_principal NVARCHAR(200),
    telefono NVARCHAR(50),
    email NVARCHAR(150) NOT NULL,
    sector_industria NVARCHAR(100),
    pais_origen NVARCHAR(100)
);

/*===========================================
  =====             HECHOS              =====
  ===========================================*/
CREATE TABLE FACT_Proyecciones (
    proyeccion_id INT PRIMARY KEY,
    tiempo_id INT,
    pelicula_id INT,
    sala_id INT,
    edicion_id INT,
    duracion_proyeccion INT,
    tiene_qa BIT,
    aforo_total INT,
    entradas_vendidas INT,
    porcentaje_ocupacion DECIMAL(5,2),
    ingresos_totales DECIMAL(10,2),
    FOREIGN KEY (tiempo_id) REFERENCES DIM_Tiempo(tiempo_id),
    FOREIGN KEY (pelicula_id) REFERENCES DIM_Pelicula(pelicula_id),
    FOREIGN KEY (sala_id) REFERENCES DIM_Sala(sala_id),
    FOREIGN KEY (edicion_id) REFERENCES DIM_Edicion(edicion_id)
);

CREATE TABLE FACT_Ventas_Entradas (
    venta_id INT PRIMARY KEY,
    tiempo_id INT,
    proyeccion_id INT,
    asistente_id INT,
    entrada_id INT,
    edicion_id INT,
    precio_final DECIMAL(8,2),
    canal_venta VARCHAR(100),
    fue_utilizada BIT,
    tiempo_compra_anticipada INT,
    FOREIGN KEY (tiempo_id) REFERENCES DIM_Tiempo(tiempo_id),
    FOREIGN KEY (proyeccion_id) REFERENCES FACT_Proyecciones(proyeccion_id),
    FOREIGN KEY (asistente_id) REFERENCES DIM_Asistente(asistente_id),
    FOREIGN KEY (entrada_id) REFERENCES DIM_Entrada(entrada_id),
    FOREIGN KEY (edicion_id) REFERENCES DIM_Edicion(edicion_id)
);

CREATE TABLE FACT_Evaluaciones_Jurado (
    evaluacion_id INT PRIMARY KEY,
    pelicula_id INT,
    jurado_id INT,
    persona_id INT,
    categoria_id INT,
    edicion_id INT,
    tiempo_id INT,
    puntuacion DECIMAL(4,2),
    posicion_ranking INT,
    FOREIGN KEY (pelicula_id) REFERENCES DIM_Pelicula(pelicula_id),
    FOREIGN KEY (jurado_id) REFERENCES DIM_Jurado(jurado_id),
    FOREIGN KEY (persona_id) REFERENCES DIM_Persona(persona_id),
    FOREIGN KEY (categoria_id) REFERENCES DIM_Categoria(categoria_id),
    FOREIGN KEY (edicion_id) REFERENCES DIM_Edicion(edicion_id),
    FOREIGN KEY (tiempo_id) REFERENCES DIM_Tiempo(tiempo_id)
);

CREATE TABLE FACT_Premios (
    premio_id INT PRIMARY KEY,
    pelicula_id INT,
    categoria_id INT,
    jurado_id INT,
    edicion_id INT,
    tiempo_id INT,
    dotacion_economica DECIMAL(10,2),
    prestigio_premio VARCHAR(20),
    FOREIGN KEY (pelicula_id) REFERENCES DIM_Pelicula(pelicula_id),
    FOREIGN KEY (categoria_id) REFERENCES DIM_Categoria(categoria_id),
    FOREIGN KEY (jurado_id) REFERENCES DIM_Jurado(jurado_id),
    FOREIGN KEY (edicion_id) REFERENCES DIM_Edicion(edicion_id),
    FOREIGN KEY (tiempo_id) REFERENCES DIM_Tiempo(tiempo_id)
);

CREATE TABLE FACT_Eventos_Paralelos (
    evento_participacion_id INT PRIMARY KEY,
    evento_id INT,
    tiempo_id INT,
    persona_id INT,
    asistente_id INT,
    edicion_id INT,
    aforo_maximo INT,
    inscripciones_realizadas INT,
    asistencia_real INT,
    valoracion_promedio DECIMAL(4,2),
    FOREIGN KEY (evento_id) REFERENCES DIM_Evento(evento_id),
    FOREIGN KEY (tiempo_id) REFERENCES DIM_Tiempo(tiempo_id),
    FOREIGN KEY (persona_id) REFERENCES DIM_Persona(persona_id),
    FOREIGN KEY (asistente_id) REFERENCES DIM_Asistente(asistente_id),
    FOREIGN KEY (edicion_id) REFERENCES DIM_Edicion(edicion_id)
);

CREATE TABLE FACT_Patrocinios (
    patrocinio_id INT PRIMARY KEY,
    patrocinador_id INT,
    edicion_id INT,
    tiempo_id INT,
    valor_monetario DECIMAL(10,2),
    valor_en_especie DECIMAL(10,2),
    categoria_patrocinio VARCHAR(100),
    retorno_estimado DECIMAL(10,2),
    FOREIGN KEY (patrocinador_id) REFERENCES DIM_Patrocinador(patrocinador_id),
    FOREIGN KEY (edicion_id) REFERENCES DIM_Edicion(edicion_id),
    FOREIGN KEY (tiempo_id) REFERENCES DIM_Tiempo(tiempo_id)
);
