-- V15: Add student 2 to team 301 (project 201)
-- This migration allows student 2 to generate and download reports for project 201
-- Add student 2 to team 301 (project 201)
INSERT INTO team_members (team_id, student_id, joined_at)
VALUES (301, 2, NOW() - INTERVAL '45 days') ON CONFLICT (team_id, student_id) DO NOTHING;
-- Verify the insertion
-- This comment serves as documentation that student 2 is now part of team 301
-- Team 301 belongs to project 201, so student 2 can now:
-- - Generate student reports for project 201
-- - Download student reports for project 201
-- - View feedback and responses for deliveries in team 301