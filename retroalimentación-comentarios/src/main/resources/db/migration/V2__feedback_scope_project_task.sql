-- Extend feedback to support project-level and task-level scopes in addition to delivery

ALTER TABLE IF EXISTS feedback
  ADD COLUMN IF NOT EXISTS project_id INTEGER REFERENCES projects(id) ON DELETE CASCADE,
  ADD COLUMN IF NOT EXISTS task_id INTEGER REFERENCES tasks(id) ON DELETE CASCADE;

CREATE INDEX IF NOT EXISTS idx_feedback_project_time ON feedback (project_id, created_at);
CREATE INDEX IF NOT EXISTS idx_feedback_task_time ON feedback (task_id, created_at);


