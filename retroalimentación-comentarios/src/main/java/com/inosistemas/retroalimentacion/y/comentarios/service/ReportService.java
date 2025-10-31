package com.inosistemas.retroalimentacion.y.comentarios.service;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;

@Service
public class ReportService {

    private final JdbcTemplate jdbc;
    private final AuthorizationService authz;

    public ReportService(JdbcTemplate jdbc, AuthorizationService authz) {
        this.jdbc = jdbc;
        this.authz = authz;
    }

    public Map<String, Object> studentProjectReport(long studentId, long projectId) {
        if (!authz.canAccessProjectAsStudent(studentId, projectId)) throw new SecurityException("Acceso denegado");

        Map<String, Object> project = jdbc.queryForMap("select id, name, description from projects where id = ?", projectId);

        List<Map<String, Object>> feedback = jdbc.queryForList(
                "select f.id, f.content, f.created_at, f.author_id, coalesce(f.project_id, f.task_id, f.delivery_id) as scope_id, " +
                        "case when f.project_id is not null then 'project' when f.task_id is not null then 'task' else 'delivery' end as scope " +
                        "from feedback f " +
                        "left join deliveries d on d.id = f.delivery_id " +
                        "left join tasks ta on ta.id = f.task_id " +
                        "left join deliveries dt on dt.id = ta.id_delivery " +
                        "left join teams t on t.id = coalesce(d.team_id, dt.team_id) " +
                        "where (f.project_id = ? or t.project_id = ?) and f.is_deleted = false order by f.created_at asc",
                projectId, projectId);

        return Map.of("project", project, "feedback", feedback);
    }

    public Map<String, Object> teamReportForProfessor(long professorId, long teamId) {
        Long projectId = jdbc.queryForObject("select project_id from teams where id = ?", Long.class, teamId);
        if (projectId == null || !authz.canAccessProjectAsProfessor(professorId, projectId)) throw new SecurityException("Acceso denegado");

        Map<String, Object> team = jdbc.queryForMap("select id, name, project_id from teams where id = ?", teamId);
        List<Map<String, Object>> deliveries = jdbc.queryForList("select id, title, created_at from deliveries where team_id = ? order by created_at asc", teamId);
        List<Map<String, Object>> feedback = jdbc.queryForList(
                "select f.id, f.content, f.created_at, f.author_id, f.delivery_id from feedback f join deliveries d on d.id = f.delivery_id where d.team_id = ? and f.is_deleted = false order by f.created_at asc",
                teamId);
        return Map.of("team", team, "deliveries", deliveries, "feedback", feedback);
    }
}


