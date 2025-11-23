-- V14: Add student 1 to teams 301 and 302 for projects 201 and 202
-- This migration configures the student-team relationships needed for report generation
-- First, ensure projects 201 and 202 exist
INSERT INTO projects (id, name, description, professor_id, created_at)
VALUES (
        201,
        'Proyecto 201',
        'Proyecto de prueba para estudiante 1 y profesor 2',
        2,
        NOW() - INTERVAL '45 days'
    ),
    (
        202,
        'Proyecto 202',
        'Proyecto de prueba para estudiante 1 y profesor 2',
        2,
        NOW() - INTERVAL '40 days'
    ) ON CONFLICT (id) DO
UPDATE
SET professor_id = EXCLUDED.professor_id,
    name = EXCLUDED.name,
    description = EXCLUDED.description;
-- Ensure teams 301 and 302 exist and are associated with projects 201 and 202
INSERT INTO teams (id, name, project_id, created_at)
VALUES (
        301,
        'Equipo 301',
        201,
        NOW() - INTERVAL '45 days'
    ),
    (
        302,
        'Equipo 302',
        202,
        NOW() - INTERVAL '40 days'
    ) ON CONFLICT (id) DO
UPDATE
SET project_id = EXCLUDED.project_id,
    name = EXCLUDED.name,
    created_at = EXCLUDED.created_at;
-- Add student 1 to team 301 (project 201)
INSERT INTO team_members (team_id, student_id, joined_at)
VALUES (301, 1, NOW() - INTERVAL '45 days') ON CONFLICT (team_id, student_id) DO NOTHING;
-- Add student 1 to team 302 (project 202)
INSERT INTO team_members (team_id, student_id, joined_at)
VALUES (302, 1, NOW() - INTERVAL '40 days') ON CONFLICT (team_id, student_id) DO NOTHING;
-- Add some sample deliveries for student 1 in team 301 (project 201)
INSERT INTO deliveries (id, team_id, title, description, created_at)
VALUES (
        2001,
        301,
        'Entrega 1 - Análisis',
        'Documento de análisis del sistema',
        NOW() - INTERVAL '40 days'
    ),
    (
        2002,
        301,
        'Entrega 2 - Diseño',
        'Diseño de arquitectura',
        NOW() - INTERVAL '35 days'
    ),
    (
        2003,
        301,
        'Entrega 3 - Implementación',
        'Código fuente y documentación',
        NOW() - INTERVAL '30 days'
    ) ON CONFLICT (id) DO NOTHING;
-- Add some sample deliveries for student 1 in team 302 (project 202)
INSERT INTO deliveries (id, team_id, title, description, created_at)
VALUES (
        2004,
        302,
        'Entrega 1 - Requerimientos',
        'Documento de requerimientos',
        NOW() - INTERVAL '35 days'
    ),
    (
        2005,
        302,
        'Entrega 2 - Prototipo',
        'Prototipo inicial',
        NOW() - INTERVAL '30 days'
    ),
    (
        2006,
        302,
        'Entrega 3 - Sistema Final',
        'Sistema completo',
        NOW() - INTERVAL '25 days'
    ) ON CONFLICT (id) DO NOTHING;
-- Add tasks for deliveries in team 301 (project 201)
INSERT INTO tasks (
        id,
        id_delivery,
        title,
        description,
        status,
        created_at,
        updated_at
    )
VALUES (
        20001,
        2001,
        'Investigación inicial',
        'Investigar tecnologías disponibles',
        'completed',
        NOW() - INTERVAL '40 days',
        NOW() - INTERVAL '38 days'
    ),
    (
        20002,
        2001,
        'Documento de análisis',
        'Redactar análisis completo',
        'completed',
        NOW() - INTERVAL '40 days',
        NOW() - INTERVAL '37 days'
    ),
    (
        20003,
        2002,
        'Diseño de base de datos',
        'Crear diagrama ER',
        'completed',
        NOW() - INTERVAL '35 days',
        NOW() - INTERVAL '33 days'
    ),
    (
        20004,
        2002,
        'Diseño de UI',
        'Mockups de interfaz',
        'in_progress',
        NOW() - INTERVAL '35 days',
        NOW() - INTERVAL '32 days'
    ),
    (
        20005,
        2003,
        'Implementar backend',
        'API REST',
        'pending',
        NOW() - INTERVAL '30 days',
        NOW() - INTERVAL '30 days'
    ),
    (
        20006,
        2003,
        'Implementar frontend',
        'Interfaz de usuario',
        'pending',
        NOW() - INTERVAL '30 days',
        NOW() - INTERVAL '30 days'
    ) ON CONFLICT (id) DO NOTHING;
-- Add tasks for deliveries in team 302 (project 202)
INSERT INTO tasks (
        id,
        id_delivery,
        title,
        description,
        status,
        created_at,
        updated_at
    )
VALUES (
        20007,
        2004,
        'Recopilar requerimientos',
        'Entrevistas con stakeholders',
        'completed',
        NOW() - INTERVAL '35 days',
        NOW() - INTERVAL '33 days'
    ),
    (
        20008,
        2004,
        'Documentar requerimientos',
        'Documento formal',
        'completed',
        NOW() - INTERVAL '35 days',
        NOW() - INTERVAL '32 days'
    ),
    (
        20009,
        2005,
        'Diseño de prototipo',
        'Wireframes',
        'completed',
        NOW() - INTERVAL '30 days',
        NOW() - INTERVAL '28 days'
    ),
    (
        20010,
        2005,
        'Desarrollar prototipo',
        'Versión funcional básica',
        'in_progress',
        NOW() - INTERVAL '30 days',
        NOW() - INTERVAL '27 days'
    ),
    (
        20011,
        2006,
        'Testing',
        'Pruebas de sistema',
        'pending',
        NOW() - INTERVAL '25 days',
        NOW() - INTERVAL '25 days'
    ),
    (
        20012,
        2006,
        'Documentación final',
        'Manual de usuario',
        'pending',
        NOW() - INTERVAL '25 days',
        NOW() - INTERVAL '25 days'
    ) ON CONFLICT (id) DO NOTHING;
-- Add some feedback for student 1's work in project 201
INSERT INTO feedback (
        id,
        delivery_id,
        content,
        author_id,
        created_at,
        edited,
        is_deleted
    )
VALUES (
        3001,
        2001,
        'Excelente investigación, muy completa',
        2,
        NOW() - INTERVAL '39 days',
        FALSE,
        FALSE
    ),
    (
        3002,
        2001,
        'El análisis está bien estructurado, considera agregar más diagramas',
        2,
        NOW() - INTERVAL '37 days',
        FALSE,
        FALSE
    ),
    (
        3003,
        2002,
        'Buen diseño de base de datos, cumple con las normalizaciones',
        2,
        NOW() - INTERVAL '34 days',
        FALSE,
        FALSE
    ) ON CONFLICT (id) DO NOTHING;
-- Add some feedback for student 1's work in project 202
INSERT INTO feedback (
        id,
        delivery_id,
        content,
        author_id,
        created_at,
        edited,
        is_deleted
    )
VALUES (
        3004,
        2004,
        'Los requerimientos están claros y bien definidos',
        2,
        NOW() - INTERVAL '34 days',
        FALSE,
        FALSE
    ),
    (
        3005,
        2004,
        'La documentación es clara, buen trabajo',
        2,
        NOW() - INTERVAL '32 days',
        FALSE,
        FALSE
    ),
    (
        3006,
        2005,
        'Los wireframes son intuitivos y funcionales',
        2,
        NOW() - INTERVAL '29 days',
        FALSE,
        FALSE
    ) ON CONFLICT (id) DO NOTHING;
-- Add some feedback responses from student 1
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
        4001,
        3002,
        'Gracias por el feedback, agregaré los diagramas solicitados',
        1,
        2001,
        NOW() - INTERVAL '36 days',
        FALSE,
        FALSE
    ),
    (
        4002,
        3003,
        'Agradezco el comentario positivo',
        1,
        2002,
        NOW() - INTERVAL '33 days',
        FALSE,
        FALSE
    ),
    (
        4003,
        3005,
        'Gracias profesor, me esforcé en la claridad',
        1,
        2004,
        NOW() - INTERVAL '31 days',
        FALSE,
        FALSE
    ) ON CONFLICT (id) DO NOTHING;
-- Update sequences to avoid conflicts
SELECT setval(
        'projects_id_seq',
        GREATEST(
            (
                SELECT COALESCE(MAX(id), 0)
                FROM projects
            ),
            1000
        )
    );
SELECT setval(
        'teams_id_seq',
        GREATEST(
            (
                SELECT COALESCE(MAX(id), 0)
                FROM teams
            ),
            500
        )
    );
SELECT setval(
        'deliveries_id_seq',
        GREATEST(
            (
                SELECT COALESCE(MAX(id), 0)
                FROM deliveries
            ),
            3000
        )
    );
SELECT setval(
        'tasks_id_seq',
        GREATEST(
            (
                SELECT COALESCE(MAX(id), 0)
                FROM tasks
            ),
            30000
        )
    );
SELECT setval(
        'feedback_id_seq',
        GREATEST(
            (
                SELECT COALESCE(MAX(id), 0)
                FROM feedback
            ),
            5000
        )
    );
SELECT setval(
        'feedback_responses_id_seq',
        GREATEST(
            (
                SELECT COALESCE(MAX(id), 0)
                FROM feedback_responses
            ),
            5000
        )
    );
-- Verification query (commented out, but useful for manual checking)
-- SELECT 
--     tm.student_id,
--     tm.team_id,
--     t.name as team_name,
--     t.project_id,
--     p.name as project_name,
--     COUNT(DISTINCT d.id) as num_deliveries,
--     COUNT(DISTINCT tk.id) as num_tasks,
--     COUNT(DISTINCT f.id) as num_feedbacks
-- FROM team_members tm
-- JOIN teams t ON tm.team_id = t.id
-- JOIN projects p ON t.project_id = p.id
-- LEFT JOIN deliveries d ON d.project_id = p.id
-- LEFT JOIN tasks tk ON tk.delivery_id = d.id AND tk.assigned_to_student = tm.student_id
-- LEFT JOIN feedbacks f ON f.receiver_id = tm.student_id AND f.project_id = p.id
-- WHERE tm.student_id = 1 AND t.id IN (301, 302)
-- GROUP BY tm.student_id, tm.team_id, t.name, t.project_id, p.name
-- ORDER BY t.id;