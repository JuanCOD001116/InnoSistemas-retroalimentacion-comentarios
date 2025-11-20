-- V11: Add courses table and fix team_reports course_id requirement
-- Create courses table
CREATE TABLE IF NOT EXISTS courses (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    professor_id BIGINT NOT NULL DEFAULT 1,
    start_date TIMESTAMPTZ,
    end_date TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
-- Insert sample courses
INSERT INTO courses (
        id,
        name,
        description,
        professor_id,
        start_date,
        end_date
    )
VALUES (
        100,
        'Sistemas Distribuidos 2025-1',
        'Curso avanzado de arquitecturas distribuidas, microservicios y contenedores',
        1,
        '2025-01-15',
        '2025-05-30'
    ),
    (
        101,
        'Arquitectura de Software 2025-1',
        'Patrones de diseño, principios SOLID y arquitecturas modernas',
        1,
        '2025-01-15',
        '2025-05-30'
    ),
    (
        102,
        'Bases de Datos Avanzadas 2025-1',
        'Optimización, diseño de esquemas y bases de datos NoSQL',
        1,
        '2025-01-15',
        '2025-05-30'
    );
-- Add course_id to projects table
ALTER TABLE projects
ADD COLUMN IF NOT EXISTS course_id BIGINT DEFAULT 100;
-- Update existing projects with course_id
UPDATE projects
SET course_id = 100
WHERE id = 1000;
UPDATE projects
SET course_id = 101
WHERE id = 1001;
UPDATE projects
SET course_id = 102
WHERE id = 1002;
-- Make course_id NOT NULL now that data exists
ALTER TABLE projects
ALTER COLUMN course_id
SET NOT NULL;
-- Add foreign key constraint
ALTER TABLE projects
ADD CONSTRAINT fk_projects_course FOREIGN KEY (course_id) REFERENCES courses(id);
-- Create index on projects.course_id
CREATE INDEX IF NOT EXISTS idx_projects_course_id ON projects(course_id);
-- Add team_reports foreign key for course_id
ALTER TABLE team_reports
ADD CONSTRAINT fk_team_reports_course FOREIGN KEY (course_id) REFERENCES courses(id);
-- Add student_reports foreign key if needed (assuming students need course context)
ALTER TABLE student_reports
ADD COLUMN IF NOT EXISTS course_id BIGINT;
UPDATE student_reports sr
SET course_id = p.course_id
FROM projects p
WHERE sr.project_id = p.id
    AND sr.course_id IS NULL;
-- Create indexes for courses
CREATE INDEX IF NOT EXISTS idx_courses_professor_id ON courses(professor_id);
CREATE INDEX IF NOT EXISTS idx_courses_dates ON courses(start_date, end_date);
COMMENT ON TABLE courses IS 'Academic courses taught by professors containing multiple projects';
COMMENT ON COLUMN projects.course_id IS 'References the course this project belongs to';