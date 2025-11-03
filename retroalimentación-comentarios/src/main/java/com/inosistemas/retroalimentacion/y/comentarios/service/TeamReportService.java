package com.inosistemas.retroalimentacion.y.comentarios.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;
import com.inosistemas.retroalimentacion.y.comentarios.domain.*;
import com.inosistemas.retroalimentacion.y.comentarios.dto.TeamReportDTO;
import com.inosistemas.retroalimentacion.y.comentarios.dto.TeamReportDTO.*;
import com.inosistemas.retroalimentacion.y.comentarios.repository.*;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Duration;
import java.time.OffsetDateTime;
import java.util.*;
import java.util.stream.Collectors;

@Service
public class TeamReportService {

    private final TeamReportRepository teamReportRepository;
    private final DeliveryRepository deliveryRepository;
    private final TaskRepository taskRepository;
    private final FeedbackRepository feedbackRepository;
    private final FeedbackResponseRepository responseRepository;
    private final ObjectMapper objectMapper;

    public TeamReportService(TeamReportRepository teamReportRepository,
            DeliveryRepository deliveryRepository,
            TaskRepository taskRepository,
            FeedbackRepository feedbackRepository,
            FeedbackResponseRepository responseRepository) {
        this.teamReportRepository = teamReportRepository;
        this.deliveryRepository = deliveryRepository;
        this.taskRepository = taskRepository;
        this.feedbackRepository = feedbackRepository;
        this.responseRepository = responseRepository;
        this.objectMapper = new ObjectMapper();
        this.objectMapper.registerModule(new JavaTimeModule());
    }

    /**
     * Genera un reporte completo de evaluación del equipo
     */
    @Transactional
    public TeamReportDTO generateTeamReport(Long teamId, Long professorId, Long courseId, String courseName) {
        try {
            // Crear DTO del reporte
            TeamReportDTO reportDTO = new TeamReportDTO();
            reportDTO.setTeamId(teamId);
            reportDTO.setTeamName("Equipo " + teamId); // TODO: obtener nombre real del equipo
            reportDTO.setCourseId(courseId);
            reportDTO.setCourseName(courseName);
            reportDTO.setProfessorId(professorId);
            reportDTO.setProfessorName("Profesor " + professorId); // TODO: obtener nombre real
            reportDTO.setGeneratedAt(OffsetDateTime.now());

            // Obtener entregas del equipo
            List<Delivery> deliveries = deliveryRepository.findByTeamId(teamId);

            // Generar resumen de proyectos
            List<ProjectSummary> projectSummaries = generateProjectSummaries(deliveries);
            reportDTO.setProjects(projectSummaries);

            // Generar resumen de feedbacks
            List<FeedbackSummary> feedbackSummaries = generateFeedbackSummaries(deliveries);
            reportDTO.setFeedbacks(feedbackSummaries);

            // Generar estadísticas
            ReportStatistics statistics = generateStatistics(deliveries);
            reportDTO.setStatistics(statistics);

            // Guardar en base de datos
            TeamReport report = new TeamReport();
            report.setTeamId(teamId);
            report.setProfessorId(professorId);
            report.setCourseId(courseId);
            report.setTitle("Reporte de Evaluación - " + courseName + " - " + reportDTO.getTeamName());
            report.setSummary(generateSummaryText(reportDTO));
            report.setReportData(objectMapper.writeValueAsString(reportDTO));
            report.setGeneratedAt(OffsetDateTime.now());

            TeamReport savedReport = teamReportRepository.save(report);
            reportDTO.setId(savedReport.getId());

            return reportDTO;

        } catch (JsonProcessingException e) {
            throw new RuntimeException("Error al generar el reporte: " + e.getMessage(), e);
        }
    }

    /**
     * Genera resumen de proyectos
     */
    private List<ProjectSummary> generateProjectSummaries(List<Delivery> deliveries) {
        // Agrupar por proyecto (usando el primer proyecto encontrado o un mock)
        Map<Long, List<Delivery>> byProject = new HashMap<>();
        for (Delivery delivery : deliveries) {
            Long projectId = 1L; // Mock: asumimos proyecto 1
            byProject.computeIfAbsent(projectId, k -> new ArrayList<>()).add(delivery);
        }

        List<ProjectSummary> summaries = new ArrayList<>();
        for (Map.Entry<Long, List<Delivery>> entry : byProject.entrySet()) {
            ProjectSummary summary = new ProjectSummary();
            summary.setProjectId(entry.getKey());
            summary.setProjectName("Proyecto " + entry.getKey());
            summary.setDeliveriesCount(entry.getValue().size());

            // Contar tareas
            int totalTasks = 0;
            int completedTasks = 0;
            OffsetDateTime lastDate = null;

            for (Delivery delivery : entry.getValue()) {
                List<Task> tasks = taskRepository.findByDeliveryId(delivery.getId());
                totalTasks += tasks.size();
                completedTasks += (int) tasks.stream()
                        .filter(t -> "completed".equalsIgnoreCase(t.getStatus()))
                        .count();

                if (lastDate == null || delivery.getCreatedAt().isAfter(lastDate)) {
                    lastDate = delivery.getCreatedAt();
                }
            }

            summary.setTotalTasks(totalTasks);
            summary.setCompletedTasks(completedTasks);
            summary.setLastDeliveryDate(lastDate);

            summaries.add(summary);
        }

        return summaries;
    }

    /**
     * Genera resumen de feedbacks por categoría
     */
    private List<FeedbackSummary> generateFeedbackSummaries(List<Delivery> deliveries) {
        List<FeedbackSummary> summaries = new ArrayList<>();

        // Contar feedbacks por scope
        int deliveryFeedbacks = 0;
        int taskFeedbacks = 0;
        int projectFeedbacks = 0;

        for (Delivery delivery : deliveries) {
            deliveryFeedbacks += feedbackRepository.countByDeliveryId(delivery.getId());

            List<Task> tasks = taskRepository.findByDeliveryId(delivery.getId());
            for (Task task : tasks) {
                taskFeedbacks += feedbackRepository.countByTaskId(task.getId());
            }
        }

        if (deliveryFeedbacks > 0) {
            FeedbackSummary summary = new FeedbackSummary();
            summary.setCategory("Entregas");
            summary.setCount(deliveryFeedbacks);
            summary.setMostCommonTopic("Calidad del código");
            summaries.add(summary);
        }

        if (taskFeedbacks > 0) {
            FeedbackSummary summary = new FeedbackSummary();
            summary.setCategory("Tareas");
            summary.setCount(taskFeedbacks);
            summary.setMostCommonTopic("Implementación técnica");
            summaries.add(summary);
        }

        return summaries;
    }

    /**
     * Genera estadísticas generales
     */
    private ReportStatistics generateStatistics(List<Delivery> deliveries) {
        ReportStatistics stats = new ReportStatistics();
        stats.setTotalDeliveries(deliveries.size());

        int totalFeedbacks = 0;
        int totalResponses = 0;
        int pendingDeliveries = 0;
        List<Duration> responseTimes = new ArrayList<>();

        for (Delivery delivery : deliveries) {
            List<Feedback> feedbacks = feedbackRepository.findByDeliveryId(delivery.getId());
            totalFeedbacks += feedbacks.size();

            if (feedbacks.isEmpty()) {
                pendingDeliveries++;
            }

            for (Feedback feedback : feedbacks) {
                List<FeedbackResponse> responses = responseRepository.findByFeedbackId(feedback.getId());
                totalResponses += responses.size();

                // Calcular tiempo de respuesta
                for (FeedbackResponse response : responses) {
                    Duration duration = Duration.between(feedback.getCreatedAt(), response.getCreatedAt());
                    responseTimes.add(duration);
                }
            }

            // También contar feedbacks de tareas
            List<Task> tasks = taskRepository.findByDeliveryId(delivery.getId());
            for (Task task : tasks) {
                List<Feedback> taskFeedbacks = feedbackRepository.findByTaskId(task.getId());
                totalFeedbacks += taskFeedbacks.size();

                for (Feedback feedback : taskFeedbacks) {
                    List<FeedbackResponse> responses = responseRepository.findByFeedbackId(feedback.getId());
                    totalResponses += responses.size();

                    for (FeedbackResponse response : responses) {
                        Duration duration = Duration.between(feedback.getCreatedAt(), response.getCreatedAt());
                        responseTimes.add(duration);
                    }
                }
            }
        }

        stats.setTotalFeedbacks(totalFeedbacks);
        stats.setTotalResponses(totalResponses);
        stats.setPendingDeliveries(pendingDeliveries);

        // Calcular tiempo promedio de respuesta en horas
        if (!responseTimes.isEmpty()) {
            double avgHours = responseTimes.stream()
                    .mapToLong(Duration::toHours)
                    .average()
                    .orElse(0.0);
            stats.setAverageResponseTime(avgHours);
        }

        return stats;
    }

    /**
     * Genera texto resumen del reporte
     */
    private String generateSummaryText(TeamReportDTO report) {
        StringBuilder summary = new StringBuilder();
        summary.append("Reporte de evaluación del equipo ").append(report.getTeamName())
                .append(" en el curso ").append(report.getCourseName()).append(". ");

        ReportStatistics stats = report.getStatistics();
        summary.append("Total de entregas: ").append(stats.getTotalDeliveries())
                .append(", Feedbacks: ").append(stats.getTotalFeedbacks())
                .append(", Respuestas: ").append(stats.getTotalResponses()).append(". ");

        if (stats.getPendingDeliveries() > 0) {
            summary.append("Entregas pendientes de revisión: ").append(stats.getPendingDeliveries()).append(". ");
        }

        return summary.toString();
    }

    /**
     * Obtener reporte por ID
     */
    public TeamReportDTO getReportById(Long reportId, Long professorId) {
        TeamReport report = teamReportRepository.findById(reportId)
                .orElseThrow(() -> new RuntimeException("Reporte no encontrado"));

        // Verificar que el profesor tiene acceso
        if (!report.getProfessorId().equals(professorId)) {
            throw new RuntimeException("Acceso denegado al reporte");
        }

        try {
            return objectMapper.readValue(report.getReportData(), TeamReportDTO.class);
        } catch (JsonProcessingException e) {
            throw new RuntimeException("Error al leer el reporte: " + e.getMessage(), e);
        }
    }

    /**
     * Listar reportes con filtros
     */
    public List<TeamReportDTO> listReports(Long professorId, Long courseId, Long teamId, OffsetDateTime fromDate) {
        List<TeamReport> reports = teamReportRepository.findByFilters(professorId, courseId, teamId, fromDate);

        return reports.stream()
                .map(report -> {
                    try {
                        TeamReportDTO dto = objectMapper.readValue(report.getReportData(), TeamReportDTO.class);
                        dto.setId(report.getId());
                        return dto;
                    } catch (JsonProcessingException e) {
                        throw new RuntimeException("Error al leer reportes: " + e.getMessage(), e);
                    }
                })
                .collect(Collectors.toList());
    }

    /**
     * Listar reportes de un curso
     */
    public List<TeamReportDTO> listReportsByCourse(Long courseId) {
        List<TeamReport> reports = teamReportRepository.findByCourseIdOrderByGeneratedAtDesc(courseId);

        return reports.stream()
                .map(report -> {
                    try {
                        TeamReportDTO dto = objectMapper.readValue(report.getReportData(), TeamReportDTO.class);
                        dto.setId(report.getId());
                        return dto;
                    } catch (JsonProcessingException e) {
                        throw new RuntimeException("Error al leer reportes: " + e.getMessage(), e);
                    }
                })
                .collect(Collectors.toList());
    }
}
