USE Festival_Final_OLTP;
GO

-- PARTE 1: CONSULTAS SELECT PARA TODAS LAS TABLAS
PRINT '====== CONSULTAS SELECT ======';

-- Tablas principales
SELECT * FROM Persona;
SELECT * FROM Rol_Cinematografico;
SELECT * FROM Genero_Cinematografico;
SELECT * FROM Idioma;
SELECT * FROM Edicion_Festival;
SELECT * FROM Pelicula;
SELECT * FROM Sala;
SELECT * FROM Jurado;
SELECT * FROM Asistente;
SELECT * FROM Tipo_Entrada;
SELECT * FROM Patrocinador;
SELECT * FROM Alojamiento;

-- Tablas de relación y detalle
SELECT * FROM Pelicula_Persona_Rol;
SELECT * FROM Pelicula_Idioma;
SELECT * FROM Pelicula_Genero;
SELECT * FROM Proyeccion;
SELECT * FROM QA_Sesion;
SELECT * FROM QA_Participante;
SELECT * FROM Categoria_Competicion;
SELECT * FROM Pelicula_Categoria;
SELECT * FROM Jurado_Categoria;
SELECT * FROM Miembro_Jurado;
SELECT * FROM Evaluacion;
SELECT * FROM Premio;
SELECT * FROM Premio_Otorgado;
SELECT * FROM Abono;
SELECT * FROM Entrada;
SELECT * FROM Acreditacion;
SELECT * FROM Evento_Paralelo;
SELECT * FROM Inscripcion_Evento;
SELECT * FROM Patrocinio;
SELECT * FROM Reserva_Alojamiento;
SELECT * FROM Traslado;
SELECT * FROM Gasto_Festival;

-- PARTE 2: DROP TABLES EN ORDEN CORRECTO
PRINT '====== DROP TABLES ======';

-- Primero deshabilitamos todas las restricciones de clave foránea
PRINT 'Deshabilitando restricciones de clave foránea...';
EXEC sp_MSforeachtable "ALTER TABLE ? NOCHECK CONSTRAINT ALL";

-- 1. Primero tablas que dependen de múltiples tablas (nivel más bajo)
IF OBJECT_ID('Pelicula_Persona_Rol', 'U') IS NOT NULL DROP TABLE Pelicula_Persona_Rol;
IF OBJECT_ID('Pelicula_Idioma', 'U') IS NOT NULL DROP TABLE Pelicula_Idioma;
IF OBJECT_ID('Pelicula_Genero', 'U') IS NOT NULL DROP TABLE Pelicula_Genero;
IF OBJECT_ID('QA_Participante', 'U') IS NOT NULL DROP TABLE QA_Participante;
IF OBJECT_ID('Pelicula_Categoria', 'U') IS NOT NULL DROP TABLE Pelicula_Categoria;
IF OBJECT_ID('Jurado_Categoria', 'U') IS NOT NULL DROP TABLE Jurado_Categoria;
IF OBJECT_ID('Miembro_Jurado', 'U') IS NOT NULL DROP TABLE Miembro_Jurado;
IF OBJECT_ID('Premio_Otorgado', 'U') IS NOT NULL DROP TABLE Premio_Otorgado;
IF OBJECT_ID('Evaluacion', 'U') IS NOT NULL DROP TABLE Evaluacion;

-- 2. Tablas que dependen de pocas tablas (nivel medio)
IF OBJECT_ID('QA_Sesion', 'U') IS NOT NULL DROP TABLE QA_Sesion;
IF OBJECT_ID('Proyeccion', 'U') IS NOT NULL DROP TABLE Proyeccion;
IF OBJECT_ID('Entrada', 'U') IS NOT NULL DROP TABLE Entrada;
IF OBJECT_ID('Premio', 'U') IS NOT NULL DROP TABLE Premio;
IF OBJECT_ID('Abono', 'U') IS NOT NULL DROP TABLE Abono;
IF OBJECT_ID('Acreditacion', 'U') IS NOT NULL DROP TABLE Acreditacion;
IF OBJECT_ID('Inscripcion_Evento', 'U') IS NOT NULL DROP TABLE Inscripcion_Evento;
IF OBJECT_ID('Patrocinio', 'U') IS NOT NULL DROP TABLE Patrocinio;
IF OBJECT_ID('Reserva_Alojamiento', 'U') IS NOT NULL DROP TABLE Reserva_Alojamiento;
IF OBJECT_ID('Traslado', 'U') IS NOT NULL DROP TABLE Traslado;
IF OBJECT_ID('Gasto_Festival', 'U') IS NOT NULL DROP TABLE Gasto_Festival;

-- 3. Tablas base intermedias
IF OBJECT_ID('Categoria_Competicion', 'U') IS NOT NULL DROP TABLE Categoria_Competicion;
IF OBJECT_ID('Evento_Paralelo', 'U') IS NOT NULL DROP TABLE Evento_Paralelo;

-- 4. Tablas base/principales
IF OBJECT_ID('Pelicula', 'U') IS NOT NULL DROP TABLE Pelicula;
IF OBJECT_ID('Sala', 'U') IS NOT NULL DROP TABLE Sala;
IF OBJECT_ID('Jurado', 'U') IS NOT NULL DROP TABLE Jurado;
IF OBJECT_ID('Asistente', 'U') IS NOT NULL DROP TABLE Asistente;
IF OBJECT_ID('Tipo_Entrada', 'U') IS NOT NULL DROP TABLE Tipo_Entrada;
IF OBJECT_ID('Patrocinador', 'U') IS NOT NULL DROP TABLE Patrocinador;
IF OBJECT_ID('Alojamiento', 'U') IS NOT NULL DROP TABLE Alojamiento;
IF OBJECT_ID('Persona', 'U') IS NOT NULL DROP TABLE Persona;
IF OBJECT_ID('Rol_Cinematografico', 'U') IS NOT NULL DROP TABLE Rol_Cinematografico;
IF OBJECT_ID('Genero_Cinematografico', 'U') IS NOT NULL DROP TABLE Genero_Cinematografico;
IF OBJECT_ID('Idioma', 'U') IS NOT NULL DROP TABLE Idioma;
IF OBJECT_ID('Edicion_Festival', 'U') IS NOT NULL DROP TABLE Edicion_Festival;

PRINT 'Todas las tablas han sido eliminadas.';
GO