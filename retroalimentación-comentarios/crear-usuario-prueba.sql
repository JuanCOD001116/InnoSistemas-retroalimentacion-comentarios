-- Script para crear usuario de prueba en Neon
-- Ejecuta este script en el SQL Editor de Neon

-- Verificar si el usuario ya existe
DO $$
BEGIN
    -- Intentar insertar el usuario con ID 1
    -- Si ya existe, no hará nada
    INSERT INTO users (id, name, email, role, created_at)
    VALUES (1, 'Usuario de Prueba', 'prueba@test.com', 'estudiante', NOW())
    ON CONFLICT (id) DO NOTHING;
    
    RAISE NOTICE 'Usuario de prueba creado o ya existía';
END $$;

-- Verificar que se creó correctamente
SELECT id, name, email, role FROM users WHERE id = 1;

