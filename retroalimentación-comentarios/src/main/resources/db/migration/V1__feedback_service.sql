-- Feedback service: schema initialization and enhancements
-- Creates base tables if they don't exist, then applies alterations and indexes
-- ==============================================
-- 1. Create base tables (if not exist)
-- ==============================================
-- Feedback table (base structure)
CREATE TABLE IF NOT EXISTS feedback (
  id BIGSERIAL PRIMARY KEY,
  content TEXT NOT NULL,
  author_id BIGINT NOT NULL,
  project_id BIGINT,
  task_id BIGINT,
  delivery_id BIGINT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ,
  edited BOOLEAN NOT NULL DEFAULT FALSE,
  is_deleted BOOLEAN NOT NULL DEFAULT FALSE,
  CONSTRAINT chk_feedback_scope CHECK (
    (
      project_id IS NOT NULL
      AND task_id IS NULL
      AND delivery_id IS NULL
    )
    OR (
      project_id IS NULL
      AND task_id IS NOT NULL
      AND delivery_id IS NULL
    )
    OR (
      project_id IS NULL
      AND task_id IS NULL
      AND delivery_id IS NOT NULL
    )
  )
);
-- Feedback responses table (base structure)
CREATE TABLE IF NOT EXISTS feedback_responses (
  id BIGSERIAL PRIMARY KEY,
  feedback_id BIGINT NOT NULL,
  content TEXT NOT NULL,
  author_id BIGINT NOT NULL,
  delivery_id BIGINT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ,
  edited BOOLEAN NOT NULL DEFAULT FALSE,
  is_deleted BOOLEAN NOT NULL DEFAULT FALSE,
  CONSTRAINT fk_feedback_responses_feedback FOREIGN KEY (feedback_id) REFERENCES feedback(id) ON DELETE CASCADE
);
-- ==============================================
-- 2. Apply alterations (idempotent)
-- ==============================================
-- Add columns to feedback table if they don't exist
ALTER TABLE feedback
ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS edited BOOLEAN NOT NULL DEFAULT FALSE,
  ADD COLUMN IF NOT EXISTS is_deleted BOOLEAN NOT NULL DEFAULT FALSE;
-- Add columns to feedback_responses table if they don't exist
ALTER TABLE feedback_responses
ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS edited BOOLEAN NOT NULL DEFAULT FALSE,
  ADD COLUMN IF NOT EXISTS is_deleted BOOLEAN NOT NULL DEFAULT FALSE;
-- ==============================================
-- 3. Create indexes (idempotent)
-- ==============================================
-- Performance indexes for feedback
CREATE INDEX IF NOT EXISTS idx_feedback_delivery_time ON feedback (delivery_id, created_at);
CREATE INDEX IF NOT EXISTS idx_feedback_task_time ON feedback (task_id, created_at);
CREATE INDEX IF NOT EXISTS idx_feedback_project_time ON feedback (project_id, created_at);
CREATE INDEX IF NOT EXISTS idx_feedback_author ON feedback (author_id);
CREATE INDEX IF NOT EXISTS idx_feedback_not_deleted ON feedback (is_deleted)
WHERE is_deleted = FALSE;
-- Performance indexes for feedback_responses
CREATE INDEX IF NOT EXISTS idx_feedback_responses_feedback_time ON feedback_responses (feedback_id, created_at);
CREATE INDEX IF NOT EXISTS idx_feedback_responses_author ON feedback_responses (author_id);
CREATE INDEX IF NOT EXISTS idx_feedback_responses_not_deleted ON feedback_responses (is_deleted)
WHERE is_deleted = FALSE;
-- audit logs
CREATE TABLE IF NOT EXISTS audit_logs (
  id BIGSERIAL PRIMARY KEY,
  user_id BIGINT,
  action VARCHAR(64) NOT NULL,
  target_type VARCHAR(32) NOT NULL,
  target_id BIGINT,
  metadata JSONB,
  ip INET,
  user_agent TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_audit_logs_time ON audit_logs (created_at);
-- idempotency keys (optional)
CREATE TABLE IF NOT EXISTS idempotency_keys (
  idempotency_key VARCHAR(64) PRIMARY KEY,
  user_id BIGINT NOT NULL,
  response_body JSONB NOT NULL,
  status_code INT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);