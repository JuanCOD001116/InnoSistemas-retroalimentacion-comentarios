-- Refactor: Change tasks relationship from projects to deliveries
-- Tasks are now related to deliveries instead of projects
-- This migration ensures base tables exist before applying schema changes
-- ==============================================
-- 1. Create base tables (if not exist)
-- ==============================================
-- Projects table (base structure for context)
CREATE TABLE IF NOT EXISTS projects (
  id BIGSERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  description TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ
);
-- Teams table (base structure for context)
CREATE TABLE IF NOT EXISTS teams (
  id BIGSERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  project_id BIGINT REFERENCES projects(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
-- Deliveries table (base structure)
CREATE TABLE IF NOT EXISTS deliveries (
  id BIGSERIAL PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  description TEXT,
  team_id BIGINT REFERENCES teams(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ
);
-- Tasks table (base structure with delivery relationship)
CREATE TABLE IF NOT EXISTS tasks (
  id BIGSERIAL PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  description TEXT,
  id_delivery BIGINT REFERENCES deliveries(id) ON DELETE CASCADE,
  status VARCHAR(50) NOT NULL DEFAULT 'pending',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ
);
-- ==============================================
-- 2. Apply alterations (idempotent)
-- ==============================================
-- Ensure tasks table has id_delivery column (migration from old schema if needed)
ALTER TABLE tasks
ADD COLUMN IF NOT EXISTS id_delivery BIGINT REFERENCES deliveries(id) ON DELETE CASCADE;
-- Remove the old project relationship if it exists
-- This assumes migration from an old schema where tasks referenced projects directly
ALTER TABLE tasks DROP COLUMN IF EXISTS id_project;
-- ==============================================
-- 3. Create indexes (idempotent)
-- ==============================================
-- Performance indexes for the new relationships
CREATE INDEX IF NOT EXISTS idx_tasks_delivery ON tasks (id_delivery);
CREATE INDEX IF NOT EXISTS idx_deliveries_team ON deliveries (team_id);
CREATE INDEX IF NOT EXISTS idx_teams_project ON teams (project_id);
-- Drop old indexes if they exist (cleanup from old schema)
DROP INDEX IF EXISTS idx_tasks_project;