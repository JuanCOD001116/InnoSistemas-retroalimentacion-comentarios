package com.inosistemas.retroalimentacion.y.comentarios.service;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;

@Service
public class AuthorizationService {

    private final JdbcTemplate jdbcTemplate;

    public AuthorizationService(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    public boolean canAccessDeliveryAsProfessor(long userId, long deliveryId) {
        String sql = "SELECT 1 FROM deliveries d " +
                "JOIN teams t ON t.id = d.team_id " +
                "JOIN projects p ON p.id = t.project_id " +
                "JOIN course_teachers ct ON ct.course_id = p.course_id " +
                "WHERE d.id = ? AND ct.teacher_id = ? LIMIT 1";
        Integer result = jdbcTemplate.queryForObject(sql, Integer.class, deliveryId, userId);
        return result != null;
    }

    public boolean canAccessDeliveryAsStudent(long userId, long deliveryId) {
        String sql = "SELECT 1 FROM deliveries d " +
                "JOIN teams t ON t.id = d.team_id " +
                "JOIN team_members tm ON tm.team_id = t.id " +
                "WHERE d.id = ? AND tm.student_id = ? LIMIT 1";
        Integer result = jdbcTemplate.queryForObject(sql, Integer.class, deliveryId, userId);
        return result != null;
    }

    public boolean canAccessProjectAsProfessor(long userId, long projectId) {
        String sql = "SELECT 1 FROM projects p " +
                "JOIN course_teachers ct ON ct.course_id = p.course_id " +
                "WHERE p.id = ? AND ct.teacher_id = ? LIMIT 1";
        Integer result = jdbcTemplate.queryForObject(sql, Integer.class, projectId, userId);
        return result != null;
    }

    public boolean canAccessProjectAsStudent(long userId, long projectId) {
        String sql = "SELECT 1 FROM projects p " +
                "JOIN teams t ON t.project_id = p.id " +
                "JOIN team_members tm ON tm.team_id = t.id " +
                "WHERE p.id = ? AND tm.student_id = ? LIMIT 1";
        Integer result = jdbcTemplate.queryForObject(sql, Integer.class, projectId, userId);
        return result != null;
    }

    public boolean canAccessTaskAsProfessor(long userId, long taskId) {
        String sql = "SELECT 1 FROM tasks ta " +
                "JOIN deliveries d ON d.id = ta.id_delivery " +
                "JOIN teams t ON t.id = d.team_id " +
                "JOIN projects p ON p.id = t.project_id " +
                "JOIN course_teachers ct ON ct.course_id = p.course_id " +
                "WHERE ta.id = ? AND ct.teacher_id = ? LIMIT 1";
        Integer result = jdbcTemplate.queryForObject(sql, Integer.class, taskId, userId);
        return result != null;
    }

    public boolean canAccessTaskAsStudent(long userId, long taskId) {
        String sql = "SELECT 1 FROM tasks ta " +
                "JOIN deliveries d ON d.id = ta.id_delivery " +
                "JOIN teams t ON t.id = d.team_id " +
                "JOIN team_members tm ON tm.team_id = t.id " +
                "WHERE ta.id = ? AND (tm.student_id = ? OR ta.assignee_id = ?) LIMIT 1";
        Integer result = jdbcTemplate.queryForObject(sql, Integer.class, taskId, userId, userId);
        return result != null;
    }
}


