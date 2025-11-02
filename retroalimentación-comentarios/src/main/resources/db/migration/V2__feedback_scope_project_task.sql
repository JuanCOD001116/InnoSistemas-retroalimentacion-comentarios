-- Extend feedback to support project-level and task-level scopes in addition to delivery
-- This migration assumes V1 created the feedback table
-- Adds support for feedback on projects and tasks, not just deliveries
-- ==============================================
-- 1. Apply alterations (idempotent)
-- ==============================================
-- Add project_id and task_id columns to feedback table
ALTER TABLE feedback
ADD COLUMN IF NOT EXISTS project_id BIGINT REFERENCES projects(id) ON DELETE CASCADE,
  ADD COLUMN IF NOT EXISTS task_id BIGINT REFERENCES tasks(id) ON DELETE CASCADE;
-- ==============================================
-- 2. Create indexes (idempotent)
-- ==============================================
-- Performance indexes for querying feedback by project or task
CREATE INDEX IF NOT EXISTS idx_feedback_project_time ON feedback (project_id, created_at);
CREATE INDEX IF NOT EXISTS idx_feedback_task_time ON feedback (task_id, created_at);