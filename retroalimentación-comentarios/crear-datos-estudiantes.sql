-- Add team_members table and test data for student reports
-- Create team_members table if it doesn't exist
CREATE TABLE IF NOT EXISTS team_members (
    id BIGSERIAL PRIMARY KEY,
    team_id BIGINT NOT NULL REFERENCES teams(id) ON DELETE CASCADE,
    student_id BIGINT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uk_team_student UNIQUE (team_id, student_id)
);
-- Insert test students into teams
INSERT INTO team_members (team_id, student_id, created_at)
VALUES (1, 200, NOW() - INTERVAL '30 days'),
    -- Student 200 in Team 1 (Backend)
    (1, 201, NOW() - INTERVAL '30 days'),
    -- Student 201 in Team 1 (Backend)
    (2, 202, NOW() - INTERVAL '30 days'),
    -- Student 202 in Team 2 (Frontend)
    (2, 203, NOW() - INTERVAL '30 days') -- Student 203 in Team 2 (Frontend)
    ON CONFLICT (team_id, student_id) DO NOTHING;
-- Add some feedback responses from students
INSERT INTO feedback_responses (feedback_id, content, author_id, created_at)
SELECT f.id,
    'Gracias por el feedback, ya lo corregí',
    200,
    f.created_at + INTERVAL '2 hours'
FROM feedback f
WHERE f.delivery_id = 1
    AND f.id NOT IN (
        SELECT feedback_id
        FROM feedback_responses
        WHERE author_id = 200
    )
LIMIT 2;
INSERT INTO feedback_responses (feedback_id, content, author_id, created_at)
SELECT f.id,
    'Entendido, trabajaré en eso',
    202,
    f.created_at + INTERVAL '1 day'
FROM feedback f
WHERE f.delivery_id = 2
    AND f.id NOT IN (
        SELECT feedback_id
        FROM feedback_responses
        WHERE author_id = 202
    )
LIMIT 1;
-- Show summary
SELECT 'Team Members' as tabla,
    COUNT(*) as total
FROM team_members
UNION ALL
SELECT 'Student Responses',
    COUNT(*)
FROM feedback_responses
WHERE author_id IN (200, 201, 202, 203);