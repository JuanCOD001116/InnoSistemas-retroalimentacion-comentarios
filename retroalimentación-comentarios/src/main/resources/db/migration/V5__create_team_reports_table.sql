-- Migration V5: Create team_reports table
-- Purpose: Store generated team evaluation reports with JSONB data
CREATE TABLE IF NOT EXISTS team_reports (
    id BIGSERIAL PRIMARY KEY,
    team_id BIGINT NOT NULL,
    professor_id BIGINT NOT NULL,
    course_id BIGINT NOT NULL,
    title VARCHAR(255) NOT NULL,
    summary TEXT,
    report_data JSONB NOT NULL,
    generated_at TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
-- Indexes for common queries
CREATE INDEX idx_team_reports_team_id ON team_reports(team_id);
CREATE INDEX idx_team_reports_professor_id ON team_reports(professor_id);
CREATE INDEX idx_team_reports_course_id ON team_reports(course_id);
CREATE INDEX idx_team_reports_generated_at ON team_reports(generated_at);
-- Index for filtering queries (professor + course + team + date)
CREATE INDEX idx_team_reports_filters ON team_reports(professor_id, course_id, team_id, generated_at);
-- GIN index for JSONB queries (if needed for searching report_data)
CREATE INDEX idx_team_reports_data ON team_reports USING GIN (report_data);
COMMENT ON TABLE team_reports IS 'Stores generated team evaluation reports with consolidated project, feedback, and statistics data';
COMMENT ON COLUMN team_reports.report_data IS 'JSONB column containing full report structure (projects, feedbacks, statistics)';