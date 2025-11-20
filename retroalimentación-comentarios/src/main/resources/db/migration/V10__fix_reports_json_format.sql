-- V10: Delete malformed reports with snake_case JSON
-- The system will generate new reports with correct camelCase format
-- Delete team reports that have snake_case fields in JSON
DELETE FROM team_reports
WHERE report_data::text LIKE '%team_id%'
    OR report_data::text LIKE '%project_id%'
    OR report_data::text LIKE '%team_members%';
-- Delete student reports that have snake_case fields in JSON
DELETE FROM student_reports
WHERE report_data::text LIKE '%student_id%'
    OR report_data::text LIKE '%project_id%'
    OR report_data::text LIKE '%feedbacks_received%';
-- Note: The application will regenerate these reports with correct camelCase format
-- when the respective endpoints are called (POST /team-reports/generate, POST /student-reports/generate)