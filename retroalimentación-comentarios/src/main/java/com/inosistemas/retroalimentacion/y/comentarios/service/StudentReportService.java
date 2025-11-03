package com.inosistemas.retroalimentacion.y.comentarios.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;
import com.inosistemas.retroalimentacion.y.comentarios.domain.*;
import com.inosistemas.retroalimentacion.y.comentarios.dto.StudentReportDTO;
import com.inosistemas.retroalimentacion.y.comentarios.repository.*;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Duration;
import java.time.OffsetDateTime;
import java.util.*;
import java.util.stream.Collectors;

@Service
public class StudentReportService {

    private final StudentReportRepository studentReportRepository;
    private final DeliveryRepository deliveryRepository;
    private final TaskRepository taskRepository;
    private final FeedbackRepository feedbackRepository;
    private final FeedbackResponseRepository feedbackResponseRepository;
    private final JdbcTemplate jdbcTemplate;
    private final ObjectMapper objectMapper;

    public StudentReportService(
            StudentReportRepository studentReportRepository,
            DeliveryRepository deliveryRepository,
            TaskRepository taskRepository,
            FeedbackRepository feedbackRepository,
            FeedbackResponseRepository feedbackResponseRepository,
            JdbcTemplate jdbcTemplate) {
        this.studentReportRepository = studentReportRepository;
        this.deliveryRepository = deliveryRepository;
        this.taskRepository = taskRepository;
        this.feedbackRepository = feedbackRepository;
        this.feedbackResponseRepository = feedbackResponseRepository;
        this.jdbcTemplate = jdbcTemplate;
        this.objectMapper = new ObjectMapper();
        this.objectMapper.registerModule(new JavaTimeModule());
    }

    /**
     * Generate a final consolidated report for a student in a specific project
     */
    @Transactional
    public StudentReportDTO generateStudentReport(Long studentId, Long projectId, String projectName) {
        // Get student's team for this project
        Long teamId = getStudentTeamId(studentId, projectId);
        if (teamId == null) {
            throw new RuntimeException("El estudiante no pertenece a ningún equipo en este proyecto");
        }

        // Get all deliveries for the student's team
        List<Delivery> deliveries = deliveryRepository.findByTeamId(teamId);

        // Build the report DTO
        StudentReportDTO dto = new StudentReportDTO();
        dto.setStudentId(studentId);
        dto.setStudentName("Estudiante " + studentId); // In real app, fetch from users table
        dto.setProjectId(projectId);
        dto.setProjectName(projectName);
        dto.setGeneratedAt(OffsetDateTime.now());

        // Generate delivery summaries
        dto.setDeliveries(generateDeliverySummaries(deliveries));

        // Generate feedback received
        dto.setFeedbackReceived(generateFeedbackItems(projectId, deliveries, studentId));

        // Generate responses given
        dto.setResponsesGiven(generateResponseItems(projectId, deliveries, studentId));

        // Generate statistics
        dto.setStatistics(generateStatistics(deliveries, dto.getFeedbackReceived(), dto.getResponsesGiven()));

        // Calculate final grade (placeholder - in real app, this would be calculated)
        dto.setFinalGrade(calculateFinalGrade(dto.getStatistics()));

        // Save the report
        StudentReport report = new StudentReport();
        report.setStudentId(studentId);
        report.setProjectId(projectId);
        report.setTitle("Reporte Final - " + projectName);
        report.setSummary(generateSummaryText(dto));
        report.setFinalGrade(dto.getFinalGrade());
        report.setGeneratedAt(dto.getGeneratedAt());

        try {
            String jsonData = objectMapper.writeValueAsString(dto);
            report.setReportData(jsonData);
        } catch (JsonProcessingException e) {
            throw new RuntimeException("Error al serializar el reporte", e);
        }

        StudentReport savedReport = studentReportRepository.save(report);
        dto.setId(savedReport.getId());

        return dto;
    }

    /**
     * Get a student report by ID with access control
     */
    public StudentReportDTO getReportById(Long reportId, Long studentId) {
        StudentReport report = studentReportRepository.findById(reportId)
                .orElseThrow(() -> new RuntimeException("Reporte no encontrado"));

        // Access control: student can only access their own reports
        if (!report.getStudentId().equals(studentId)) {
            throw new RuntimeException("Acceso denegado: no tienes permiso para ver este reporte");
        }

        return deserializeReport(report);
    }

    /**
     * List student reports with filters
     */
    public List<StudentReportDTO> listReports(Long studentId, Long projectId, OffsetDateTime fromDate) {
        List<StudentReport> reports = studentReportRepository.findByFilters(studentId, projectId, fromDate);
        return reports.stream()
                .map(this::deserializeReport)
                .collect(Collectors.toList());
    }

    /**
     * List reports for a specific student
     */
    public List<StudentReportDTO> listReportsByStudent(Long studentId) {
        List<StudentReport> reports = studentReportRepository.findByStudentIdOrderByGeneratedAtDesc(studentId);
        return reports.stream()
                .map(this::deserializeReport)
                .collect(Collectors.toList());
    }

    /**
     * Check if a student can view a report (Scenario 4: Access restriction)
     */
    public boolean canAccessReport(Long studentId, Long projectId) {
        Long teamId = getStudentTeamId(studentId, projectId);
        return teamId != null;
    }

    private Long getStudentTeamId(Long studentId, Long projectId) {
        String sql = "SELECT t.id FROM teams t " +
                "JOIN team_members tm ON tm.team_id = t.id " +
                "WHERE tm.student_id = ? AND t.project_id = ? LIMIT 1";
        try {
            return jdbcTemplate.queryForObject(sql, Long.class, studentId, projectId);
        } catch (Exception e) {
            return null;
        }
    }

    private List<StudentReportDTO.DeliverySummary> generateDeliverySummaries(List<Delivery> deliveries) {
        List<StudentReportDTO.DeliverySummary> summaries = new ArrayList<>();

        for (Delivery delivery : deliveries) {
            StudentReportDTO.DeliverySummary summary = new StudentReportDTO.DeliverySummary();
            summary.setDeliveryId(delivery.getId());
            summary.setDeliveryTitle(delivery.getTitle());
            summary.setSubmittedAt(delivery.getCreatedAt());

            // Get tasks for this delivery
            List<Task> tasks = taskRepository.findByDeliveryId(delivery.getId());
            summary.setTotalTasks(tasks.size());
            summary.setTasksCompleted((int) tasks.stream()
                    .filter(t -> "completed".equalsIgnoreCase(t.getStatus()))
                    .count());

            // Get feedback count for this delivery
            List<Feedback> feedbacks = feedbackRepository.findByDeliveryIdOrderByCreatedAtAsc(delivery.getId());
            summary.setFeedbackCount(feedbacks.size());

            summaries.add(summary);
        }

        return summaries;
    }

    private List<StudentReportDTO.FeedbackItem> generateFeedbackItems(Long projectId, List<Delivery> deliveries,
            Long studentId) {
        List<StudentReportDTO.FeedbackItem> feedbackItems = new ArrayList<>();

        // Feedback on project
        List<Feedback> projectFeedbacks = feedbackRepository.findByProjectIdOrderByCreatedAtAsc(projectId);
        for (Feedback feedback : projectFeedbacks) {
            StudentReportDTO.FeedbackItem item = new StudentReportDTO.FeedbackItem();
            item.setFeedbackId(feedback.getId());
            item.setContent(feedback.getContent());
            item.setCreatedAt(feedback.getCreatedAt());
            item.setScope("project");
            item.setScopeId(projectId);
            item.setScopeName("Proyecto");
            item.setAuthorId(feedback.getAuthorId());
            item.setAuthorName("Profesor " + feedback.getAuthorId());
            feedbackItems.add(item);
        }

        // Feedback on deliveries
        for (Delivery delivery : deliveries) {
            List<Feedback> deliveryFeedbacks = feedbackRepository.findByDeliveryIdOrderByCreatedAtAsc(delivery.getId());
            for (Feedback feedback : deliveryFeedbacks) {
                StudentReportDTO.FeedbackItem item = new StudentReportDTO.FeedbackItem();
                item.setFeedbackId(feedback.getId());
                item.setContent(feedback.getContent());
                item.setCreatedAt(feedback.getCreatedAt());
                item.setScope("delivery");
                item.setScopeId(delivery.getId());
                item.setScopeName(delivery.getTitle());
                item.setAuthorId(feedback.getAuthorId());
                item.setAuthorName("Profesor " + feedback.getAuthorId());
                feedbackItems.add(item);
            }

            // Feedback on tasks within this delivery
            List<Task> tasks = taskRepository.findByDeliveryId(delivery.getId());
            for (Task task : tasks) {
                List<Feedback> taskFeedbacks = feedbackRepository.findByTaskIdOrderByCreatedAtAsc(task.getId());
                for (Feedback feedback : taskFeedbacks) {
                    StudentReportDTO.FeedbackItem item = new StudentReportDTO.FeedbackItem();
                    item.setFeedbackId(feedback.getId());
                    item.setContent(feedback.getContent());
                    item.setCreatedAt(feedback.getCreatedAt());
                    item.setScope("task");
                    item.setScopeId(task.getId());
                    item.setScopeName(task.getTitle());
                    item.setAuthorId(feedback.getAuthorId());
                    item.setAuthorName("Profesor " + feedback.getAuthorId());
                    feedbackItems.add(item);
                }
            }
        }

        // Sort by creation date
        feedbackItems.sort(Comparator.comparing(StudentReportDTO.FeedbackItem::getCreatedAt));

        return feedbackItems;
    }

    private List<StudentReportDTO.ResponseItem> generateResponseItems(Long projectId, List<Delivery> deliveries,
            Long studentId) {
        List<StudentReportDTO.ResponseItem> responseItems = new ArrayList<>();

        // Get all feedback IDs
        Set<Long> feedbackIds = new HashSet<>();
        feedbackRepository.findByProjectIdOrderByCreatedAtAsc(projectId).forEach(f -> feedbackIds.add(f.getId()));
        for (Delivery delivery : deliveries) {
            feedbackRepository.findByDeliveryIdOrderByCreatedAtAsc(delivery.getId())
                    .forEach(f -> feedbackIds.add(f.getId()));
            List<Task> tasks = taskRepository.findByDeliveryId(delivery.getId());
            for (Task task : tasks) {
                feedbackRepository.findByTaskIdOrderByCreatedAtAsc(task.getId())
                        .forEach(f -> feedbackIds.add(f.getId()));
            }
        }

        // Get all responses by this student
        String sql = "SELECT fr.id, fr.feedback_id, fr.content, fr.created_at " +
                "FROM feedback_responses fr " +
                "WHERE fr.author_id = ? AND fr.feedback_id IN (" +
                feedbackIds.stream().map(String::valueOf).collect(Collectors.joining(",")) + ") " +
                "AND fr.is_deleted = false " +
                "ORDER BY fr.created_at ASC";

        if (!feedbackIds.isEmpty()) {
            List<Map<String, Object>> responses = jdbcTemplate.queryForList(sql, studentId);
            for (Map<String, Object> row : responses) {
                StudentReportDTO.ResponseItem item = new StudentReportDTO.ResponseItem();
                item.setResponseId(((Number) row.get("id")).longValue());
                item.setFeedbackId(((Number) row.get("feedback_id")).longValue());
                item.setContent((String) row.get("content"));
                // Convert Timestamp to OffsetDateTime
                Object createdAtObj = row.get("created_at");
                if (createdAtObj instanceof java.sql.Timestamp) {
                    item.setCreatedAt(((java.sql.Timestamp) createdAtObj).toInstant()
                            .atOffset(java.time.ZoneOffset.UTC));
                } else if (createdAtObj instanceof OffsetDateTime) {
                    item.setCreatedAt((OffsetDateTime) createdAtObj);
                }
                responseItems.add(item);
            }
        }

        return responseItems;
    }

    private StudentReportDTO.ReportStatistics generateStatistics(
            List<Delivery> deliveries,
            List<StudentReportDTO.FeedbackItem> feedbackItems,
            List<StudentReportDTO.ResponseItem> responseItems) {

        StudentReportDTO.ReportStatistics stats = new StudentReportDTO.ReportStatistics();

        stats.setTotalDeliveries(deliveries.size());
        stats.setTotalFeedbackReceived(feedbackItems.size());
        stats.setTotalResponsesGiven(responseItems.size());

        // Calculate total and completed tasks
        int totalTasks = 0;
        int completedTasks = 0;
        for (Delivery delivery : deliveries) {
            List<Task> tasks = taskRepository.findByDeliveryId(delivery.getId());
            totalTasks += tasks.size();
            completedTasks += (int) tasks.stream()
                    .filter(t -> "completed".equalsIgnoreCase(t.getStatus()))
                    .count();
        }
        stats.setTotalTasks(totalTasks);
        stats.setCompletedTasks(completedTasks);

        // Calculate task completion rate
        if (totalTasks > 0) {
            stats.setTaskCompletionRate((double) completedTasks / totalTasks * 100);
        } else {
            stats.setTaskCompletionRate(0.0);
        }

        // Calculate average response time
        double avgResponseTimeHours = 0.0;
        int responseCount = 0;
        for (StudentReportDTO.ResponseItem response : responseItems) {
            // Find the corresponding feedback
            Optional<StudentReportDTO.FeedbackItem> feedbackOpt = feedbackItems.stream()
                    .filter(f -> f.getFeedbackId().equals(response.getFeedbackId()))
                    .findFirst();

            if (feedbackOpt.isPresent()) {
                Duration duration = Duration.between(
                        feedbackOpt.get().getCreatedAt(),
                        response.getCreatedAt());
                avgResponseTimeHours += duration.toHours();
                responseCount++;
            }
        }

        if (responseCount > 0) {
            stats.setAverageResponseTimeHours(avgResponseTimeHours / responseCount);
        } else {
            stats.setAverageResponseTimeHours(0.0);
        }

        return stats;
    }

    private Double calculateFinalGrade(StudentReportDTO.ReportStatistics stats) {
        // Simple grading formula (can be customized)
        double grade = 0.0;

        // 40% for task completion
        if (stats.getTaskCompletionRate() != null) {
            grade += stats.getTaskCompletionRate() * 0.4;
        }

        // 30% for feedback engagement (max 100%)
        if (stats.getTotalFeedbackReceived() != null && stats.getTotalResponsesGiven() != null) {
            double engagementRate = Math.min(100.0,
                    (stats.getTotalResponsesGiven().doubleValue() / Math.max(1, stats.getTotalFeedbackReceived()))
                            * 100);
            grade += engagementRate * 0.3;
        }

        // 30% for deliveries submitted
        if (stats.getTotalDeliveries() != null && stats.getTotalDeliveries() > 0) {
            grade += 30.0; // Full points if at least one delivery
        }

        return Math.min(100.0, Math.round(grade * 10) / 10.0);
    }

    private String generateSummaryText(StudentReportDTO report) {
        StringBuilder summary = new StringBuilder();
        summary.append("Reporte final para estudiante ").append(report.getStudentName());
        summary.append(" en el proyecto ").append(report.getProjectName()).append(". ");

        if (report.getStatistics() != null) {
            StudentReportDTO.ReportStatistics stats = report.getStatistics();
            summary.append("Entregas realizadas: ").append(stats.getTotalDeliveries()).append(". ");
            summary.append("Tareas completadas: ").append(stats.getCompletedTasks())
                    .append(" de ").append(stats.getTotalTasks()).append(". ");
            summary.append("Retroalimentaciones recibidas: ").append(stats.getTotalFeedbackReceived()).append(". ");
            summary.append("Respuestas dadas: ").append(stats.getTotalResponsesGiven()).append(". ");
        }

        if (report.getFinalGrade() != null) {
            summary.append("Calificación final: ").append(report.getFinalGrade()).append("/100");
        }

        return summary.toString();
    }

    private StudentReportDTO deserializeReport(StudentReport report) {
        try {
            StudentReportDTO dto = objectMapper.readValue(report.getReportData(), StudentReportDTO.class);
            dto.setId(report.getId());
            return dto;
        } catch (JsonProcessingException e) {
            throw new RuntimeException("Error al deserializar el reporte", e);
        }
    }
}
