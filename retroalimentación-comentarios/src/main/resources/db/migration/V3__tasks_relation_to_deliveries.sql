-- Refactor: Change tasks relationship from projects to deliveries
-- Tasks are now related to deliveries instead of projects

-- Ensure tasks table has id_delivery column (if it doesn't exist in base schema)
ALTER TABLE IF EXISTS tasks
  ADD COLUMN IF NOT EXISTS id_delivery INTEGER REFERENCES deliveries(id) ON DELETE CASCADE;

-- Create index for the new relationship
CREATE INDEX IF NOT EXISTS idx_tasks_delivery ON tasks (id_delivery);

-- Remove the old project relationship if it exists
-- Note: This migration assumes tasks should now only relate to deliveries
-- If id_project column exists, we'll remove it after ensuring data migration is handled
-- Uncomment the following if you need to remove id_project:
-- ALTER TABLE IF EXISTS tasks DROP COLUMN IF EXISTS id_project;

-- Drop old index if it exists (assuming it was idx_tasks_project or similar)
-- DROP INDEX IF EXISTS idx_tasks_project;

