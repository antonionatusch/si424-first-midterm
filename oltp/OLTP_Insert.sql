USE OLTP_Claude;
GO

-- 1. Insertar idiomas
INSERT INTO Idioma (nombre, codigo_iso) VALUES
('Español', 'ES'), ('Inglés', 'EN'), ('Francés', 'FR'), ('Alemán', 'DE'), ('Italiano', 'IT'),
('Portugués', 'PT'), ('Japonés', 'JA'), ('Chino', 'ZH'), ('Ruso', 'RU'), ('Árabe', 'AR');

-- 2. Insertar géneros cinematográficos
INSERT INTO Genero_Cinematografico (nombre, descripcion) VALUES
('Drama', 'Películas que exploran conflictos emocionales'),
('Comedia', 'Contenido humorístico y divertido'),
('Ciencia Ficción', 'Historias futuristas o tecnológicas'),
('Documental', 'Obras basadas en hechos reales'),
('Terror', 'Diseñado para asustar o provocar miedo'),
('Romance', 'Historias de amor y relaciones'),
('Acción', 'Escenas de alto impacto y movimiento'),
('Animación', 'Técnicas de animación tradicional o digital'),
('Fantasía', 'Elementos mágicos o sobrenaturales'),
('Thriller', 'Suspenso y tensión psicológica');

-- 3. Insertar roles cinematográficos
INSERT INTO Rol_Cinematografico (nombre) VALUES
('Director'), ('Actor Principal'), ('Actor Secundario'), ('Guionista'), ('Productor'),
('Director de Fotografía'), ('Editor'), ('Diseñador de Vestuario'), ('Compositor'), ('Director de Arte');

-- 4. Insertar ediciones del festival
INSERT INTO Edicion_Festival (año, fecha_inicio, fecha_fin, tema, director_festival) VALUES
(2023, '2023-10-01', '2023-10-10', 'El cine como puente cultural', 'María González'),
(2024, '2024-10-05', '2024-10-15', 'Nuevas voces del cine global', 'Carlos Martínez');

-- 5. Insertar personas (directores, actores, etc.)
INSERT INTO Persona (nombre, apellidos, email, telefono, biografia, nacionalidad) VALUES
('Alejandro', 'González Iñárritu', 'alejandro@cine.com', '+525511223344', 'Director mexicano ganador de Oscar', 'México'),
('Pedro', 'Almodóvar', 'pedro@almodovar.es', '+34911234567', 'Aclamado director español', 'España'),
('Penélope', 'Cruz', 'penelope@actriz.es', '+34666777888', 'Actriz española internacional', 'España'),
('Gael', 'García Bernal', 'gael@actor.mx', '+525566778899', 'Actor y director mexicano', 'México'),
('Isabel', 'Coixet', 'isabel@directora.es', '+34987654321', 'Directora catalana reconocida', 'España'),
('Luis', 'Tosar', 'luis@actor.es', '+34654321098', 'Actor gallego de cine y teatro', 'España'),
('Alfonso', 'Cuarón', 'alfonso@director.mx', '+525544332211', 'Director de Gravity y Roma', 'México'),
('Maribel', 'Verdú', 'maribel@actriz.es', '+34900112233', 'Actriz española con carrera internacional', 'España'),
('Damian', 'Szifron', 'damian@director.ar', '+541112345678', 'Director argentino de Relatos Salvajes', 'Argentina'),
('Ricardo', 'Darín', 'ricardo@actor.ar', '+541198765432', 'Actor argentino reconocido', 'Argentina');

-- 6. Insertar películas
INSERT INTO Pelicula (titulo, año, duracion, pais_origen, sinopsis, clasificacion_edad, formato_proyeccion, estado_seleccion) VALUES
('El Laberinto del Fauno', 2006, 118, 'España', 'Una niña descubre un mundo mágico durante la posguerra española', '16+', 'DCP', 'premiada'),
('Roma', 2018, 135, 'México', 'Historia de una empleada doméstica en los años 70', '12+', '4K', 'seleccionada'),
('Relatos Salvajes', 2014, 122, 'Argentina', 'Seis historias de violencia y venganza', '18+', 'DCP', 'seleccionada'),
('Los Olvidados', 1950, 85, 'México', 'Drama sobre niños marginados en la ciudad de México', '16+', '35mm', 'postulada'),
('Volver', 2006, 121, 'España', 'Historia de mujeres en un pueblo manchego', '12+', 'DCP', 'seleccionada'),
('El Secreto de sus Ojos', 2009, 129, 'Argentina', 'Un crimen que marca varias vidas', '16+', 'DCP', 'premiada'),
('Amores Perros', 2000, 154, 'México', 'Tres historias conectadas por un accidente', '18+', 'DCP', 'seleccionada'),
('La Piel que Habito', 2011, 120, 'España', 'Thriller psicológico sobre un cirujano plástico', '18+', 'DCP', 'postulada'),
('El Hijo de la Novia', 2001, 124, 'Argentina', 'Drama sobre un hombre que reevalúa su vida', '12+', '35mm', 'postulada'),
('Y tu Mamá También', 2001, 106, 'México', 'Viaje de dos adolescentes con una mujer mayor', '18+', 'DCP', 'seleccionada');

-- 7. Insertar relación película-género
INSERT INTO Pelicula_Genero (pelicula_id, genero_id) VALUES
(1, 6), (1, 9), (2, 1), (3, 1), (3, 10), (4, 1), (5, 1), (5, 6), 
(6, 1), (6, 10), (7, 1), (7, 10), (8, 1), (8, 10), (9, 1), (10, 1), (10, 6);

-- 8. Insertar relación película-idioma
INSERT INTO Pelicula_Idioma (pelicula_id, idioma_id, tipo) VALUES
(1, 1, 'original'), (1, 2, 'subtítulos'), (2, 1, 'original'), (2, 2, 'subtítulos'),
(3, 1, 'original'), (3, 2, 'subtítulos'), (4, 1, 'original'), (5, 1, 'original'),
(6, 1, 'original'), (7, 1, 'original'), (8, 1, 'original'), (9, 1, 'original'),
(10, 1, 'original');

-- 9. Insertar relación película-persona-rol
INSERT INTO Pelicula_Persona_Rol (pelicula_id, persona_id, rol_id, descripcion_rol) VALUES
(1, 2, 1, 'Director'), (1, 3, 2, 'Protagonista'), (1, 4, 3, 'Actor secundario'),
(2, 7, 1, 'Director y guionista'), (3, 9, 1, 'Director'), (3, 10, 2, 'Protagonista'),
(4, 2, 1, 'Director'), (5, 2, 1, 'Director'), (5, 3, 2, 'Protagonista'),
(6, 10, 2, 'Protagonista'), (7, 1, 1, 'Director'), (7, 4, 2, 'Protagonista'),
(8, 2, 1, 'Director'), (8, 3, 2, 'Protagonista'), (9, 10, 2, 'Protagonista'),
(10, 7, 1, 'Director'), (10, 4, 2, 'Protagonista');

-- 10. Insertar salas
INSERT INTO Sala (nombre, ubicacion, capacidad, caracteristicas_tecnicas) VALUES
('Sala Principal', 'Edificio A, Planta Baja', 250, 'Dolby Atmos, 4K Proyección'),
('Sala Digital', 'Edificio B, Planta 1', 120, '2K Proyección, Sonido 5.1'),
('Sala Clásica', 'Edificio C, Planta Baja', 80, 'Proyector 35mm, Sonido estéreo'),
('Sala Intima', 'Edificio A, Planta 1', 50, 'Proyección digital HD'),
('Sala al Aire Libre', 'Jardín Principal', 300, 'Pantalla gigante, Sonido envolvente');

-- 11. Insertar proyecciones
INSERT INTO Proyeccion (pelicula_id, sala_id, fecha, hora_inicio, hora_fin, sesion_qa) VALUES
(1, 1, '2023-10-02', '18:00', '20:10', 1),
(2, 2, '2023-10-03', '16:00', '18:15', 0),
(3, 3, '2023-10-04', '20:00', '22:05', 1),
(4, 4, '2023-10-05', '17:30', '19:00', 0),
(5, 5, '2023-10-06', '21:30', '23:35', 1),
(6, 1, '2023-10-07', '19:00', '21:10', 0),
(7, 2, '2023-10-08', '18:30', '21:05', 1),
(8, 3, '2023-10-09', '20:00', '22:00', 0),
(9, 4, '2023-10-10', '16:00', '18:05', 1),
(10, 5, '2023-10-02', '22:00', '23:50', 0);

-- 12. Insertar sesiones QA
INSERT INTO QA_Sesion (proyeccion_id, descripcion, moderador) VALUES
(1, 'Sesión con el director y actores principales', 'Juan Pérez'),
(3, 'Análisis de los temas de la película', 'Ana Gómez'),
(5, 'Conversación con la directora', 'Carlos Ruiz'),
(7, 'Debate sobre el cine mexicano contemporáneo', 'Luisa Fernández'),
(9, 'Encuentro con el actor principal', 'Marta Sánchez');

-- 13. Insertar participantes QA
INSERT INTO QA_Participante (qa_id, persona_id) VALUES
(1, 2), (1, 3), (1, 4),
(2, 9), (2, 10),
(3, 2), (3, 3),
(4, 1), (4, 4),
(5, 10);

-- 14. Insertar categorías de competición
INSERT INTO Categoria_Competicion (nombre, descripcion, edicion_festival) VALUES
('Mejor Película', 'Premio a la mejor película en competición', 1),
('Mejor Director', 'Reconocimiento a la mejor dirección', 1),
('Mejor Actor', 'Premio a la mejor interpretación masculina', 1),
('Mejor Actriz', 'Premio a la mejor interpretación femenina', 1),
('Premio del Público', 'Votado por los asistentes al festival', 1);

-- 15. Insertar relación película-categoría
INSERT INTO Pelicula_Categoria (pelicula_id, categoria_id) VALUES
(1, 1), (1, 2), (1, 4),
(2, 1), (2, 2),
(3, 1), (3, 2), (3, 3),
(5, 1), (5, 2), (5, 4),
(6, 1), (6, 3),
(7, 1), (7, 2),
(10, 1), (10, 2), (10, 3);

-- 16. Insertar jurados
INSERT INTO Jurado (nombre, edicion_festival) VALUES
('Jurado Oficial', 1),
('Jurado Joven', 1),
('Jurado Críticos', 1);

-- 17. Insertar relación jurado-categoría
INSERT INTO Jurado_Categoria (jurado_id, categoria_id) VALUES
(1, 1), (1, 2), (1, 3), (1, 4),
(2, 5),
(3, 1), (3, 2);

-- 18. Insertar miembros del jurado
INSERT INTO Miembro_Jurado (jurado_id, persona_id, cargo) VALUES
(1, 5, 'Presidente'), (1, 6, 'Miembro'), (1, 8, 'Miembro'),
(2, 4, 'Coordinador'), (2, 7, 'Miembro'),
(3, 1, 'Presidente'), (3, 9, 'Miembro');

-- 19. Insertar evaluaciones
INSERT INTO Evaluacion (pelicula_id, jurado_id, persona_id, puntuacion, comentarios, fecha_evaluacion) VALUES
(1, 1, 5, 9.5, 'Excelente trabajo técnico y narrativo', '2023-10-03 14:00'),
(1, 1, 6, 8.0, 'Gran actuación pero ritmo lento', '2023-10-03 15:30'),
(2, 1, 5, 7.5, 'Fotografía impresionante', '2023-10-04 11:00'),
(3, 1, 8, 9.0, 'Historias intensas y bien contadas', '2023-10-05 16:45'),
(5, 1, 6, 8.5, 'Almodóvar en su mejor momento', '2023-10-06 10:30'),
(6, 3, 1, 9.5, 'Actuación magistral de Darín', '2023-10-07 14:15'),
(7, 3, 9, 8.0, 'Inicio brillante del nuevo cine mexicano', '2023-10-08 17:00');

-- 20. Insertar premios
INSERT INTO Premio (nombre, categoria_id, dotacion, descripcion) VALUES
('Goya', 1, 50000, 'Premio a la mejor película'),
('Premio Especial del Jurado', 2, 25000, 'Reconocimiento a dirección innovadora'),
('Concha de Plata', 3, 20000, 'Mejor interpretación masculina'),
('Premio a la Mejor Actriz', 4, 20000, 'Mejor interpretación femenina'),
('Premio del Público', 5, 15000, 'Votado por los asistentes');

-- 21. Insertar premios otorgados
INSERT INTO Premio_Otorgado (premio_id, pelicula_id, edicion_festival, fecha_otorgamiento) VALUES
(1, 1, 1, '2023-10-10'),
(2, 3, 1, '2023-10-10'),
(3, 6, 1, '2023-10-10'),
(4, 5, 1, '2023-10-10'),
(5, 2, 1, '2023-10-10');

-- 22. Insertar tipos de entrada
INSERT INTO Tipo_Entrada (nombre, descripcion, precio_base) VALUES
('General', 'Entrada estándar para una proyección', 8.50),
('Estudiante', 'Descuento para estudiantes con carnet', 5.00),
('Senior', 'Descuento para mayores de 65 años', 5.00),
('Pase Prensa', 'Para acreditados de prensa', 0.00),
('Invitación', 'Entrada especial por invitación', 0.00);

-- 23. Insertar asistentes
INSERT INTO Asistente (nombre, apellidos, email, telefono, tipo_asistente) VALUES
('Laura', 'Gómez Pérez', 'laura@gmail.com', '+34611223344', 'público'),
('Miguel', 'Ángel Ruiz', 'miguel@hotmail.com', '+3498765432', 'público'),
('Ana', 'Martín López', 'ana@periodista.es', '+34655443322', 'prensa'),
('Carlos', 'Fernández', 'carlos@cinefilo.com', '+34900112233', 'VIP'),
('Sofía', 'Díaz García', 'sofia@universidad.es', '+34677889900', 'público');

-- 24. Insertar entradas vendidas
INSERT INTO Entrada (proyeccion_id, tipo_entrada_id, precio_final, fecha_venta, asistente_id, usado) VALUES
(1, 1, 8.50, '2023-09-20 10:00', 1, 1),
(1, 2, 5.00, '2023-09-21 11:30', 2, 1),
(2, 1, 8.50, '2023-09-22 12:00', 3, 1),
(3, 3, 5.00, '2023-09-23 09:15', 4, 1),
(4, 4, 0.00, '2023-09-24 15:30', 5, 0),
(5, 1, 8.50, '2023-09-25 16:45', 1, 1),
(6, 2, 5.00, '2023-09-26 17:00', 2, 1),
(7, 5, 0.00, '2023-09-27 18:30', 3, 1),
(8, 1, 8.50, '2023-09-28 19:00', 4, 0),
(9, 3, 5.00, '2023-09-29 20:15', 5, 1);

-- 25. Insertar acreditaciones
INSERT INTO Acreditacion (asistente_id, tipo_acreditacion, fecha_emision, fecha_validez) VALUES
(3, 'Prensa', '2023-09-01', '2023-10-15'),
(4, 'VIP', '2023-09-05', '2023-10-15'),
(5, 'Estudiante', '2023-09-10', '2023-10-15');

-- 26. Insertar eventos paralelos
INSERT INTO Evento_Paralelo (nombre, tipo, descripcion, fecha, hora_inicio, hora_fin, ubicacion, aforo_maximo, requiere_inscripcion) VALUES
('Taller de Guión', 'Taller', 'Taller práctico de escritura de guiones', '2023-10-03', '10:00', '13:00', 'Sala Talleres', 20, 1),
('Mesa Redonda: Mujeres en el Cine', 'Debate', 'Discusión sobre el papel de la mujer en la industria', '2023-10-05', '16:00', '18:00', 'Auditorio Principal', 100, 0),
('Proyección de Cortos Estudiantiles', 'Proyección', 'Selección de los mejores cortos de escuelas de cine', '2023-10-07', '12:00', '14:00', 'Sala Digital', 80, 0),
('Encuentro con Directores Novelas', 'Encuentro', 'Conversación con directores emergentes', '2023-10-09', '17:00', '19:00', 'Sala Intima', 40, 1);

-- 27. Insertar inscripciones a eventos
INSERT INTO Inscripcion_Evento (evento_id, asistente_id, fecha_inscripcion, asistio) VALUES
(1, 1, '2023-09-15 09:00', 1),
(1, 2, '2023-09-16 10:30', 1),
(4, 3, '2023-09-17 11:45', 0),
(4, 4, '2023-09-18 14:20', 1),
(4, 5, '2023-09-19 16:00', 1);

-- 28. Insertar patrocinadores
INSERT INTO Patrocinador (nombre, contacto_principal, telefono, email, tipo) VALUES
('Cervezas Alhambra', 'Juan Martínez', '+34900223344', 'juan@alhambra.es', 'Oro'),
('Renault España', 'María López', '+34911223344', 'maria@renault.es', 'Plata'),
('Ayuntamiento de Madrid', 'Departamento de Cultura', '+34913344556', 'cultura@madrid.es', 'Institucional'),
('Cinesa', 'Pedro García', '+34914455667', 'pedro@cinesa.com', 'Bronce'),
('TVE', 'Ana Sánchez', '+34915566778', 'ana.sanchez@tve.es', 'Medios');

-- 29. Insertar patrocinios
INSERT INTO Patrocinio (patrocinador_id, edicion_festival, tipo_aportacion, valor_monetario, descripcion_aportacion) VALUES
(1, 1, 'Financiero', 50000.00, 'Patrocinio principal del festival'),
(2, 1, 'Vehiculos', 25000.00, 'Flota de vehículos para transporte'),
(3, 1, 'Infraestructura', 30000.00, 'Uso de espacios municipales'),
(4, 1, 'Promoción', 15000.00, 'Publicidad en salas de cine'),
(5, 1, 'Cobertura', 20000.00, 'Transmisión de eventos especiales');

-- 30. Insertar alojamientos
INSERT INTO Alojamiento (nombre_establecimiento, direccion, telefono, categoria) VALUES
('Hotel Ritz', 'Plaza de la Lealtad, 5, Madrid', '+34914285600', '5 estrellas'),
('NH Collection Palacio de Tepa', 'San Sebastián, 2, Madrid', '+34914303454', '4 estrellas'),
('Hotel Único Madrid', 'Claudio Coello, 67, Madrid', '+34917817272', '5 estrellas'),
('Hostal Main Street', 'Gran Vía, 50, Madrid', '+34915481234', '2 estrellas'),
('Apartamentos Turísticos Plaza Mayor', 'Calle Imperial, 10, Madrid', '+34915263748', 'Apartamentos');

-- 31. Insertar reservas de alojamiento
INSERT INTO Reserva_Alojamiento (alojamiento_id, persona_id, fecha_entrada, fecha_salida, tipo_habitacion, observaciones) VALUES
(1, 1, '2023-10-01', '2023-10-11', 'Suite', 'Dieta vegetariana'),
(2, 3, '2023-10-02', '2023-10-09', 'Doble', 'Necesita sala de prensa'),
(3, 5, '2023-10-03', '2023-10-10', 'Individual', 'Alergia a los frutos secos'),
(4, 7, '2023-10-01', '2023-10-11', 'Doble', ''),
(5, 9, '2023-10-04', '2023-10-08', 'Estudio', 'Llegada tarde');

-- 32. Insertar traslados
INSERT INTO Traslado (persona_id, origen, destino, fecha, hora, tipo_transporte, observaciones) VALUES
(1, 'Aeropuerto Barajas T1', 'Hotel Ritz', '2023-10-01', '12:30', 'Coche privado', '2 maletas grandes'),
(3, 'Hotel NH Collection', 'Cine Doré', '2023-10-03', '17:45', 'Taxi', 'Equipo de cámara'),
(5, 'Hotel Único', 'Aeropuerto Barajas T4', '2023-10-10', '09:00', 'Lanzadera', 'Vuelo IB1234'),
(7, 'Estación Atocha', 'Hostal Main Street', '2023-10-01', '15:20', 'Taxi', ''),
(9, 'Hotel Ritz', 'Casa de América', '2023-10-05', '19:30', 'Coche privado', 'Recepción oficial');

-- 33. Insertar abonos
INSERT INTO Abono (tipo_abono, precio, fecha_inicio_validez, fecha_fin_validez, asistente_id)
VALUES 
('Completo', 150.00, '2023-10-01', '2023-10-10', 1),
('Parcial', 80.00, '2023-10-01', '2023-10-05', 2),
('Prensa', 0.00, '2023-10-01', '2023-10-10', 3);
