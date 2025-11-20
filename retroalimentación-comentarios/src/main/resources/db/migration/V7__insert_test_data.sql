-- V7: Insert comprehensive test data for all endpoints
-- Purpose: Provide sufficient test data to validate all API endpoints
-- Clear existing test data (optional, comment out if you want to preserve data)
-- DELETE FROM feedback_responses WHERE id > 0;
-- DELETE FROM feedback WHERE id > 0;
-- DELETE FROM audit_logs WHERE id > 0;
-- DELETE FROM team_reports WHERE id > 0;
-- DELETE FROM student_reports WHERE id > 0;
-- ============================================
-- Test Users (assuming these IDs exist in user service)
-- ============================================
-- Professor: user_id = 1
-- Students: user_ids = 101, 102, 103, 104, 105, 106
-- Teams: team_id = 10 (students 101, 102, 103), team_id = 20 (students 104, 105, 106)
-- Course: course_id = 5
-- Projects: project_id = 1000, 1001
-- Tasks: task_id = 2000, 2001, 2002, 2003
-- Deliveries: delivery_id = 3000, 3001, 3002, 3003, 3004, 3005
-- ============================================
-- 1. FEEDBACK for PROJECTS
-- ============================================
INSERT INTO feedback (
        id,
        content,
        author_id,
        project_id,
        created_at,
        edited,
        is_deleted
    )
VALUES (
        1,
        'Excelente trabajo en el diseño inicial del proyecto. La arquitectura propuesta es sólida.',
        1,
        1000,
        NOW() - INTERVAL '10 days',
        false,
        false
    ),
    (
        2,
        'El proyecto muestra buena organización, pero necesita mejorar la documentación técnica.',
        1,
        1000,
        NOW() - INTERVAL '8 days',
        false,
        false
    ),
    (
        3,
        'Muy buen progreso en la implementación. Sigan así con el trabajo en equipo.',
        1,
        1001,
        NOW() - INTERVAL '7 days',
        false,
        false
    ),
    (
        4,
        'El alcance del proyecto es ambicioso, consideren priorizar funcionalidades clave.',
        1,
        1001,
        NOW() - INTERVAL '5 days',
        false,
        false
    ),
    (
        5,
        'La presentación del proyecto fue clara y profesional. Excelente comunicación del equipo.',
        1,
        1000,
        NOW() - INTERVAL '3 days',
        false,
        false
    );
-- ============================================
-- 2. FEEDBACK for TASKS
-- ============================================
INSERT INTO feedback (
        id,
        content,
        author_id,
        task_id,
        created_at,
        edited,
        is_deleted
    )
VALUES (
        6,
        'La implementación del backend está bien estructurada. Consideren agregar más pruebas unitarias.',
        1,
        2000,
        NOW() - INTERVAL '12 days',
        false,
        false
    ),
    (
        7,
        'El diseño de la base de datos es eficiente, pero falta normalización en algunas tablas.',
        1,
        2001,
        NOW() - INTERVAL '11 days',
        false,
        false
    ),
    (
        8,
        'Buen trabajo en la interfaz de usuario. La usabilidad es intuitiva.',
        1,
        2002,
        NOW() - INTERVAL '9 days',
        false,
        false
    ),
    (
        9,
        'La documentación técnica de esta tarea está incompleta. Por favor, amplíenla.',
        1,
        2003,
        NOW() - INTERVAL '6 days',
        false,
        false
    ),
    (
        10,
        'Excelente implementación de las pruebas de integración.',
        1,
        2000,
        NOW() - INTERVAL '4 days',
        false,
        false
    ),
    (
        11,
        'El código está bien comentado, pero necesita refactorización en algunos módulos.',
        1,
        2001,
        NOW() - INTERVAL '2 days',
        false,
        false
    );
-- ============================================
-- 3. FEEDBACK for DELIVERIES
-- ============================================
INSERT INTO feedback (
        id,
        content,
        author_id,
        delivery_id,
        created_at,
        edited,
        is_deleted
    )
VALUES (
        12,
        'Entrega a tiempo. El código cumple con los requisitos básicos.',
        1,
        3000,
        NOW() - INTERVAL '15 days',
        false,
        false
    ),
    (
        13,
        'Buena calidad de código, pero faltan algunos casos de prueba edge cases.',
        1,
        3001,
        NOW() - INTERVAL '14 days',
        false,
        false
    ),
    (
        14,
        'La documentación adjunta es completa y clara. Excelente trabajo.',
        1,
        3002,
        NOW() - INTERVAL '13 days',
        false,
        false
    ),
    (
        15,
        'El código tiene algunos bugs menores que deben corregirse antes de la siguiente entrega.',
        1,
        3003,
        NOW() - INTERVAL '10 days',
        false,
        false
    ),
    (
        16,
        'Muy buen manejo de excepciones y validaciones en esta entrega.',
        1,
        3004,
        NOW() - INTERVAL '8 days',
        false,
        false
    ),
    (
        17,
        'La implementación supera las expectativas. Código limpio y bien organizado.',
        1,
        3005,
        NOW() - INTERVAL '6 days',
        false,
        false
    ),
    (
        18,
        'Necesitan mejorar el manejo de errores en el frontend.',
        1,
        3000,
        NOW() - INTERVAL '5 days',
        false,
        false
    ),
    (
        19,
        'Excelente integración entre backend y frontend.',
        1,
        3001,
        NOW() - INTERVAL '3 days',
        false,
        false
    ),
    (
        20,
        'La entrega está completa pero llegó un día tarde. Planifiquen mejor los tiempos.',
        1,
        3002,
        NOW() - INTERVAL '2 days',
        false,
        false
    ),
    (
        21,
        'Implementación robusta con buenas prácticas de seguridad.',
        1,
        3003,
        NOW() - INTERVAL '1 day',
        false,
        false
    );
-- ============================================
-- 4. FEEDBACK RESPONSES from Students
-- ============================================
INSERT INTO feedback_responses (
        id,
        feedback_id,
        content,
        author_id,
        delivery_id,
        created_at,
        edited,
        is_deleted
    )
VALUES -- Responses to project feedback (IDs 1-5)
    (
        1,
        1,
        'Gracias por el feedback positivo. Trabajaremos en mejorar la documentación.',
        101,
        NULL,
        NOW() - INTERVAL '9 days',
        false,
        false
    ),
    (
        2,
        2,
        'Entendido, ya estamos actualizando la documentación técnica con más detalles.',
        102,
        NULL,
        NOW() - INTERVAL '7 days',
        false,
        false
    ),
    (
        3,
        3,
        'Apreciamos los comentarios. Seguiremos manteniendo esta dinámica de trabajo.',
        104,
        NULL,
        NOW() - INTERVAL '6 days',
        false,
        false
    ),
    (
        4,
        4,
        'Tomaremos en cuenta la sugerencia y priorizaremos las funcionalidades core.',
        105,
        NULL,
        NOW() - INTERVAL '4 days',
        false,
        false
    ),
    (
        5,
        5,
        'Muchas gracias! Nos esforzamos mucho en la presentación.',
        101,
        NULL,
        NOW() - INTERVAL '2 days',
        false,
        false
    ),
    -- Responses to task feedback (IDs 6-11)
    (
        6,
        6,
        'Agregaremos más pruebas unitarias esta semana.',
        103,
        NULL,
        NOW() - INTERVAL '11 days',
        false,
        false
    ),
    (
        7,
        7,
        'Revisaremos la normalización de las tablas y haremos los ajustes necesarios.',
        102,
        NULL,
        NOW() - INTERVAL '10 days',
        false,
        false
    ),
    (
        8,
        8,
        'Nos alegra que la interfaz sea intuitiva. Seguiremos mejorándola.',
        106,
        NULL,
        NOW() - INTERVAL '8 days',
        false,
        false
    ),
    (
        9,
        9,
        'Ya estamos trabajando en completar toda la documentación técnica.',
        104,
        NULL,
        NOW() - INTERVAL '5 days',
        false,
        false
    ),
    (
        10,
        10,
        'Gracias! Las pruebas de integración fueron un reto pero valió la pena.',
        101,
        NULL,
        NOW() - INTERVAL '3 days',
        false,
        false
    ),
    -- Responses to delivery feedback (IDs 12-21)
    (
        11,
        12,
        'Gracias por la revisión. Trabajaremos en los puntos mencionados.',
        101,
        3000,
        NOW() - INTERVAL '14 days',
        false,
        false
    ),
    (
        12,
        13,
        'Agregaremos los casos edge que mencionas en la próxima iteración.',
        102,
        3001,
        NOW() - INTERVAL '13 days',
        false,
        false
    ),
    (
        13,
        14,
        'Nos esforzamos mucho en la documentación. Gracias por notarlo!',
        103,
        3002,
        NOW() - INTERVAL '12 days',
        false,
        false
    ),
    (
        14,
        15,
        'Ya identificamos los bugs y estamos trabajando en las correcciones.',
        104,
        3003,
        NOW() - INTERVAL '9 days',
        false,
        false
    ),
    (
        15,
        16,
        'Agradecemos el feedback positivo sobre el manejo de excepciones.',
        105,
        3004,
        NOW() - INTERVAL '7 days',
        false,
        false
    ),
    (
        16,
        17,
        'Muchas gracias! Seguiremos manteniendo esta calidad de código.',
        106,
        3005,
        NOW() - INTERVAL '5 days',
        false,
        false
    ),
    (
        17,
        18,
        'Revisaremos el manejo de errores en el frontend inmediatamente.',
        101,
        3000,
        NOW() - INTERVAL '4 days',
        false,
        false
    ),
    (
        18,
        19,
        'La integración fue un trabajo conjunto del equipo. Gracias!',
        102,
        3001,
        NOW() - INTERVAL '2 days',
        false,
        false
    ),
    (
        19,
        20,
        'Lamentamos el retraso. Implementaremos mejor gestión del tiempo.',
        103,
        3002,
        NOW() - INTERVAL '1 day',
        false,
        false
    ),
    (
        20,
        21,
        'La seguridad es prioritaria para nosotros. Seguiremos esas prácticas.',
        104,
        3003,
        NOW() - INTERVAL '12 hours',
        false,
        false
    );
-- ============================================
-- 5. ADDITIONAL RESPONSES (nested conversations)
-- ============================================
INSERT INTO feedback_responses (
        id,
        feedback_id,
        content,
        author_id,
        delivery_id,
        created_at,
        edited,
        is_deleted
    )
VALUES (
        21,
        6,
        'El equipo ya completó 15 nuevas pruebas unitarias. ¿Podría revisarlas?',
        101,
        NULL,
        NOW() - INTERVAL '9 days',
        false,
        false
    ),
    (
        22,
        7,
        'Hemos normalizado todas las tablas a 3FN. Adjuntamos el nuevo diagrama ER.',
        103,
        NULL,
        NOW() - INTERVAL '8 days',
        false,
        false
    ),
    (
        23,
        15,
        'Los bugs han sido corregidos y verificados. ¿Podemos proceder a la siguiente fase?',
        105,
        3003,
        NOW() - INTERVAL '7 days',
        false,
        false
    );
-- ============================================
-- 6. EDITED and DELETED FEEDBACK (for testing soft delete)
-- ============================================
INSERT INTO feedback (
        id,
        content,
        author_id,
        project_id,
        created_at,
        updated_at,
        edited,
        is_deleted
    )
VALUES (
        22,
        'Este feedback fue editado posteriormente.',
        1,
        1000,
        NOW() - INTERVAL '20 days',
        NOW() - INTERVAL '18 days',
        true,
        false
    ),
    (
        23,
        'Este feedback fue eliminado (soft delete).',
        1,
        1001,
        NOW() - INTERVAL '25 days',
        NOW() - INTERVAL '20 days',
        false,
        true
    ),
    (
        24,
        'Feedback inicial que luego fue modificado para mayor claridad.',
        1,
        1000,
        NOW() - INTERVAL '30 days',
        NOW() - INTERVAL '28 days',
        true,
        false
    );
-- Reset sequences to continue from the last inserted ID
SELECT setval(
        'feedback_id_seq',
        (
            SELECT MAX(id)
            FROM feedback
        )
    );
SELECT setval(
        'feedback_responses_id_seq',
        (
            SELECT MAX(id)
            FROM feedback_responses
        )
    );
-- ============================================
-- 7. AUDIT LOGS (for testing audit trail)
-- ============================================
INSERT INTO audit_logs (
        user_id,
        action,
        target_type,
        target_id,
        metadata,
        ip,
        user_agent,
        created_at
    )
VALUES (
        1,
        'CREATE_FEEDBACK',
        'FEEDBACK',
        1,
        '{"project_id": 1000, "content_length": 85}'::jsonb,
        '192.168.1.100',
        'Mozilla/5.0',
        NOW() - INTERVAL '10 days'
    ),
    (
        1,
        'CREATE_FEEDBACK',
        'FEEDBACK',
        2,
        '{"project_id": 1000, "content_length": 92}'::jsonb,
        '192.168.1.100',
        'Mozilla/5.0',
        NOW() - INTERVAL '8 days'
    ),
    (
        101,
        'CREATE_RESPONSE',
        'FEEDBACK_RESPONSE',
        1,
        '{"feedback_id": 1, "delivery_id": null}'::jsonb,
        '192.168.1.101',
        'Chrome/120.0',
        NOW() - INTERVAL '9 days'
    ),
    (
        102,
        'CREATE_RESPONSE',
        'FEEDBACK_RESPONSE',
        2,
        '{"feedback_id": 2, "delivery_id": null}'::jsonb,
        '192.168.1.102',
        'Firefox/121.0',
        NOW() - INTERVAL '7 days'
    ),
    (
        1,
        'EDIT_FEEDBACK',
        'FEEDBACK',
        22,
        '{"old_content_length": 45, "new_content_length": 52}'::jsonb,
        '192.168.1.100',
        'Mozilla/5.0',
        NOW() - INTERVAL '18 days'
    ),
    (
        1,
        'DELETE_FEEDBACK',
        'FEEDBACK',
        23,
        '{"reason": "outdated", "project_id": 1001}'::jsonb,
        '192.168.1.100',
        'Mozilla/5.0',
        NOW() - INTERVAL '20 days'
    ),
    (
        1,
        'VIEW_FEEDBACK',
        'FEEDBACK',
        5,
        '{"project_id": 1000}'::jsonb,
        '192.168.1.100',
        'Mozilla/5.0',
        NOW() - INTERVAL '3 days'
    ),
    (
        103,
        'CREATE_RESPONSE',
        'FEEDBACK_RESPONSE',
        13,
        '{"feedback_id": 13, "delivery_id": 3002}'::jsonb,
        '192.168.1.103',
        'Safari/17.0',
        NOW() - INTERVAL '12 days'
    ),
    (
        1,
        'CREATE_FEEDBACK',
        'FEEDBACK',
        16,
        '{"delivery_id": 3005, "content_length": 78}'::jsonb,
        '192.168.1.100',
        'Mozilla/5.0',
        NOW() - INTERVAL '6 days'
    ),
    (
        106,
        'CREATE_RESPONSE',
        'FEEDBACK_RESPONSE',
        16,
        '{"feedback_id": 16, "delivery_id": 3005}'::jsonb,
        '192.168.1.106',
        'Edge/120.0',
        NOW() - INTERVAL '5 days'
    );
-- ============================================
-- 8. TEAM REPORTS (for testing team reports endpoints)
-- ============================================
INSERT INTO team_reports (
        team_id,
        professor_id,
        course_id,
        title,
        summary,
        report_data,
        generated_at,
        created_at
    )
VALUES (
        10,
        1,
        5,
        'Reporte de Evaluación - Equipo 10 - Proyecto Sistema de Gestión',
        'Reporte consolidado del equipo 10 con feedback de proyectos, tareas y entregas. El equipo ha mostrado excelente desempeño.',
        '{
        "team_id": 10,
        "team_members": [101, 102, 103],
        "course_id": 5,
        "projects": [
            {
                "project_id": 1000,
                "project_name": "Sistema de Gestión Académica",
                "feedbacks_count": 5,
                "avg_sentiment": "positive",
                "completion_rate": 85.5
            }
        ],
        "statistics": {
            "total_feedbacks": 12,
            "total_responses": 15,
            "avg_response_time_hours": 24.5,
            "engagement_score": 92.3,
            "completion_rate": 87.0
        },
        "feedbacks": [
            {"id": 1, "content": "Excelente trabajo en el diseño inicial del proyecto.", "created_at": "2025-11-10T10:00:00Z"},
            {"id": 2, "content": "El proyecto muestra buena organización.", "created_at": "2025-11-12T14:30:00Z"}
        ]
    }'::jsonb,
        NOW() - INTERVAL '2 days',
        NOW() - INTERVAL '2 days'
    ),
    (
        20,
        1,
        5,
        'Reporte de Evaluación - Equipo 20 - Proyecto E-Commerce',
        'Reporte del equipo 20 mostrando buen progreso con áreas de mejora identificadas.',
        '{
        "team_id": 20,
        "team_members": [104, 105, 106],
        "course_id": 5,
        "projects": [
            {
                "project_id": 1001,
                "project_name": "Plataforma E-Commerce",
                "feedbacks_count": 4,
                "avg_sentiment": "neutral",
                "completion_rate": 78.2
            }
        ],
        "statistics": {
            "total_feedbacks": 10,
            "total_responses": 12,
            "avg_response_time_hours": 36.0,
            "engagement_score": 85.7,
            "completion_rate": 80.0
        },
        "feedbacks": [
            {"id": 3, "content": "Muy buen progreso en la implementación.", "created_at": "2025-11-13T09:00:00Z"},
            {"id": 4, "content": "El alcance del proyecto es ambicioso.", "created_at": "2025-11-15T16:45:00Z"}
        ]
    }'::jsonb,
        NOW() - INTERVAL '1 day',
        NOW() - INTERVAL '1 day'
    );
-- ============================================
-- 9. STUDENT REPORTS (for testing student reports endpoints)
-- ============================================
INSERT INTO student_reports (
        student_id,
        project_id,
        title,
        summary,
        final_grade,
        report_data,
        generated_at,
        created_at
    )
VALUES (
        101,
        1000,
        'Reporte Final - Juan Pérez - Sistema de Gestión Académica',
        'Estudiante con excelente desempeño, alta participación y entregas de calidad.',
        92.5,
        '{
        "student_id": 101,
        "student_name": "Juan Pérez",
        "project_id": 1000,
        "project_name": "Sistema de Gestión Académica",
        "deliveries": [
            {
                "delivery_id": 3000,
                "task_name": "Implementación Backend",
                "submission_date": "2025-11-05T10:00:00Z",
                "status": "approved",
                "grade": 95.0,
                "feedbacks_count": 2
            },
            {
                "delivery_id": 3001,
                "task_name": "Diseño Base de Datos",
                "submission_date": "2025-11-06T11:30:00Z",
                "status": "approved",
                "grade": 90.0,
                "feedbacks_count": 1
            }
        ],
        "feedbacks_received": 8,
        "responses_given": 6,
        "avg_response_time_hours": 18.5,
        "engagement_score": 95.0,
        "grades": {
            "deliveries_avg": 92.5,
            "participation": 95.0,
            "final_grade": 92.5
        },
        "statistics": {
            "total_tasks_completed": 8,
            "on_time_deliveries": 7,
            "late_deliveries": 1,
            "quality_score": 93.0
        }
    }'::jsonb,
        NOW() - INTERVAL '1 day',
        NOW() - INTERVAL '1 day'
    ),
    (
        102,
        1000,
        'Reporte Final - María García - Sistema de Gestión Académica',
        'Estudiante con buen desempeño general y buena capacidad de respuesta a feedback.',
        88.0,
        '{
        "student_id": 102,
        "student_name": "María García",
        "project_id": 1000,
        "project_name": "Sistema de Gestión Académica",
        "deliveries": [
            {
                "delivery_id": 3000,
                "task_name": "Implementación Backend",
                "submission_date": "2025-11-05T12:00:00Z",
                "status": "approved",
                "grade": 88.0,
                "feedbacks_count": 1
            },
            {
                "delivery_id": 3002,
                "task_name": "Interfaz de Usuario",
                "submission_date": "2025-11-07T15:00:00Z",
                "status": "approved",
                "grade": 90.0,
                "feedbacks_count": 2
            }
        ],
        "feedbacks_received": 6,
        "responses_given": 5,
        "avg_response_time_hours": 24.0,
        "engagement_score": 87.5,
        "grades": {
            "deliveries_avg": 89.0,
            "participation": 87.5,
            "final_grade": 88.0
        },
        "statistics": {
            "total_tasks_completed": 7,
            "on_time_deliveries": 6,
            "late_deliveries": 1,
            "quality_score": 88.5
        }
    }'::jsonb,
        NOW() - INTERVAL '1 day',
        NOW() - INTERVAL '1 day'
    ),
    (
        104,
        1001,
        'Reporte Final - Carlos Rodríguez - Plataforma E-Commerce',
        'Estudiante con buen desempeño, con potencial para mejorar en entregas oportunas.',
        85.0,
        '{
        "student_id": 104,
        "student_name": "Carlos Rodríguez",
        "project_id": 1001,
        "project_name": "Plataforma E-Commerce",
        "deliveries": [
            {
                "delivery_id": 3003,
                "task_name": "Módulo de Pagos",
                "submission_date": "2025-11-10T16:00:00Z",
                "status": "approved",
                "grade": 85.0,
                "feedbacks_count": 2
            },
            {
                "delivery_id": 3004,
                "task_name": "Sistema de Inventario",
                "submission_date": "2025-11-12T10:30:00Z",
                "status": "approved",
                "grade": 87.0,
                "feedbacks_count": 1
            }
        ],
        "feedbacks_received": 5,
        "responses_given": 4,
        "avg_response_time_hours": 30.0,
        "engagement_score": 82.0,
        "grades": {
            "deliveries_avg": 86.0,
            "participation": 82.0,
            "final_grade": 85.0
        },
        "statistics": {
            "total_tasks_completed": 6,
            "on_time_deliveries": 5,
            "late_deliveries": 1,
            "quality_score": 84.0
        }
    }'::jsonb,
        NOW() - INTERVAL '12 hours',
        NOW() - INTERVAL '12 hours'
    );
-- ============================================
-- 10. IDEMPOTENCY KEYS (for testing idempotent operations)
-- ============================================
INSERT INTO idempotency_keys (
        idempotency_key,
        user_id,
        response_body,
        status_code,
        created_at
    )
VALUES (
        'test-key-001-create-feedback',
        1,
        '{"id": 1, "content": "Test feedback", "status": "created"}'::jsonb,
        201,
        NOW() - INTERVAL '5 days'
    ),
    (
        'test-key-002-create-response',
        101,
        '{"id": 1, "feedback_id": 1, "status": "created"}'::jsonb,
        201,
        NOW() - INTERVAL '4 days'
    ),
    (
        'test-key-003-update-feedback',
        1,
        '{"id": 5, "updated": true, "status": "success"}'::jsonb,
        200,
        NOW() - INTERVAL '3 days'
    );
-- ============================================
-- Summary of Test Data Created
-- ============================================
-- FEEDBACK:
--   - 5 project-level feedbacks
--   - 6 task-level feedbacks
--   - 10 delivery-level feedbacks
--   - 3 edited/deleted feedbacks
-- FEEDBACK_RESPONSES:
--   - 23 responses from students
-- AUDIT_LOGS:
--   - 10 audit log entries
-- TEAM_REPORTS:
--   - 2 team reports (teams 10 and 20)
-- STUDENT_REPORTS:
--   - 3 student reports (students 101, 102, 104)
-- IDEMPOTENCY_KEYS:
--   - 3 idempotency test keys
-- This provides comprehensive data to test:
--   ✓ GET /api/feedback (all scopes: project, task, delivery)
--   ✓ POST /api/feedback
--   ✓ PUT /api/feedback/{id}
--   ✓ DELETE /api/feedback/{id}
--   ✓ GET /api/feedback/{id}/responses
--   ✓ POST /api/feedback/{id}/responses
--   ✓ GET /api/audit-logs
--   ✓ GET /api/reports/teams
--   ✓ POST /api/reports/teams/generate
--   ✓ GET /api/reports/students
--   ✓ POST /api/reports/students/generate