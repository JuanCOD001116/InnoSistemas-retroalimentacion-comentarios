-- V9: Add deliveries and tasks for complete test coverage
-- This migration adds missing deliveries and tasks referenced in V7 feedback data
-- Insert comprehensive deliveries (referenced in V7 with IDs 3000-3005)
INSERT INTO deliveries (
        id,
        title,
        description,
        team_id,
        created_at,
        updated_at
    )
VALUES (
        3000,
        'Entrega Sprint 1 - Backend API',
        'Implementación inicial de endpoints REST y autenticación JWT',
        10,
        NOW() - INTERVAL '15 days',
        NOW() - INTERVAL '15 days'
    ),
    (
        3001,
        'Entrega Sprint 1 - Base de Datos',
        'Diseño del esquema y migraciones iniciales con Flyway',
        10,
        NOW() - INTERVAL '14 days',
        NOW() - INTERVAL '14 days'
    ),
    (
        3002,
        'Entrega Sprint 2 - Frontend',
        'Interfaz de usuario con React y componentes principales',
        10,
        NOW() - INTERVAL '13 days',
        NOW() - INTERVAL '13 days'
    ),
    (
        3003,
        'Entrega Sprint 2 - Integración',
        'Integración frontend-backend y pruebas E2E',
        10,
        NOW() - INTERVAL '10 days',
        NOW() - INTERVAL '10 days'
    ),
    (
        3004,
        'Entrega Sprint 3 - Optimización',
        'Mejoras de rendimiento y caché con Redis',
        20,
        NOW() - INTERVAL '8 days',
        NOW() - INTERVAL '8 days'
    ),
    (
        3005,
        'Entrega Sprint 3 - Despliegue',
        'Configuración Docker y CI/CD con GitHub Actions',
        20,
        NOW() - INTERVAL '6 days',
        NOW() - INTERVAL '6 days'
    );
-- Insert comprehensive tasks (referenced in V7 with IDs 2000-2003)
INSERT INTO tasks (
        id,
        title,
        description,
        id_delivery,
        status,
        created_at,
        updated_at
    )
VALUES (
        2000,
        'Implementar autenticación JWT',
        'Sistema completo de login, registro y refresh tokens',
        3000,
        'completed',
        NOW() - INTERVAL '15 days',
        NOW() - INTERVAL '12 days'
    ),
    (
        2001,
        'Diseñar esquema de base de datos',
        'Modelo ER y normalización de tablas principales',
        3001,
        'completed',
        NOW() - INTERVAL '14 days',
        NOW() - INTERVAL '11 days'
    ),
    (
        2002,
        'Crear componentes de interfaz',
        'Componentes reutilizables con Tailwind CSS',
        3002,
        'completed',
        NOW() - INTERVAL '13 days',
        NOW() - INTERVAL '9 days'
    ),
    (
        2003,
        'Implementar pruebas E2E',
        'Suite completa de pruebas con Cypress',
        3003,
        'in_progress',
        NOW() - INTERVAL '10 days',
        NOW() - INTERVAL '5 days'
    ),
    (
        2004,
        'Configurar caché Redis',
        'Estrategia de caché para endpoints críticos',
        3004,
        'completed',
        NOW() - INTERVAL '8 days',
        NOW() - INTERVAL '7 days'
    ),
    (
        2005,
        'Configurar CI/CD Pipeline',
        'Pipeline completo con tests y deployment',
        3005,
        'pending',
        NOW() - INTERVAL '6 days',
        NOW() - INTERVAL '6 days'
    );
-- Update sequences for deliveries and tasks
SELECT setval(
        'deliveries_id_seq',
        (
            SELECT MAX(id)
            FROM deliveries
        )
    );
SELECT setval(
        'tasks_id_seq',
        (
            SELECT MAX(id)
            FROM tasks
        )
    );
-- Update team_reports JSON to use camelCase for compatibility with DTOs
UPDATE team_reports
SET report_data = jsonb_set(
        jsonb_set(
            report_data - 'team_id',
            '{teamId}',
            report_data->'team_id'
        ) - 'team_members',
        '{teamMembers}',
        report_data->'team_members'
    ) - 'course_id' || jsonb_build_object('courseId', (report_data->>'course_id')::int)
WHERE report_data ? 'team_id';
-- Update student_reports JSON to use camelCase
UPDATE student_reports
SET report_data = jsonb_set(
        jsonb_set(
            report_data - 'student_id',
            '{studentId}',
            report_data->'student_id'
        ) - 'student_name',
        '{studentName}',
        report_data->'student_name'
    ) - 'project_id' || jsonb_build_object('projectId', (report_data->>'project_id')::int) - 'project_name' || jsonb_build_object('projectName', report_data->'project_name')
WHERE report_data ? 'student_id';