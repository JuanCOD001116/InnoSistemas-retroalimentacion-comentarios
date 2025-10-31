-- Feedback service minimal alterations and additional tables

-- feedback table alterations
ALTER TABLE IF EXISTS feedback
  ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS edited BOOLEAN NOT NULL DEFAULT FALSE,
  ADD COLUMN IF NOT EXISTS is_deleted BOOLEAN NOT NULL DEFAULT FALSE;

CREATE INDEX IF NOT EXISTS idx_feedback_delivery_time ON feedback (delivery_id, created_at);

-- feedback_responses table alterations
ALTER TABLE IF EXISTS feedback_responses
  ADD COLUMN IF NOT EXISTS is_deleted BOOLEAN NOT NULL DEFAULT FALSE;

CREATE INDEX IF NOT EXISTS idx_feedback_responses_feedback_time ON feedback_responses (feedback_id, created_at);

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


