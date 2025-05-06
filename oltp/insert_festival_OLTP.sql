USE Festival_Final_OLTP;
GO

BEGIN TRY
    BEGIN TRANSACTION;
    
    PRINT 'Starting data insertion...';
    
    -- Clear existing data if needed (uncomment if required)
    /*
    DELETE FROM Traslado;
    DELETE FROM Reserva_Alojamiento;
    DELETE FROM Patrocinio;
    DELETE FROM Inscripcion_Evento;
    DELETE FROM Acreditacion;
    DELETE FROM Entrada;
    DELETE FROM Abono;
    DELETE FROM Premio_Otorgado;
    DELETE FROM Premio;
    DELETE FROM Evaluacion;
    DELETE FROM Miembro_Jurado;
    DELETE FROM Jurado_Categoria;
    DELETE FROM Jurado;
    DELETE FROM Pelicula_Categoria;
    DELETE FROM Categoria_Competicion;
    DELETE FROM QA_Participante;
    DELETE FROM QA_Sesion;
    DELETE FROM Proyeccion;
    DELETE FROM Pelicula_Genero;
    DELETE FROM Pelicula_Idioma;
    DELETE FROM Pelicula_Persona_Rol;
    DELETE FROM Pelicula;
    DELETE FROM Alojamiento;
    DELETE FROM Patrocinador;
    DELETE FROM Evento_Paralelo;
    DELETE FROM Tipo_Entrada;
    DELETE FROM Asistente;
    DELETE FROM Sala;
    DELETE FROM Edicion_Festival;
    DELETE FROM Idioma;
    DELETE FROM Genero_Cinematografico;
    DELETE FROM Rol_Cinematografico;
    DELETE FROM Persona;
    */
    
    -- 1. Insert data into independent tables first
    
    -- Inserting Persona data
    PRINT 'Inserting Persona data...';
    INSERT INTO Persona (nombre, apellidos, email, telefono, biografia, nacionalidad)
    VALUES 
        ('Pedro', 'Almodóvar', 'pedro@almodovar.com', '+34612345678', 'Director de cine español reconocido por sus películas que exploran temas de deseo y familia.', 'Española'),
        ('Meryl', 'Streep', 'meryl@streep.com', '+12025550143', 'Actriz estadounidense ganadora de múltiples premios Oscar, conocida por su versatilidad.', 'Estadounidense'),
        ('Guillermo', 'del Toro', 'guillermo@deltoro.com', '+523336897412', 'Director mexicano conocido por sus obras de fantasía oscura.', 'Mexicana'),
        ('Cate', 'Blanchett', 'cate@blanchett.com', '+61295557100', 'Actriz australiana reconocida por su trabajo en múltiples géneros.', 'Australiana'),
        ('Alfonso', 'Cuarón', 'alfonso@cuaron.com', '+525512348765', 'Director, guionista y productor mexicano, ganador de premios Oscar.', 'Mexicana'),
        ('Penélope', 'Cruz', 'penelope@cruz.com', '+34622334455', 'Actriz española ganadora del Oscar, musa de Almodóvar.', 'Española'),
        ('Francis Ford', 'Coppola', 'francis@coppola.com', '+14155550137', 'Legendario director estadounidense conocido por El Padrino.', 'Estadounidense'),
        ('Bong', 'Joon-ho', 'bong@joonho.com', '+8221234567', 'Director surcoreano, ganador del Oscar por Parasite.', 'Surcoreana'),
        ('Emma', 'Thompson', 'emma@thompson.com', '+447700900123', 'Actriz, guionista y activista británica ganadora de múltiples premios.', 'Británica'),
        ('Christopher', 'Nolan', 'chris@nolan.com', '+447700900555', 'Director británico-estadounidense conocido por sus narrativas no lineales.', 'Británica');
    
    -- Inserting Rol_Cinematografico data
    PRINT 'Inserting Rol_Cinematografico data...';
    INSERT INTO Rol_Cinematografico (nombre)
    VALUES 
        ('Director'),
        ('Actor Principal'),
        ('Actriz Principal'),
        ('Actor Secundario'),
        ('Actriz Secundaria'),
        ('Guionista'),
        ('Director de Fotografía'),
        ('Productor'),
        ('Compositor'),
        ('Montador');
    
    -- Inserting Genero_Cinematografico data
    PRINT 'Inserting Genero_Cinematografico data...';
    INSERT INTO Genero_Cinematografico (nombre, descripcion)
    VALUES 
        ('Drama', 'Películas que se centran en el desarrollo de personajes emocionales y conflictos'),
        ('Comedia', 'Películas que intentan hacer reír a la audiencia'),
        ('Ciencia Ficción', 'Películas que exploran conceptos futuristas, científicos y tecnológicos'),
        ('Terror', 'Películas diseñadas para asustar y provocar miedo en la audiencia'),
        ('Documental', 'Películas no ficticias que documentan la realidad'),
        ('Animación', 'Películas creadas con técnicas de animación'),
        ('Thriller', 'Películas de suspenso que mantienen a la audiencia en tensión'),
        ('Acción', 'Películas con secuencias de acción intensas'),
        ('Romance', 'Películas centradas en relaciones amorosas'),
        ('Fantasía', 'Películas que incluyen elementos mágicos o sobrenaturales');
    
    -- Inserting Idioma data
    PRINT 'Inserting Idioma data...';
    INSERT INTO Idioma (nombre, codigo_iso)
    VALUES 
        ('Español', 'ES'),
        ('Inglés', 'EN'),
        ('Francés', 'FR'),
        ('Alemán', 'DE'),
        ('Italiano', 'IT'),
        ('Portugués', 'PT'),
        ('Ruso', 'RU'),
        ('Chino Mandarín', 'ZH'),
        ('Japonés', 'JA'),
        ('Coreano', 'KO');
    
    -- Inserting Edicion_Festival data
    PRINT 'Inserting Edicion_Festival data...';
    INSERT INTO Edicion_Festival (anio, fecha_inicio, fecha_fin, tema, director_festival)
    VALUES 
        (2022, '2022-10-01', '2022-10-12', 'Cine y Cambio Climático', 'María García'),
        (2023, '2023-10-05', '2023-10-15', 'Fronteras y Migración', 'Juan Rodríguez'),
        (2024, '2024-10-03', '2024-10-14', 'Memoria e Identidad', 'Sofia López');
    
    -- Inserting Sala data
    PRINT 'Inserting Sala data...';
    INSERT INTO Sala (nombre, ubicacion, capacidad, caracteristicas_tecnicas)
    VALUES 
        ('Sala Principal', 'Edificio Central, Piso 1', 500, 'Proyector 4K, Sistema de sonido Dolby Atmos, Pantalla de 15m'),
        ('Sala Pequeña', 'Edificio Central, Piso 2', 150, 'Proyector 2K, Sistema de sonido 7.1'),
        ('Auditorio Exterior', 'Jardines del Festival', 800, 'Pantalla LED gigante, Audio al aire libre'),
        ('Sala VIP', 'Edificio Anexo', 80, 'Butacas de cuero, Servicio personalizado, Proyector 4K'),
        ('Sala Experimental', 'Edificio Este', 120, 'Equipos para proyecciones experimentales y VR');
    
    -- Inserting Asistente data
    PRINT 'Inserting Asistente data...';
    INSERT INTO Asistente (nombre, apellidos, email, telefono, tipo_asistente)
    VALUES 
        ('Carlos', 'Gómez', 'carlos@example.com', '+34611223344', 'publico'),
        ('Ana', 'Martínez', 'ana@example.com', '+34622334455', 'prensa'),
        ('Miguel', 'Fernández', 'miguel@example.com', '+34633445566', 'industria'),
        ('Laura', 'Sánchez', 'laura@example.com', '+34644556677', 'VIP'),
        ('Roberto', 'Díaz', 'roberto@example.com', '+34655667788', 'publico'),
        ('Elena', 'Pérez', 'elena@example.com', '+34666778899', 'prensa'),
        ('Javier', 'López', 'javier@example.com', '+34677889900', 'industria'),
        ('Carmen', 'Ruiz', 'carmen@example.com', '+34688990011', 'VIP');
    
    -- Inserting Tipo_Entrada data
    PRINT 'Inserting Tipo_Entrada data...';
    INSERT INTO Tipo_Entrada (nombre, descripcion, precio_base)
    VALUES 
        ('General', 'Entrada estándar para una proyección', 10.00),
        ('Reducida', 'Entrada con descuento para estudiantes, jubilados, etc.', 7.50),
        ('Premium', 'Entrada con asiento preferente', 15.00),
        ('Gala', 'Entrada para galas de apertura y clausura', 25.00),
        ('Maratón', 'Entrada para maratones temáticos', 20.00);
    
    -- Inserting Evento_Paralelo data
    PRINT 'Inserting Evento_Paralelo data...';
    INSERT INTO Evento_Paralelo (nombre, tipo, descripcion, fecha, hora_inicio, hora_fin, ubicacion, aforo_maximo, requiere_inscripcion)
    VALUES 
        ('Masterclass de Dirección', 'Formativo', 'Masterclass impartida por Alfonso Cuarón sobre técnicas de dirección', '2023-10-07', '11:00', '13:30', 'Sala de Conferencias A', 100, 1),
        ('Networking Productores', 'Networking', 'Evento para conectar productores con financiadores', '2023-10-08', '17:00', '20:00', 'Hotel Continental, Salón Oro', 150, 1),
        ('Exposición Fotografía de Cine', 'Exposición', 'Muestra de fotografías de rodajes icónicos', '2023-10-06', '10:00', '19:00', 'Galería Central', 200, 0),
        ('Mesa Redonda: Futuro del Cine', 'Debate', 'Debate sobre los desafíos del cine en la era digital', '2023-10-09', '16:00', '18:00', 'Sala de Conferencias B', 120, 1),
        ('Taller de Guion', 'Formativo', 'Taller práctico sobre escritura de guiones', '2023-10-10', '10:00', '14:00', 'Centro Cultural, Aula 3', 30, 1);
    
    -- Inserting Patrocinador data
    PRINT 'Inserting Patrocinador data...';
    INSERT INTO Patrocinador (nombre, contacto_principal, telefono, email, tipo)
    VALUES 
        ('CineMax Studios', 'Antonio Hernández', '+34911223344', 'antonio@cinemax.com', 'Productora'),
        ('BankFilm', 'María Torres', '+34922334455', 'maria@bankfilm.com', 'Financiero'),
        ('TechVision', 'Pablo Martín', '+34933445566', 'pablo@techvision.com', 'Tecnológico'),
        ('UniCultura', 'Carmen Jiménez', '+34944556677', 'carmen@unicultura.edu', 'Institución Cultural'),
        ('GlobalMedia', 'David Ruiz', '+34955667788', 'david@globalmedia.com', 'Medio Comunicación');
    
    -- Inserting Alojamiento data
    PRINT 'Inserting Alojamiento data...';
    INSERT INTO Alojamiento (nombre_establecimiento, direccion, telefono, categoria)
    VALUES 
        ('Hotel Festival', 'Calle Mayor 123', '+34966778899', '4 estrellas'),
        ('Apartamentos Cine', 'Avenida Central 45', '+34977889900', '3 estrellas'),
        ('Grand Hotel Director', 'Plaza Principal 1', '+34988990011', '5 estrellas'),
        ('Hostal Artista', 'Calle Secundaria 67', '+34999001122', '2 estrellas'),
        ('Residencia Festival', 'Avenida del Cine 32', '+34900112233', '3 estrellas');
    
    -- 2. Insert data into dependent tables
    
    -- Inserting Pelicula data
    PRINT 'Inserting Pelicula data...';
    INSERT INTO Pelicula (titulo, anio, duracion, pais_origen, sinopsis, clasificacion_edad, formato_proyeccion, estado_seleccion)
    VALUES 
        ('El Laberinto del Fauno', 2006, 118, 'España/México', 'En la España de 1944, la joven Ofelia descubre un laberinto habitado por un fauno.', 'R', '35mm', 'premiada'),
        ('Lost in Translation', 2003, 102, 'Estados Unidos', 'Dos estadounidenses solitarios se encuentran en Tokio.', 'R', 'Digital', 'seleccionada'),
        ('Parasite', 2019, 132, 'Corea del Sur', 'Una familia pobre se infiltra en el servicio de una familia rica.', 'R', 'Digital 4K', 'premiada'),
        ('Cinema Paradiso', 1988, 155, 'Italia', 'Historia de amistad entre un niño y un proyeccionista de cine.', 'PG', '35mm', 'seleccionada'),
        ('Amelie', 2001, 122, 'Francia', 'Una camarera idealista decide cambiar la vida de quienes la rodean.', 'R', 'Digital', 'seleccionada'),
        ('Todo sobre mi madre', 1999, 101, 'España', 'Tras la muerte de su hijo, Manuela busca al padre de este.', '16+', 'Digital', 'premiada'),
        ('Inception', 2010, 148, 'Estados Unidos', 'Un ladrón que roba secretos corporativos a través de la tecnología de compartir sueños.', 'PG-13', 'IMAX', 'seleccionada'),
        ('La vida de los otros', 2006, 137, 'Alemania', 'Un agente de la policía secreta vigila a un escritor y su amante.', 'R', 'Digital', 'seleccionada'),
        ('El viaje de Chihiro', 2001, 125, 'Japón', 'Una niña entra en un mundo de dioses y espíritus.', 'PG', 'Digital', 'premiada'),
        ('Nomadland', 2020, 107, 'Estados Unidos', 'Una mujer se convierte en nómada tras perderlo todo en la Gran Recesión.', 'R', 'Digital 4K', 'postulada');
    
    -- Inserting Pelicula_Persona_Rol data
    PRINT 'Inserting Pelicula_Persona_Rol data...';
    INSERT INTO Pelicula_Persona_Rol (pelicula_id, persona_id, rol_id, descripcion_rol)
    VALUES 
        (1, 3, 1, 'Director principal'),
        (1, 3, 6, 'Co-guionista'),
        (6, 1, 1, 'Director principal'),
        (6, 1, 6, 'Guionista'),
        (6, 6, 3, 'Manuela'),
        (3, 8, 1, 'Director principal'),
        (3, 8, 6, 'Guionista'),
        (7, 10, 1, 'Director y guionista'),
        (7, 10, 6, 'Guionista'),
        (2, 4, 3, 'Charlotte'),
        (5, 9, 3, 'Actriz recurrente');
    
    -- Inserting Pelicula_Idioma data
    PRINT 'Inserting Pelicula_Idioma data...';
    INSERT INTO Pelicula_Idioma (pelicula_id, idioma_id, tipo)
    VALUES 
        (1, 1, 'original'),
        (1, 2, 'subtitulos'),
        (2, 2, 'original'),
        (2, 1, 'subtitulos'),
        (3, 10, 'original'),
        (3, 2, 'subtitulos'),
        (3, 1, 'subtitulos'),
        (4, 5, 'original'),
        (4, 1, 'subtitulos'),
        (4, 2, 'subtitulos'),
        (5, 3, 'original'),
        (5, 1, 'subtitulos'),
        (5, 2, 'subtitulos'),
        (6, 1, 'original'),
        (6, 2, 'subtitulos'),
        (7, 2, 'original'),
        (7, 1, 'subtitulos'),
        (8, 4, 'original'),
        (8, 1, 'subtitulos'),
        (9, 9, 'original'),
        (9, 1, 'subtitulos'),
        (10, 2, 'original'),
        (10, 1, 'subtitulos');
    
    -- Inserting Pelicula_Genero data
    PRINT 'Inserting Pelicula_Genero data...';
    INSERT INTO Pelicula_Genero (pelicula_id, genero_id)
    VALUES 
        (1, 10), -- El Laberinto del Fauno - Fantasía
        (1, 1), -- El Laberinto del Fauno - Drama
        (2, 1), -- Lost in Translation - Drama
        (2, 2), -- Lost in Translation - Comedia
        (3, 1), -- Parasite - Drama
        (3, 7), -- Parasite - Thriller
        (4, 1), -- Cinema Paradiso - Drama
        (5, 2), -- Amelie - Comedia
        (5, 9), -- Amelie - Romance
        (6, 1), -- Todo sobre mi madre - Drama
        (7, 3), -- Inception - Ciencia Ficción
        (7, 7), -- Inception - Thriller
        (8, 1), -- La vida de los otros - Drama
        (8, 7), -- La vida de los otros - Thriller
        (9, 6), -- El viaje de Chihiro - Animación
        (9, 10), -- El viaje de Chihiro - Fantasía
        (10, 1); -- Nomadland - Drama
    
    -- Inserting Proyeccion data
    PRINT 'Inserting Proyeccion data...';
    INSERT INTO Proyeccion (pelicula_id, sala_id, fecha, hora_inicio, hora_fin, sesion_qa)
    VALUES 
        (1, 1, '2023-10-06', '19:00', '21:00', 1),
        (2, 2, '2023-10-07', '16:30', '18:15', 0),
        (3, 1, '2023-10-08', '20:00', '22:15', 1),
        (4, 3, '2023-10-09', '18:00', '20:40', 0),
        (5, 4, '2023-10-10', '17:30', '19:35', 1),
        (6, 1, '2023-10-11', '19:30', '21:15', 1),
        (7, 3, '2023-10-12', '21:00', '23:30', 0),
        (8, 2, '2023-10-13', '16:00', '18:20', 0),
        (9, 1, '2023-10-14', '15:00', '17:10', 1),
        (10, 5, '2023-10-15', '18:30', '20:20', 0),
        (1, 2, '2023-10-07', '19:00', '21:00', 0),
        (2, 3, '2023-10-08', '16:30', '18:15', 0),
        (3, 4, '2023-10-09', '20:00', '22:15', 0),
        (4, 5, '2023-10-10', '18:00', '20:40', 0),
        (5, 1, '2023-10-11', '17:30', '19:35', 0);
    
    -- Inserting QA_Sesion data
    PRINT 'Inserting QA_Sesion data...';
    INSERT INTO QA_Sesion (proyeccion_id, descripcion, moderador)
    VALUES 
        (1, 'Sesión de preguntas y respuestas con el director Guillermo del Toro', 'María Rodríguez'),
        (3, 'Debate sobre el impacto social de Parasite', 'Carlos Méndez'),
        (5, 'Conversación sobre la estética visual en Amelie', 'Laura Gómez'),
        (6, 'Retrospectiva de la obra de Almodóvar', 'José Martín'),
        (9, 'La animación japonesa y su influencia global', 'Ana Jiménez');
    
    -- Inserting QA_Participante data
    PRINT 'Inserting QA_Participante data...';
    INSERT INTO QA_Participante (qa_id, persona_id)
    VALUES 
        (1, 3), -- Guillermo del Toro en QA de El Laberinto del Fauno
        (2, 8), -- Bong Joon-ho en QA de Parasite
        (4, 1), -- Pedro Almodóvar en QA de Todo sobre mi madre
        (4, 6); -- Penélope Cruz en QA de Todo sobre mi madre
    
    -- Inserting Categoria_Competicion data
    PRINT 'Inserting Categoria_Competicion data...';
    INSERT INTO Categoria_Competicion (nombre, descripcion, edicion_festival)
    VALUES 
        ('Mejor Película', 'Premio a la mejor película del festival', 2),
        ('Mejor Director', 'Premio al mejor trabajo de dirección', 2),
        ('Mejor Actriz', 'Premio a la mejor interpretación femenina', 2),
        ('Mejor Actor', 'Premio a la mejor interpretación masculina', 2),
        ('Mejor Guion', 'Premio al mejor guion original o adaptado', 2),
        ('Premio del Público', 'Premio otorgado por votación del público', 2),
        ('Opera Prima', 'Premio a la mejor primera película de un director', 2),
        ('Premio Especial del Jurado', 'Premio especial a la innovación o singularidad', 2),
        ('Mejor Fotografía', 'Premio a la mejor dirección de fotografía', 2),
        ('Mejor Música Original', 'Premio a la mejor banda sonora original', 2);
    
    -- Inserting Pelicula_Categoria data
    PRINT 'Inserting Pelicula_Categoria data...';
    INSERT INTO Pelicula_Categoria (pelicula_id, categoria_id)
    VALUES 
        (1, 1), -- El Laberinto del Fauno - Mejor Película
        (1, 2), -- El Laberinto del Fauno - Mejor Director
        (2, 1), -- Lost in Translation - Mejor Película
        (2, 3), -- Lost in Translation - Mejor Actriz
        (3, 1), -- Parasite - Mejor Película
        (3, 2), -- Parasite - Mejor Director
        (3, 5), -- Parasite - Mejor Guion
        (4, 6), -- Cinema Paradiso - Premio del Público
        (5, 1), -- Amelie - Mejor Película
        (5, 9), -- Amelie - Mejor Fotografía
        (6, 2), -- Todo sobre mi madre - Mejor Director
        (6, 3), -- Todo sobre mi madre - Mejor Actriz
        (7, 1), -- Inception - Mejor Película
        (7, 5), -- Inception - Mejor Guion
        (8, 8), -- La vida de los otros - Premio Especial del Jurado
        (9, 10), -- El viaje de Chihiro - Mejor Música Original
        (10, 7); -- Nomadland - Opera Prima
    
    -- Inserting Jurado data
    PRINT 'Inserting Jurado data...';
    INSERT INTO Jurado (nombre, edicion_festival)
    VALUES 
        ('Jurado Oficial Sección Oficial', 2),
        ('Jurado Premio del Público', 2),
        ('Jurado Opera Prima', 2),
        ('Jurado Premios Técnicos', 2);
    
    -- Inserting Jurado_Categoria data
    PRINT 'Inserting Jurado_Categoria data...';
    INSERT INTO Jurado_Categoria (jurado_id, categoria_id)
    VALUES 
        (1, 1), -- Jurado Oficial - Mejor Película
        (1, 2), -- Jurado Oficial - Mejor Director
        (1, 3), -- Jurado Oficial - Mejor Actriz
        (1, 4), -- Jurado Oficial - Mejor Actor
        (1, 5), -- Jurado Oficial - Mejor Guion
        (1, 8), -- Jurado Oficial - Premio Especial del Jurado
        (2, 6), -- Jurado Premio del Público - Premio del Público
        (3, 7), -- Jurado Opera Prima - Opera Prima
        (4, 9), -- Jurado Premios Técnicos - Mejor Fotografía
        (4, 10); -- Jurado Premios Técnicos - Mejor Música Original
    
    -- Inserting Miembro_Jurado data
    PRINT 'Inserting Miembro_Jurado data...';
    INSERT INTO Miembro_Jurado (jurado_id, persona_id, cargo)
    VALUES 
        (1, 7, 'Presidente'),
        (1, 4, 'Vocal'),
        (1, 5, 'Vocal'),
        (2, 9, 'Coordinadora'),
        (3, 2, 'Presidenta'),
        (3, 10, 'Vocal'),
        (4, 3, 'Presidente'),
        (4, 1, 'Vocal');
    
    -- Inserting Evaluacion data
    PRINT 'Inserting Evaluacion data...';
    INSERT INTO Evaluacion (pelicula_id, jurado_id, persona_id, puntuacion, comentarios, fecha_evaluacion)
    VALUES 
        (1, 1, 7, 9.50, 'Una obra maestra visual con profundidad emocional', '2023-10-10 15:30:00'),
        (1, 1, 4, 9.20, 'Destaca por su atmósfera única y dirección artística', '2023-10-10 16:45:00'),
        (1, 1, 5, 9.70, 'Combina perfectamente fantasía y realidad histórica', '2023-10-10 14:20:00'),
        (2, 1, 7, 8.50, 'Delicada exploración de la soledad y conexión humana', '2023-10-11 10:15:00'),
        (2, 1, 4, 9.00, 'Actuaciones sobresalientes y dirección sutil', '2023-10-11 11:30:00'),
        (3, 1, 5, 9.80, 'Brillante sátira social con ejecución impecable', '2023-10-12 09:45:00'),
        (3, 1, 7, 9.60, 'Guion inteligente con giros inesperados', '2023-10-12 10:20:00'),
        (5, 4, 3, 9.30, 'Fotografía excepcionalmente creativa', '2023-10-13 14:00:00'),
        (6, 1, 4, 9.10, 'Almodóvar en su mejor momento', '2023-10-13 16:30:00'),
        (7, 1, 5, 9.40, 'Concepto original con ejecución técnica brillante', '2023-10-14 11:15:00'),
        (9, 4, 1, 9.70, 'Banda sonora que eleva la experiencia de la película', '2023-10-14 13:40:00'),
        (10, 3, 2, 8.90, 'Impresionante debut con mirada auténtica', '2023-10-15 10:00:00');
    
    -- Inserting Premio data
    PRINT 'Inserting Premio data...';
    INSERT INTO Premio (nombre, categoria_id, dotacion, descripcion)
    VALUES 
        ('Concha de Oro', 1, 50000.00, 'Premio a la mejor película del festival'),
        ('Concha de Plata al Mejor Director', 2, 25000.00, 'Premio al mejor trabajo de dirección'),
        ('Concha de Plata a la Mejor Actriz', 3, 25000.00, 'Premio a la mejor interpretación femenina'),
        ('Concha de Plata al Mejor Actor', 4, 25000.00, 'Premio a la mejor interpretación masculina'),
        ('Premio al Mejor Guion', 5, 15000.00, 'Premio al mejor guion original o adaptado'),
        ('Premio del Público', 6, 10000.00, 'Premio otorgado por votación del público'),
        ('Premio Opera Prima', 7, 20000.00, 'Premio a la mejor primera película de un director'),
        ('Premio Especial del Jurado', 8, 15000.00, 'Premio especial a la innovación o singularidad'),
        ('Premio a la Mejor Fotografía', 9, 10000.00, 'Premio a la mejor dirección de fotografía'),
        ('Premio a la Mejor Música Original', 10, 10000.00, 'Premio a la mejor banda sonora original');
    
    -- Inserting Premio_Otorgado data
    PRINT 'Inserting Premio_Otorgado data...';
    INSERT INTO Premio_Otorgado (premio_id, pelicula_id, edicion_festival, fecha_otorgamiento)
    VALUES 
        (1, 3, 2, '2023-10-15'), -- Concha de Oro a Parasite
        (2, 1, 2, '2023-10-15'), -- Mejor Director a Guillermo del Toro por El Laberinto del Fauno
        (3, 6, 2, '2023-10-15'), -- Mejor Actriz a Penélope Cruz en Todo sobre mi madre
        (5, 3, 2, '2023-10-15'), -- Mejor Guion a Parasite
        (6, 4, 2, '2023-10-15'), -- Premio del Público a Cinema Paradiso
        (8, 8, 2, '2023-10-15'), -- Premio Especial del Jurado a La vida de los otros
        (9, 5, 2, '2023-10-15'), -- Mejor Fotografía a Amelie
        (10, 9, 2, '2023-10-15'); -- Mejor Música Original a El viaje de Chihiro
    
    -- Inserting Abono data
    PRINT 'Inserting Abono data...';
    INSERT INTO Abono (tipo_abono, precio, fecha_inicio_validez, fecha_fin_validez, asistente_id)
    VALUES 
        ('Completo', 120.00, '2023-10-05', '2023-10-15', 1),
        ('Completo', 120.00, '2023-10-05', '2023-10-15', 4),
        ('Fin de Semana', 50.00, '2023-10-06', '2023-10-08', 2),
        ('Fin de Semana', 50.00, '2023-10-13', '2023-10-15', 5),
        ('Temático Drama', 40.00, '2023-10-05', '2023-10-15', 3),
        ('Temático Animación', 30.00, '2023-10-05', '2023-10-15', 6),
        ('Media Semana', 60.00, '2023-10-09', '2023-10-12', 7),
        ('Media Semana', 60.00, '2023-10-09', '2023-10-12', 8);
    
    -- Inserting Entrada data
    PRINT 'Inserting Entrada data...';
    INSERT INTO Entrada (proyeccion_id, tipo_entrada_id, precio_final, fecha_venta, asistente_id, abono_id, usado)
    VALUES 
        (1, 1, 10.00, '2023-09-15 10:30:00', 1, 1, 1),
        (3, 1, 10.00, '2023-09-16 11:45:00', 1, 1, 1),
        (6, 1, 10.00, '2023-09-17 09:20:00', 1, 1, 0),
        (9, 1, 10.00, '2023-09-18 14:15:00', 1, 1, 0),
        
        (1, 4, 25.00, '2023-09-20 16:30:00', 4, 2, 1),
        (3, 4, 25.00, '2023-09-21 12:10:00', 4, 2, 1),
        (5, 4, 25.00, '2023-09-22 10:45:00', 4, 2, 0),
        
        (2, 2, 7.50, '2023-09-25 17:00:00', 2, 3, 1),
        (3, 2, 7.50, '2023-09-26 11:30:00', 2, 3, 0),
        
        (8, 2, 7.50, '2023-09-28 15:20:00', 5, 4, 0),
        (9, 2, 7.50, '2023-09-29 13:40:00', 5, 4, 0),
        
        (1, 3, 15.00, '2023-09-30 10:00:00', NULL, NULL, 1),
        (2, 3, 15.00, '2023-10-01 11:15:00', NULL, NULL, 1),
        (3, 3, 15.00, '2023-10-02 14:30:00', NULL, NULL, 1),
        (4, 3, 15.00, '2023-10-03 16:45:00', NULL, NULL, 0),
        (5, 3, 15.00, '2023-10-04 09:50:00', NULL, NULL, 0);
    
    -- Inserting Acreditacion data
    PRINT 'Inserting Acreditacion data...';
    INSERT INTO Acreditacion (asistente_id, tipo_acreditacion, fecha_emision, fecha_validez)
    VALUES 
        (2, 'Prensa', '2023-09-01', '2023-10-15'),
        (3, 'Industria', '2023-09-05', '2023-10-15'),
        (4, 'VIP', '2023-09-10', '2023-10-15'),
        (6, 'Prensa', '2023-09-08', '2023-10-15'),
        (7, 'Industria', '2023-09-12', '2023-10-15'),
        (8, 'VIP', '2023-09-15', '2023-10-15');
    
    -- Inserting Inscripcion_Evento data
    PRINT 'Inserting Inscripcion_Evento data...';
    INSERT INTO Inscripcion_Evento (evento_id, asistente_id, fecha_inscripcion, asistio)
    VALUES 
        (1, 3, '2023-09-20 10:15:00', 1),
        (1, 7, '2023-09-21 14:30:00', 1),
        (1, 8, '2023-09-22 11:45:00', 0),
        (2, 3, '2023-09-23 09:20:00', 1),
        (2, 4, '2023-09-24 16:10:00', 1),
        (2, 7, '2023-09-25 10:50:00', 0),
        (2, 8, '2023-09-26 13:15:00', 1),
        (4, 2, '2023-09-27 15:30:00', 1),
        (4, 6, '2023-09-28 11:20:00', 1),
        (4, 7, '2023-09-29 14:45:00', 0),
        (5, 3, '2023-09-30 10:00:00', 1),
        (5, 7, '2023-10-01 09:30:00', 1),
        (5, 8, '2023-10-02 12:15:00', 0);
    
    -- Inserting Patrocinio data
    PRINT 'Inserting Patrocinio data...';
    INSERT INTO Patrocinio (patrocinador_id, edicion_festival, tipo_aportacion, valor_monetario, descripcion_aportacion)
    VALUES 
        (1, 2, 'Económica', 50000.00, 'Aportación principal para premios'),
        (1, 1, 'Económica', 45000.00, 'Aportación principal para premios'),
        (2, 2, 'Económica', 30000.00, 'Financiación para actividades paralelas'),
        (2, 1, 'Económica', 25000.00, 'Financiación para actividades paralelas'),
        (3, 2, 'Material', 20000.00, 'Equipos de proyección y sonido'),
        (3, 1, 'Material', 18000.00, 'Equipos de proyección y sonido'),
        (4, 2, 'Espacios', 15000.00, 'Cesión de salas para eventos'),
        (4, 1, 'Espacios', 15000.00, 'Cesión de salas para eventos'),
        (5, 2, 'Difusión', 10000.00, 'Campaña mediática promocional'),
        (5, 1, 'Difusión', 8000.00, 'Campaña mediática promocional');
    
    -- Inserting Reserva_Alojamiento data
    PRINT 'Inserting Reserva_Alojamiento data...';
    INSERT INTO Reserva_Alojamiento (alojamiento_id, persona_id, fecha_entrada, fecha_salida, tipo_habitacion, observaciones)
    VALUES 
        (3, 1, '2023-10-04', '2023-10-12', 'Suite', 'Requiere botella de agua en habitación'),
        (3, 6, '2023-10-04', '2023-10-12', 'Suite', 'Requiere almohadas hipoalergénicas'),
        (3, 3, '2023-10-05', '2023-10-07', 'Junior Suite', 'Requiere late check-out'),
        (3, 8, '2023-10-07', '2023-10-10', 'Junior Suite', 'Requiere servicio de despertador'),
        (1, 4, '2023-10-06', '2023-10-13', 'Doble Superior', 'Requiere habitación con vistas'),
        (1, 5, '2023-10-08', '2023-10-14', 'Doble Superior', 'Requiere habitación tranquila'),
        (1, 2, '2023-10-09', '2023-10-15', 'Doble Estándar', 'No fumador'),
        (2, 7, '2023-10-05', '2023-10-11', 'Apartamento', 'Requiere cocina equipada'),
        (2, 9, '2023-10-07', '2023-10-13', 'Apartamento', 'Requiere cama extra'),
        (4, 10, '2023-10-11', '2023-10-15', 'Individual', 'Con desayuno incluido');
    
    -- Inserting Traslado data
    PRINT 'Inserting Traslado data...';
    INSERT INTO Traslado (persona_id, origen, destino, fecha, hora, tipo_transporte, observaciones)
    VALUES 
        (1, 'Aeropuerto', 'Hotel Festival', '2023-10-04', '14:30', 'Coche Privado', 'Recogida en Terminal 4'),
        (1, 'Hotel Festival', 'Aeropuerto', '2023-10-12', '10:00', 'Coche Privado', 'Vuelo a las 13:00'),
        (3, 'Estación de Tren', 'Hotel Festival', '2023-10-05', '16:45', 'Taxi', 'Tren llega a las 16:30'),
        (3, 'Hotel Festival', 'Estación de Tren', '2023-10-07', '18:15', 'Taxi', 'Tren sale a las 19:00'),
        (6, 'Aeropuerto', 'Hotel Festival', '2023-10-04', '15:20', 'Coche Privado', 'Recogida en Terminal 2'),
        (6, 'Hotel Festival', 'Aeropuerto', '2023-10-12', '11:30', 'Coche Privado', 'Vuelo a las 14:15'),
        (8, 'Aeropuerto', 'Hotel Festival', '2023-10-07', '09:45', 'Taxi', 'Recogida en Terminal 1'),
        (8, 'Hotel Festival', 'Aeropuerto', '2023-10-10', '17:00', 'Taxi', 'Vuelo a las 19:30'),
        (2, 'Aeropuerto', 'Hotel Festival', '2023-10-09', '12:30', 'Shuttle Festival', 'Recogida en punto de encuentro'),
        (2, 'Hotel Festival', 'Aeropuerto', '2023-10-15', '15:45', 'Shuttle Festival', 'Vuelo a las 18:00'),
        (4, 'Aeropuerto', 'Hotel Festival', '2023-10-06', '10:15', 'Coche Privado', 'Recogida en Terminal 3'),
        (4, 'Hotel Festival', 'Sala Principal', '2023-10-07', '18:00', 'Taxi', 'Para proyección de gala'),
        (5, 'Aeropuerto', 'Hotel Festival', '2023-10-08', '11:45', 'Coche Privado', 'Recogida en Terminal 4'),
        (5, 'Hotel Festival', 'Sala Principal', '2023-10-09', '17:30', 'Taxi', 'Para evento de premiación'),
        (9, 'Estación de Tren', 'Hotel Festival', '2023-10-07', '14:00', 'Shuttle Festival', 'Tren llega a las 13:45'),
        (10, 'Aeropuerto', 'Hotel Festival', '2023-10-11', '13:15', 'Coche Privado', 'Recogida VIP');
    
    COMMIT TRANSACTION;
    PRINT 'Data insertion completed successfully.';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;
    
    PRINT 'Error occurred: ' + ERROR_MESSAGE();
    PRINT 'Line number: ' + CAST(ERROR_LINE() AS VARCHAR(10));
END CATCH;
GO