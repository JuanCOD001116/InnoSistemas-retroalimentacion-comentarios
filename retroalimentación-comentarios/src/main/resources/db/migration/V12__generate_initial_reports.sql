-- V12: Generate initial student and team reports automatically
-- This ensures reports exist after database reset
-- Uses correct field names from DTOs to avoid deserialization errors
-- ============================================================================
-- STUDENT REPORTS - Using StudentReportDTO.ReportStatistics field names
-- ============================================================================
-- Student 101 - Project 1000
INSERT INTO student_reports (
        student_id,
        project_id,
        title,
        summary,
        report_data,
        final_grade,
        generated_at,
        created_at
    )
SELECT 101,
    1000,
    'Reporte Final - Estudiante 101 - Proyecto Sistemas Distribuidos',
    'Reporte inicial. Use /generate para datos completos.',
    jsonb_build_object(
        'studentId',
        101,
        'studentName',
        'Estudiante 101',
        'projectId',
        1000,
        'projectName',
        'Proyecto Sistemas Distribuidos',
        'finalGrade',
        69.5,
        'deliveries',
        '[]'::jsonb,
        'statistics',
        jsonb_build_object(
            'totalDeliveries',
            0,
            'totalFeedbackReceived',
            0,
            'totalResponsesGiven',
            0,
            'completedTasks',
            0,
            'totalTasks',
            0,
            'taskCompletionRate',
            0.0,
            'averageResponseTimeHours',
            0.0
        )
    ),
    69.5,
    NOW(),
    NOW()
WHERE EXISTS (
        SELECT 1
        FROM team_members
        WHERE student_id = 101
    )
    AND NOT EXISTS (
        SELECT 1
        FROM student_reports
        WHERE student_id = 101
            AND project_id = 1000
    );
-- Student 102 - Project 1000
INSERT INTO student_reports (
        student_id,
        project_id,
        title,
        summary,
        report_data,
        final_grade,
        generated_at,
        created_at
    )
SELECT 102,
    1000,
    'Reporte Final - Estudiante 102 - Proyecto Sistemas Distribuidos',
    'Reporte inicial. Use /generate para datos completos.',
    jsonb_build_object(
        'studentId',
        102,
        'studentName',
        'Estudiante 102',
        'projectId',
        1000,
        'projectName',
        'Proyecto Sistemas Distribuidos',
        'finalGrade',
        66.3,
        'deliveries',
        '[]'::jsonb,
        'statistics',
        jsonb_build_object(
            'totalDeliveries',
            0,
            'totalFeedbackReceived',
            0,
            'totalResponsesGiven',
            0,
            'completedTasks',
            0,
            'totalTasks',
            0,
            'taskCompletionRate',
            0.0,
            'averageResponseTimeHours',
            0.0
        )
    ),
    66.3,
    NOW(),
    NOW()
WHERE EXISTS (
        SELECT 1
        FROM team_members
        WHERE student_id = 102
    )
    AND NOT EXISTS (
        SELECT 1
        FROM student_reports
        WHERE student_id = 102
            AND project_id = 1000
    );
-- Student 103 - Project 1000
INSERT INTO student_reports (
        student_id,
        project_id,
        title,
        summary,
        report_data,
        final_grade,
        generated_at,
        created_at
    )
SELECT 103,
    1000,
    'Reporte Final - Estudiante 103 - Proyecto Sistemas Distribuidos',
    'Reporte inicial. Use /generate para datos completos.',
    jsonb_build_object(
        'studentId',
        103,
        'studentName',
        'Estudiante 103',
        'projectId',
        1000,
        'projectName',
        'Proyecto Sistemas Distribuidos',
        'finalGrade',
        72.0,
        'deliveries',
        '[]'::jsonb,
        'statistics',
        jsonb_build_object(
            'totalDeliveries',
            0,
            'totalFeedbackReceived',
            0,
            'totalResponsesGiven',
            0,
            'completedTasks',
            0,
            'totalTasks',
            0,
            'taskCompletionRate',
            0.0,
            'averageResponseTimeHours',
            0.0
        )
    ),
    72.0,
    NOW(),
    NOW()
WHERE EXISTS (
        SELECT 1
        FROM team_members
        WHERE student_id = 103
    )
    AND NOT EXISTS (
        SELECT 1
        FROM student_reports
        WHERE student_id = 103
            AND project_id = 1000
    );
-- Student 104 - Project 1000
INSERT INTO student_reports (
        student_id,
        project_id,
        title,
        summary,
        report_data,
        final_grade,
        generated_at,
        created_at
    )
SELECT 104,
    1000,
    'Reporte Final - Estudiante 104 - Proyecto Sistemas Distribuidos',
    'Reporte inicial. Use /generate para datos completos.',
    jsonb_build_object(
        'studentId',
        104,
        'studentName',
        'Estudiante 104',
        'projectId',
        1000,
        'projectName',
        'Proyecto Sistemas Distribuidos',
        'finalGrade',
        68.5,
        'deliveries',
        '[]'::jsonb,
        'statistics',
        jsonb_build_object(
            'totalDeliveries',
            0,
            'totalFeedbackReceived',
            0,
            'totalResponsesGiven',
            0,
            'completedTasks',
            0,
            'totalTasks',
            0,
            'taskCompletionRate',
            0.0,
            'averageResponseTimeHours',
            0.0
        )
    ),
    68.5,
    NOW(),
    NOW()
WHERE EXISTS (
        SELECT 1
        FROM team_members
        WHERE student_id = 104
    )
    AND NOT EXISTS (
        SELECT 1
        FROM student_reports
        WHERE student_id = 104
            AND project_id = 1000
    );
-- Student 105 - Project 1001
INSERT INTO student_reports (
        student_id,
        project_id,
        title,
        summary,
        report_data,
        final_grade,
        generated_at,
        created_at
    )
SELECT 105,
    1001,
    'Reporte Final - Estudiante 105 - Proyecto Arquitectura de Software',
    'Reporte inicial. Use /generate para datos completos.',
    jsonb_build_object(
        'studentId',
        105,
        'studentName',
        'Estudiante 105',
        'projectId',
        1001,
        'projectName',
        'Proyecto Arquitectura de Software',
        'finalGrade',
        65.0,
        'deliveries',
        '[]'::jsonb,
        'statistics',
        jsonb_build_object(
            'totalDeliveries',
            0,
            'totalFeedbackReceived',
            0,
            'totalResponsesGiven',
            0,
            'completedTasks',
            0,
            'totalTasks',
            0,
            'taskCompletionRate',
            0.0,
            'averageResponseTimeHours',
            0.0
        )
    ),
    65.0,
    NOW(),
    NOW()
WHERE EXISTS (
        SELECT 1
        FROM team_members
        WHERE student_id = 105
    )
    AND NOT EXISTS (
        SELECT 1
        FROM student_reports
        WHERE student_id = 105
            AND project_id = 1001
    );
-- Student 106 - Project 1001
INSERT INTO student_reports (
        student_id,
        project_id,
        title,
        summary,
        report_data,
        final_grade,
        generated_at,
        created_at
    )
SELECT 106,
    1001,
    'Reporte Final - Estudiante 106 - Proyecto Arquitectura de Software',
    'Reporte inicial. Use /generate para datos completos.',
    jsonb_build_object(
        'studentId',
        106,
        'studentName',
        'Estudiante 106',
        'projectId',
        1001,
        'projectName',
        'Proyecto Arquitectura de Software',
        'finalGrade',
        70.5,
        'deliveries',
        '[]'::jsonb,
        'statistics',
        jsonb_build_object(
            'totalDeliveries',
            0,
            'totalFeedbackReceived',
            0,
            'totalResponsesGiven',
            0,
            'completedTasks',
            0,
            'totalTasks',
            0,
            'taskCompletionRate',
            0.0,
            'averageResponseTimeHours',
            0.0
        )
    ),
    70.5,
    NOW(),
    NOW()
WHERE EXISTS (
        SELECT 1
        FROM team_members
        WHERE student_id = 106
    )
    AND NOT EXISTS (
        SELECT 1
        FROM student_reports
        WHERE student_id = 106
            AND project_id = 1001
    );
-- ============================================================================
-- TEAM REPORTS - Using TeamReportDTO field names (ReportStatistics & ProjectSummary)
-- ============================================================================
-- Team 10 - Project 1000 - Course 100
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
SELECT 10,
    1,
    100,
    'Reporte de Evaluación - Sistemas Distribuidos 2025-1 - Equipo Alpha',
    'Reporte inicial. Use /generate para datos completos.',
    jsonb_build_object(
        'teamId',
        10,
        'teamName',
        'Equipo Alpha - Microservicios',
        'courseId',
        100,
        'courseName',
        'Sistemas Distribuidos 2025-1',
        'professorId',
        1,
        'professorName',
        'Profesor 1',
        'projects',
        jsonb_build_array(
            jsonb_build_object(
                'projectId',
                1000,
                'projectName',
                'Proyecto Sistemas Distribuidos',
                'deliveriesCount',
                0,
                'completedTasks',
                0,
                'totalTasks',
                0,
                'lastDeliveryDate',
                NULL
            )
        ),
        'statistics',
        jsonb_build_object(
            'totalDeliveries',
            0,
            'totalFeedbacks',
            0,
            'totalResponses',
            0,
            'averageResponseTime',
            0.0,
            'pendingDeliveries',
            0
        )
    ),
    NOW(),
    NOW()
WHERE EXISTS (
        SELECT 1
        FROM teams
        WHERE id = 10
    )
    AND EXISTS (
        SELECT 1
        FROM courses
        WHERE id = 100
    )
    AND NOT EXISTS (
        SELECT 1
        FROM team_reports
        WHERE team_id = 10
            AND course_id = 100
    );
-- Team 20 - Project 1001 - Course 101
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
SELECT 20,
    1,
    101,
    'Reporte de Evaluación - Arquitectura de Software 2025-1 - Equipo Beta',
    'Reporte inicial. Use /generate para datos completos.',
    jsonb_build_object(
        'teamId',
        20,
        'teamName',
        'Equipo Beta - Arquitectura',
        'courseId',
        101,
        'courseName',
        'Arquitectura de Software 2025-1',
        'professorId',
        1,
        'professorName',
        'Profesor 1',
        'projects',
        jsonb_build_array(
            jsonb_build_object(
                'projectId',
                1001,
                'projectName',
                'Proyecto Arquitectura de Software',
                'deliveriesCount',
                0,
                'completedTasks',
                0,
                'totalTasks',
                0,
                'lastDeliveryDate',
                NULL
            )
        ),
        'statistics',
        jsonb_build_object(
            'totalDeliveries',
            0,
            'totalFeedbacks',
            0,
            'totalResponses',
            0,
            'averageResponseTime',
            0.0,
            'pendingDeliveries',
            0
        )
    ),
    NOW(),
    NOW()
WHERE EXISTS (
        SELECT 1
        FROM teams
        WHERE id = 20
    )
    AND EXISTS (
        SELECT 1
        FROM courses
        WHERE id = 101
    )
    AND NOT EXISTS (
        SELECT 1
        FROM team_reports
        WHERE team_id = 20
            AND course_id = 101
    );
-- Team 30 - Project 1001 - Course 101
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
SELECT 30,
    1,
    101,
    'Reporte de Evaluación - Arquitectura de Software 2025-1 - Equipo Gamma',
    'Reporte inicial. Use /generate para datos completos.',
    jsonb_build_object(
        'teamId',
        30,
        'teamName',
        'Equipo Gamma - Cloud',
        'courseId',
        101,
        'courseName',
        'Arquitectura de Software 2025-1',
        'professorId',
        1,
        'professorName',
        'Profesor 1',
        'projects',
        jsonb_build_array(
            jsonb_build_object(
                'projectId',
                1001,
                'projectName',
                'Proyecto Arquitectura de Software',
                'deliveriesCount',
                0,
                'completedTasks',
                0,
                'totalTasks',
                0,
                'lastDeliveryDate',
                NULL
            )
        ),
        'statistics',
        jsonb_build_object(
            'totalDeliveries',
            0,
            'totalFeedbacks',
            0,
            'totalResponses',
            0,
            'averageResponseTime',
            0.0,
            'pendingDeliveries',
            0
        )
    ),
    NOW(),
    NOW()
WHERE EXISTS (
        SELECT 1
        FROM teams
        WHERE id = 30
    )
    AND EXISTS (
        SELECT 1
        FROM courses
        WHERE id = 101
    )
    AND NOT EXISTS (
        SELECT 1
        FROM team_reports
        WHERE team_id = 30
            AND course_id = 101
    );
-- Team 40 - Project 1002 - Course 102
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
SELECT 40,
    1,
    102,
    'Reporte de Evaluación - Bases de Datos Avanzadas 2025-1 - Equipo Delta',
    'Reporte inicial. Use /generate para datos completos.',
    jsonb_build_object(
        'teamId',
        40,
        'teamName',
        'Equipo Delta - DevOps',
        'courseId',
        102,
        'courseName',
        'Bases de Datos Avanzadas 2025-1',
        'professorId',
        1,
        'professorName',
        'Profesor 1',
        'projects',
        jsonb_build_array(
            jsonb_build_object(
                'projectId',
                1002,
                'projectName',
                'Proyecto Bases de Datos',
                'deliveriesCount',
                0,
                'completedTasks',
                0,
                'totalTasks',
                0,
                'lastDeliveryDate',
                NULL
            )
        ),
        'statistics',
        jsonb_build_object(
            'totalDeliveries',
            0,
            'totalFeedbacks',
            0,
            'totalResponses',
            0,
            'averageResponseTime',
            0.0,
            'pendingDeliveries',
            0
        )
    ),
    NOW(),
    NOW()
WHERE EXISTS (
        SELECT 1
        FROM teams
        WHERE id = 40
    )
    AND EXISTS (
        SELECT 1
        FROM courses
        WHERE id = 102
    )
    AND NOT EXISTS (
        SELECT 1
        FROM team_reports
        WHERE team_id = 40
            AND course_id = 102
    );
-- ============================================================================
-- INDEXES AND COMMENTS
-- ============================================================================
CREATE INDEX IF NOT EXISTS idx_student_reports_student_project ON student_reports(student_id, project_id);
CREATE INDEX IF NOT EXISTS idx_team_reports_team_course ON team_reports(team_id, course_id);
COMMENT ON COLUMN student_reports.report_data IS 'JSONB - StudentReportDTO: statistics(totalDeliveries, totalFeedbackReceived, totalResponsesGiven, completedTasks, totalTasks, taskCompletionRate, averageResponseTimeHours)';
COMMENT ON COLUMN team_reports.report_data IS 'JSONB - TeamReportDTO: statistics(totalDeliveries, totalFeedbacks, totalResponses, averageResponseTime, pendingDeliveries), projects(projectId, projectName, deliveriesCount, completedTasks, totalTasks, lastDeliveryDate)';