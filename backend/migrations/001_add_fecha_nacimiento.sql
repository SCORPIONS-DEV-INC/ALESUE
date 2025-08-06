-- Migración para agregar fecha_nacimiento a las tablas usuarios y estudiantes

-- Agregar columna fecha_nacimiento a la tabla usuarios
ALTER TABLE usuarios ADD COLUMN fecha_nacimiento DATE;

-- Agregar columna fecha_nacimiento a la tabla estudiantes  
ALTER TABLE estudiantes ADD COLUMN fecha_nacimiento DATE;

-- Crear índices para optimizar consultas por fecha de nacimiento
CREATE INDEX idx_usuarios_fecha_nacimiento ON usuarios(fecha_nacimiento);
CREATE INDEX idx_estudiantes_fecha_nacimiento ON estudiantes(fecha_nacimiento);

-- Comentarios para documentar el cambio
COMMENT ON COLUMN usuarios.fecha_nacimiento IS 'Fecha de nacimiento del usuario para cálculo automático de edad';
COMMENT ON COLUMN estudiantes.fecha_nacimiento IS 'Fecha de nacimiento del estudiante para cálculo automático de edad';
g