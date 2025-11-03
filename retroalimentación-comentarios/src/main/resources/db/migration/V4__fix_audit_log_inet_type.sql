-- Fix audit_logs.ip column type from INET to VARCHAR
-- This resolves Hibernate compatibility issues with PostgreSQL INET type
-- ==============================================
-- Change ip column from INET to VARCHAR(45)
-- VARCHAR(45) is sufficient for both IPv4 (15 chars) and IPv6 (39 chars)
ALTER TABLE audit_logs
ALTER COLUMN ip TYPE VARCHAR(45) USING ip::VARCHAR;
-- Add comment for documentation
COMMENT ON COLUMN audit_logs.ip IS 'Client IP address (IPv4 or IPv6 format)';