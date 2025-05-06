-- ======================================================
-- create_festival_OLTP.sql
-- ======================================================

IF NOT EXISTS (SELECT name FROM master.dbo.sysdatabases WHERE name = 'Festival_Final_OLTP')
BEGIN
    CREATE DATABASE Festival_Final_OLTP;
    PRINT 'Database Festival_Final_OLTP created.';
END
ELSE
    PRINT 'Database Festival_Final_OLTP already exists.';
GO

USE Festival_Final_OLTP;
GO

BEGIN TRY
    BEGIN TRANSACTION;

    --------------------------------------------------------------------------------
    -- 1) Tablas independientes
    --------------------------------------------------------------------------------

    IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Persona')
    CREATE TABLE Persona (
        persona_id   INT IDENTITY(1,1) PRIMARY KEY,
        nombre       VARCHAR(100) NOT NULL,
        apellidos    VARCHAR(150) NOT NULL,
        email        VARCHAR(150) UNIQUE,
        telefono     VARCHAR(50),
        biografia    TEXT,
        nacionalidad VARCHAR(100)
    );

    IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Rol_Cinematografico')
    CREATE TABLE Rol_Cinematografico (
        rol_id INT IDENTITY(1,1) PRIMARY KEY,
        nombre VARCHAR(100) NOT NULL UNIQUE
    );

    IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Genero_Cinematografico')
    CREATE TABLE Genero_Cinematografico (
        genero_id   INT IDENTITY(1,1) PRIMARY KEY,
        nombre      VARCHAR(100) NOT NULL UNIQUE,
        descripcion TEXT
    );

    IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Idioma')
    CREATE TABLE Idioma (
        idioma_id  INT IDENTITY(1,1) PRIMARY KEY,
        nombre     VARCHAR(100) NOT NULL UNIQUE,
        codigo_iso CHAR(2)     NOT NULL UNIQUE
    );

    IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Edicion_Festival')
    CREATE TABLE Edicion_Festival (
        edicion_id        INT IDENTITY(1,1) PRIMARY KEY,
        anio              INT NOT NULL UNIQUE,
        fecha_inicio      DATE NOT NULL,
        fecha_fin         DATE NOT NULL,
        tema              VARCHAR(200),
        director_festival VARCHAR(200)
    );

    IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Sala')
    CREATE TABLE Sala (
        sala_id               INT IDENTITY(1,1) PRIMARY KEY,
        nombre                VARCHAR(100) NOT NULL,
        ubicacion             VARCHAR(200) NOT NULL,
        capacidad             INT NOT NULL,
        caracteristicas_tecnicas TEXT
    );

    IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Asistente')
    CREATE TABLE Asistente (
        asistente_id   INT IDENTITY(1,1) PRIMARY KEY,
        nombre         VARCHAR(100) NOT NULL,
        apellidos      VARCHAR(150) NOT NULL,
        email          VARCHAR(150) NOT NULL UNIQUE,
        telefono       VARCHAR(50),
        tipo_asistente VARCHAR(20) NOT NULL
            CHECK (tipo_asistente IN ('publico','prensa','industria','VIP')),
        pais           VARCHAR(100),
        ciudad         VARCHAR(100)
    );

    IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Tipo_Entrada')
    CREATE TABLE Tipo_Entrada (
        tipo_entrada_id INT IDENTITY(1,1) PRIMARY KEY,
        nombre          VARCHAR(100) NOT NULL UNIQUE,
        descripcion     TEXT,
        precio_base     DECIMAL(8,2) NOT NULL
    );

    IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Evento_Paralelo')
    CREATE TABLE Evento_Paralelo (
        evento_id      INT IDENTITY(1,1) PRIMARY KEY,
        nombre         VARCHAR(200) NOT NULL,
        tipo           VARCHAR(100) NOT NULL,
        descripcion    TEXT,
        fecha          DATE NOT NULL,
        hora_inicio    TIME NOT NULL,
        hora_fin       TIME NOT NULL,
        ubicacion      VARCHAR(200) NOT NULL,
        aforo_maximo   INT NOT NULL,
        requiere_inscripcion BIT DEFAULT 0
    );

    IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Patrocinador')
    CREATE TABLE Patrocinador (
        patrocinador_id    INT IDENTITY(1,1) PRIMARY KEY,
        nombre             VARCHAR(200) NOT NULL,
        contacto_principal VARCHAR(200),
        telefono           VARCHAR(50),
        email              VARCHAR(150) NOT NULL,
        tipo               VARCHAR(100) NOT NULL,
        pais               VARCHAR(100),
        sector_industria   VARCHAR(100)
    );

    IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Alojamiento')
    CREATE TABLE Alojamiento (
        alojamiento_id         INT IDENTITY(1,1) PRIMARY KEY,
        nombre_establecimiento VARCHAR(200) NOT NULL,
        direccion              VARCHAR(250) NOT NULL,
        telefono               VARCHAR(50) NOT NULL,
        categoria              VARCHAR(50)
    );

    --------------------------------------------------------------------------------
    -- 2) Nueva tabla de dimensión País
    --------------------------------------------------------------------------------

    IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Pais')
    CREATE TABLE Pais (
        pais_id INT IDENTITY(1,1) PRIMARY KEY,
        nombre  VARCHAR(100) NOT NULL UNIQUE
    );

    --------------------------------------------------------------------------------
    -- 3) Pelicula refactorizada para usar FK a Pais
    --------------------------------------------------------------------------------

    IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Pelicula')
        DROP TABLE Pelicula;

    CREATE TABLE Pelicula (
        pelicula_id        INT IDENTITY(1,1) PRIMARY KEY,
        titulo             VARCHAR(200) NOT NULL,
        anio               INT NOT NULL,
        duracion           INT NOT NULL,
        pais_origen_id     INT NOT NULL,
        sinopsis           TEXT,
        clasificacion_edad VARCHAR(50),
        formato_proyeccion VARCHAR(50),
        estado_seleccion   VARCHAR(20) NOT NULL
            CHECK (estado_seleccion IN ('postulada','seleccionada','rechazada','premiada')),
        CONSTRAINT FK_Pelicula_Pais
          FOREIGN KEY(pais_origen_id) REFERENCES Pais(pais_id)
    );

    --------------------------------------------------------------------------------
    -- 4) Tablas dependientes
    --------------------------------------------------------------------------------

    IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Pelicula_Persona_Rol')
    CREATE TABLE Pelicula_Persona_Rol (
        pelicula_id     INT NOT NULL,
        persona_id      INT NOT NULL,
        rol_id          INT NOT NULL,
        descripcion_rol VARCHAR(200),
        PRIMARY KEY(pelicula_id,persona_id,rol_id),
        FOREIGN KEY(pelicula_id) REFERENCES Pelicula(pelicula_id),
        FOREIGN KEY(persona_id)  REFERENCES Persona(persona_id),
        FOREIGN KEY(rol_id)      REFERENCES Rol_Cinematografico(rol_id)
    );

    IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Pelicula_Idioma')
    CREATE TABLE Pelicula_Idioma (
        pelicula_id INT NOT NULL,
        idioma_id   INT NOT NULL,
        tipo        VARCHAR(10) NOT NULL CHECK(tipo IN ('original','subtitulos','doblaje')),
        PRIMARY KEY(pelicula_id,idioma_id,tipo),
        FOREIGN KEY(pelicula_id) REFERENCES Pelicula(pelicula_id),
        FOREIGN KEY(idioma_id)   REFERENCES Idioma(idioma_id)
    );

    IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Pelicula_Genero')
    CREATE TABLE Pelicula_Genero (
        pelicula_id INT NOT NULL,
        genero_id   INT NOT NULL,
        PRIMARY KEY(pelicula_id,genero_id),
        FOREIGN KEY(pelicula_id) REFERENCES Pelicula(pelicula_id),
        FOREIGN KEY(genero_id)   REFERENCES Genero_Cinematografico(genero_id)
    );

    IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Proyeccion')
    CREATE TABLE Proyeccion (
        proyeccion_id INT IDENTITY(1,1) PRIMARY KEY,
        pelicula_id   INT NOT NULL,
        sala_id       INT NOT NULL,
        fecha         DATE NOT NULL,
        hora_inicio   TIME NOT NULL,
        hora_fin      TIME NOT NULL,
        sesion_qa     BIT DEFAULT 0,
        FOREIGN KEY(pelicula_id) REFERENCES Pelicula(pelicula_id),
        FOREIGN KEY(sala_id)      REFERENCES Sala(sala_id)
    );

    IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'QA_Sesion')
    CREATE TABLE QA_Sesion (
        qa_id         INT IDENTITY(1,1) PRIMARY KEY,
        proyeccion_id INT NOT NULL,
        descripcion   TEXT,
        moderador     VARCHAR(200),
        FOREIGN KEY(proyeccion_id) REFERENCES Proyeccion(proyeccion_id)
    );

    IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'QA_Participante')
    CREATE TABLE QA_Participante (
        qa_id      INT NOT NULL,
        persona_id INT NOT NULL,
        PRIMARY KEY(qa_id,persona_id),
        FOREIGN KEY(qa_id)      REFERENCES QA_Sesion(qa_id),
        FOREIGN KEY(persona_id) REFERENCES Persona(persona_id)
    );

    IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Categoria_Competicion')
    CREATE TABLE Categoria_Competicion (
        categoria_id     INT IDENTITY(1,1) PRIMARY KEY,
        nombre           VARCHAR(150) NOT NULL,
        descripcion      TEXT,
        edicion_festival INT NOT NULL,
        FOREIGN KEY(edicion_festival) REFERENCES Edicion_Festival(edicion_id)
    );

    IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Pelicula_Categoria')
    CREATE TABLE Pelicula_Categoria (
        pelicula_id INT NOT NULL,
        categoria_id INT NOT NULL,
        PRIMARY KEY(pelicula_id,categoria_id),
        FOREIGN KEY(pelicula_id)   REFERENCES Pelicula(pelicula_id),
        FOREIGN KEY(categoria_id) REFERENCES Categoria_Competicion(categoria_id)
    );

    IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Jurado')
    CREATE TABLE Jurado (
        jurado_id        INT IDENTITY(1,1) PRIMARY KEY,
        nombre           VARCHAR(150) NOT NULL,
        edicion_festival INT NOT NULL,
        FOREIGN KEY(edicion_festival) REFERENCES Edicion_Festival(edicion_id)
    );

    IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Jurado_Categoria')
    CREATE TABLE Jurado_Categoria (
        jurado_id    INT NOT NULL,
        categoria_id INT NOT NULL,
        PRIMARY KEY(jurado_id,categoria_id),
        FOREIGN KEY(jurado_id)    REFERENCES Jurado(jurado_id),
        FOREIGN KEY(categoria_id) REFERENCES Categoria_Competicion(categoria_id)
    );

    IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Miembro_Jurado')
    CREATE TABLE Miembro_Jurado (
        jurado_id  INT NOT NULL,
        persona_id INT NOT NULL,
        cargo      VARCHAR(100),
        PRIMARY KEY(jurado_id,persona_id),
        FOREIGN KEY(jurado_id)  REFERENCES Jurado(jurado_id),
        FOREIGN KEY(persona_id) REFERENCES Persona(persona_id)
    );

    IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Evaluacion')
    CREATE TABLE Evaluacion (
        evaluacion_id    INT IDENTITY(1,1) PRIMARY KEY,
        pelicula_id      INT NOT NULL,
        jurado_id        INT NOT NULL,
        persona_id       INT NOT NULL,
        puntuacion       DECIMAL(4,2) NOT NULL,
        comentarios      TEXT,
        fecha_evaluacion DATETIME NOT NULL,
        FOREIGN KEY(pelicula_id) REFERENCES Pelicula(pelicula_id),
        FOREIGN KEY(jurado_id)    REFERENCES Jurado(jurado_id),
        FOREIGN KEY(persona_id)   REFERENCES Persona(persona_id)
    );

    IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Premio')
    CREATE TABLE Premio (
        premio_id    INT IDENTITY(1,1) PRIMARY KEY,
        nombre       VARCHAR(200) NOT NULL,
        categoria_id INT NOT NULL,
        dotacion     DECIMAL(10,2),
        descripcion  TEXT,
        FOREIGN KEY(categoria_id) REFERENCES Categoria_Competicion(categoria_id)
    );

    IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Premio_Otorgado')
    CREATE TABLE Premio_Otorgado (
        premio_otorgado_id INT IDENTITY(1,1) PRIMARY KEY,
        premio_id          INT NOT NULL,
        pelicula_id        INT NOT NULL,
        edicion_festival   INT NOT NULL,
        fecha_otorgamiento DATE NOT NULL,
        FOREIGN KEY(premio_id)        REFERENCES Premio(premio_id),
        FOREIGN KEY(pelicula_id)      REFERENCES Pelicula(pelicula_id),
        FOREIGN KEY(edicion_festival) REFERENCES Edicion_Festival(edicion_id)
    );

    IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Abono')
    CREATE TABLE Abono (
        abono_id            INT IDENTITY(1,1) PRIMARY KEY,
        tipo_abono          VARCHAR(100) NOT NULL,
        precio              DECIMAL(8,2) NOT NULL,
        fecha_inicio_validez DATE NOT NULL,
        fecha_fin_validez   DATE NOT NULL,
        asistente_id        INT NOT NULL,
        FOREIGN KEY(asistente_id) REFERENCES Asistente(asistente_id)
    );

    IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Entrada')
    CREATE TABLE Entrada (
        entrada_id      INT IDENTITY(1,1) PRIMARY KEY,
        proyeccion_id   INT NOT NULL,
        tipo_entrada_id INT NOT NULL,
        precio_final    DECIMAL(8,2) NOT NULL,
        fecha_venta     DATETIME NOT NULL,
        asistente_id    INT,
        abono_id        INT,
        usado           BIT DEFAULT 0,
        metodo_pago     VARCHAR(50),
        FOREIGN KEY(proyeccion_id)   REFERENCES Proyeccion(proyeccion_id),
        FOREIGN KEY(tipo_entrada_id) REFERENCES Tipo_Entrada(tipo_entrada_id),
        FOREIGN KEY(asistente_id)    REFERENCES Asistente(asistente_id),
        FOREIGN KEY(abono_id)        REFERENCES Abono(abono_id)
    );

    IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Acreditacion')
    CREATE TABLE Acreditacion (
        acreditacion_id INT IDENTITY(1,1) PRIMARY KEY,
        asistente_id    INT NOT NULL,
        tipo_acreditacion VARCHAR(100) NOT NULL,
        fecha_emision   DATE NOT NULL,
        fecha_validez   DATE NOT NULL,
        FOREIGN KEY(asistente_id) REFERENCES Asistente(asistente_id)
    );

    IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Inscripcion_Evento')
    CREATE TABLE Inscripcion_Evento (
        inscripcion_id    INT IDENTITY(1,1) PRIMARY KEY,
        evento_id         INT NOT NULL,
        asistente_id      INT NOT NULL,
        fecha_inscripcion DATETIME NOT NULL,
        asistio           BIT DEFAULT 0,
        FOREIGN KEY(evento_id)    REFERENCES Evento_Paralelo(evento_id),
        FOREIGN KEY(asistente_id) REFERENCES Asistente(asistente_id)
    );

    IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Patrocinio')
    CREATE TABLE Patrocinio (
        patrocinio_id     INT IDENTITY(1,1) PRIMARY KEY,
        patrocinador_id   INT NOT NULL,
        edicion_festival  INT NOT NULL,
        tipo_aportacion   VARCHAR(100) NOT NULL,
        valor_monetario   DECIMAL(10,2),
        descripcion_aportacion TEXT,
        FOREIGN KEY(patrocinador_id)  REFERENCES Patrocinador(patrocinador_id),
        FOREIGN KEY(edicion_festival) REFERENCES Edicion_Festival(edicion_id)
    );

    IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Reserva_Alojamiento')
    CREATE TABLE Reserva_Alojamiento (
        reserva_id      INT IDENTITY(1,1) PRIMARY KEY,
        alojamiento_id  INT NOT NULL,
        persona_id      INT NOT NULL,
        fecha_entrada   DATE NOT NULL,
        fecha_salida    DATE NOT NULL,
        tipo_habitacion VARCHAR(100),
        observaciones   TEXT,
        precio          DECIMAL(10,2) NOT NULL,
        FOREIGN KEY(alojamiento_id) REFERENCES Alojamiento(alojamiento_id),
        FOREIGN KEY(persona_id)     REFERENCES Persona(persona_id)
    );

    IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Traslado')
    CREATE TABLE Traslado (
        traslado_id     INT IDENTITY(1,1) PRIMARY KEY,
        persona_id      INT NOT NULL,
        origen          VARCHAR(200) NOT NULL,
        destino         VARCHAR(200) NOT NULL,
        fecha           DATE NOT NULL,
        hora            TIME NOT NULL,
        tipo_transporte VARCHAR(100) NOT NULL,
        observaciones   TEXT,
        costo           DECIMAL(10,2),
        FOREIGN KEY(persona_id) REFERENCES Persona(persona_id)
    );

    IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Gasto_Festival')
    CREATE TABLE Gasto_Festival (
        gasto_id         INT IDENTITY(1,1) PRIMARY KEY,
        edicion_festival INT NOT NULL,
        categoria_gasto  VARCHAR(100) NOT NULL,
        descripcion      TEXT,
        monto            DECIMAL(10,2) NOT NULL,
        fecha_gasto      DATE NOT NULL,
        proveedor        VARCHAR(200),
        numero_factura   VARCHAR(100),
        FOREIGN KEY(edicion_festival) REFERENCES Edicion_Festival(edicion_id)
    );

    COMMIT TRANSACTION;
    PRINT 'All tables successfully checked/created.';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;
    PRINT 'Error occurred: ' + ERROR_MESSAGE();
END CATCH;
GO
