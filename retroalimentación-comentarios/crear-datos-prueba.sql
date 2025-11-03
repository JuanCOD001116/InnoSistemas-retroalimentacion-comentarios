-- Script para crear datos de prueba para los nuevos endpoints
-- Insertar proyecto si no existe
INSERT INTO projects (id, name, description, created_at)
VALUES (
        1,
        'Sistema de Gestión Académica',
        'Proyecto de desarrollo de sistema integral para gestión universitaria',
        NOW()
    ) ON CONFLICT (id) DO NOTHING;
-- Insertar equipos (teams)
INSERT INTO teams (id, name, project_id, created_at)
VALUES (1, 'Equipo Backend', 1, NOW()),
    (2, 'Equipo Frontend', 1, NOW()) ON CONFLICT (id) DO NOTHING;
-- Insertar entregas (deliveries)
INSERT INTO deliveries (id, title, description, team_id, created_at)
VALUES (
        1,
        'Entrega Parcial 1 - Backend',
        'Sistema de autenticación JWT',
        1,
        NOW() - INTERVAL '5 days'
    ),
    (
        2,
        'Entrega Parcial 2 - Frontend',
        'Interfaz de usuario',
        2,
        NOW() - INTERVAL '3 days'
    ),
    (
        3,
        'Entrega Final - Integración',
        'Integración completa del sistema',
        1,
        NOW() - INTERVAL '1 day'
    ) ON CONFLICT (id) DO NOTHING;
-- Insertar tareas (tasks)
INSERT INTO tasks (
        id,
        title,
        description,
        id_delivery,
        status,
        created_at
    )
VALUES (
        1,
        'Implementar JWT',
        'Crear sistema de autenticación con tokens JWT',
        1,
        'completed',
        NOW() - INTERVAL '4 days'
    ),
    (
        2,
        'Validación de errores',
        'Agregar validación de errores en endpoints',
        1,
        'in_progress',
        NOW() - INTERVAL '3 days'
    ),
    (
        3,
        'Diseño responsive',
        'Hacer la interfaz responsive para móviles',
        2,
        'pending',
        NOW() - INTERVAL '2 days'
    ),
    (
        4,
        'Tests unitarios',
        'Escribir tests para los servicios',
        3,
        'in_progress',
        NOW() - INTERVAL '1 day'
    ) ON CONFLICT (id) DO NOTHING;
-- Actualizar feedbacks existentes para asociarlos a deliveries
UPDATE feedback
SET delivery_id = 1
WHERE id IN (4, 8, 12, 13, 14, 15, 19);
-- Insertar más feedbacks para tener variedad
INSERT INTO feedback (content, author_id, delivery_id, created_at)
VALUES (
        'La entrega parcial 2 está muy bien estructurada. Buen trabajo en el frontend.',
        100,
        2,
        NOW() - INTERVAL '2 days'
    ),
    (
        'Falta documentación en algunos componentes de React.',
        100,
        2,
        NOW() - INTERVAL '2 days'
    ) ON CONFLICT DO NOTHING;
-- Mostrar resumen
SELECT 'Deliveries' as tabla,
    COUNT(*) as total
FROM deliveries
UNION ALL
SELECT 'Tasks',
    COUNT(*)
FROM tasks
UNION ALL
SELECT 'Feedbacks',
    COUNT(*)
FROM feedback
UNION ALL
SELECT 'Responses',
    COUNT(*)
FROM feedback_responses;