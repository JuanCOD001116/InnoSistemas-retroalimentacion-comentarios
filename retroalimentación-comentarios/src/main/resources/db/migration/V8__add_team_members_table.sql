-- V8: Complete data setup for all endpoints - Full population without constraints
-- This migration creates all necessary tables and populates comprehensive test data
-- Add professor_id to projects table
ALTER TABLE projects
ADD COLUMN IF NOT EXISTS professor_id BIGINT DEFAULT 1;
-- Insert comprehensive test projects
INSERT INTO projects (id, name, description, professor_id, created_at)
VALUES (
        1000,
        'Proyecto Sistemas Distribuidos',
        'Implementación completa de sistema de microservicios con Spring Boot, Docker y Kubernetes',
        1,
        NOW() - INTERVAL '60 days'
    ),
    (
        1001,
        'Proyecto Base de Datos Avanzadas',
        'Diseño e implementación de base de datos NoSQL con MongoDB y Redis',
        1,
        NOW() - INTERVAL '50 days'
    ),
    (
        1002,
        'Proyecto Desarrollo Web Full-Stack',
        'Aplicación web completa con React, Node.js y PostgreSQL',
        1,
        NOW() - INTERVAL '40 days'
    );
-- Insert comprehensive test teams
INSERT INTO teams (id, name, project_id, created_at)
VALUES (
        10,
        'Equipo Alpha - Microservicios',
        1000,
        NOW() - INTERVAL '55 days'
    ),
    (
        20,
        'Equipo Beta - Bases de Datos',
        1001,
        NOW() - INTERVAL '50 days'
    ),
    (
        30,
        'Equipo Gamma - Full-Stack',
        1002,
        NOW() - INTERVAL '40 days'
    ),
    (
        40,
        'Equipo Delta - Microservicios',
        1000,
        NOW() - INTERVAL '55 days'
    );
-- Update sequences for projects and teams
SELECT setval(
        'projects_id_seq',
        (
            SELECT MAX(id)
            FROM projects
        )
    );
SELECT setval(
        'teams_id_seq',
        (
            SELECT MAX(id)
            FROM teams
        )
    );
-- Create team_members table for student-team relationships
CREATE TABLE IF NOT EXISTS team_members (
    id BIGSERIAL PRIMARY KEY,
    team_id BIGINT NOT NULL REFERENCES teams(id) ON DELETE CASCADE,
    student_id BIGINT NOT NULL,
    joined_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(team_id, student_id)
);
-- Ensure indexes exist
CREATE INDEX IF NOT EXISTS idx_projects_professor ON projects(professor_id);
CREATE INDEX IF NOT EXISTS idx_team_members_student ON team_members(student_id);
CREATE INDEX IF NOT EXISTS idx_team_members_team ON team_members(team_id);
-- Insert comprehensive team member assignments
INSERT INTO team_members (team_id, student_id, joined_at)
VALUES -- Team 10 (Equipo Alpha - 3 members)
    (10, 101, NOW() - INTERVAL '55 days'),
    (10, 102, NOW() - INTERVAL '55 days'),
    (10, 103, NOW() - INTERVAL '55 days'),
    -- Team 20 (Equipo Beta - 3 members)
    (20, 104, NOW() - INTERVAL '50 days'),
    (20, 105, NOW() - INTERVAL '50 days'),
    (20, 106, NOW() - INTERVAL '50 days'),
    -- Team 30 (Equipo Gamma - 3 members)
    (30, 107, NOW() - INTERVAL '40 days'),
    (30, 108, NOW() - INTERVAL '40 days'),
    (30, 109, NOW() - INTERVAL '40 days'),
    -- Team 40 (Equipo Delta - 2 members)
    (40, 110, NOW() - INTERVAL '55 days'),
    (40, 111, NOW() - INTERVAL '55 days');
-- Update team_reports to use consistent professor_id
UPDATE team_reports
SET professor_id = 1
WHERE professor_id IS NULL
    OR professor_id IN (100, 101);
-- Update student_reports to match team members and projects
UPDATE student_reports
SET student_id = 101,
    project_id = 1000
WHERE id = 1;
UPDATE student_reports
SET student_id = 102,
    project_id = 1000
WHERE id = 2;
UPDATE student_reports
SET student_id = 104,
    project_id = 1001
WHERE id = 3;