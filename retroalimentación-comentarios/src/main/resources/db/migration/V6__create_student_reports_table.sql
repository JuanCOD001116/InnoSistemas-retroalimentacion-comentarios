-- V6: Create student_reports table for storing consolidated student evaluation reports
-- This migration supports the student final report user story with 6 Gherkin scenarios
-- Create student_reports table
CREATE TABLE IF NOT EXISTS student_reports (
    id BIGSERIAL PRIMARY KEY,
    student_id BIGINT NOT NULL,
    project_id BIGINT NOT NULL,
    title VARCHAR(255) NOT NULL,
    summary TEXT,
    final_grade NUMERIC(5, 2),
    report_data JSONB NOT NULL,
    generated_at TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    -- Ensure one report per student per project (can regenerate to update)
    CONSTRAINT uk_student_project UNIQUE (student_id, project_id)
);
-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_student_reports_student ON student_reports(student_id);
CREATE INDEX IF NOT EXISTS idx_student_reports_project ON student_reports(project_id);
CREATE INDEX IF NOT EXISTS idx_student_reports_generated_at ON student_reports(generated_at);
-- Composite index for filtered queries
CREATE INDEX IF NOT EXISTS idx_student_reports_filter ON student_reports(student_id, project_id, generated_at);
-- GIN index for JSONB queries (if needed for advanced search)
CREATE INDEX IF NOT EXISTS idx_student_reports_data ON student_reports USING GIN (report_data);
-- Comments for documentation
COMMENT ON TABLE student_reports IS 'Stores consolidated final evaluation reports for students with feedback, grades, and statistics';
COMMENT ON COLUMN student_reports.report_data IS 'JSONB containing full report structure: deliveries, feedback, responses, and statistics';
COMMENT ON COLUMN student_reports.final_grade IS 'Calculated final grade (0-100) based on task completion, feedback engagement, and deliveries';