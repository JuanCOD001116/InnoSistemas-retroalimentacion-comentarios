package com.inosistemas.retroalimentacion.y.comentarios.controller;

import com.inosistemas.retroalimentacion.y.comentarios.dto.TeamReportDTO;
import com.inosistemas.retroalimentacion.y.comentarios.service.TeamReportService;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.OffsetDateTime;
import java.util.List;

@RestController
@RequestMapping("/api/v1/team-reports")
public class TeamReportController {

    private final TeamReportService teamReportService;

    public TeamReportController(TeamReportService teamReportService) {
        this.teamReportService = teamReportService;
    }

    /**
     * Generar reporte de evaluación de equipo
     * POST /api/v1/team-reports/generate
     */
    @PostMapping("/generate")
    public ResponseEntity<?> generateTeamReport(
            @RequestBody GenerateReportRequest request,
            @RequestHeader(value = "X-User-Id", required = false) String professorIdHeader) {

        try {
            Long professorId = professorIdHeader != null ? Long.parseLong(professorIdHeader) : 100L;

            TeamReportDTO report = teamReportService.generateTeamReport(
                    request.getTeamId(),
                    professorId,
                    request.getCourseId(),
                    request.getCourseName());

            return ResponseEntity.ok(report);

        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(new ErrorResponse("No se pudo generar el reporte, inténtalo de nuevo", e.getMessage()));
        }
    }

    /**
     * Obtener reporte por ID
     * GET /api/v1/team-reports/{reportId}
     */
    @GetMapping("/{reportId}")
    public ResponseEntity<?> getReport(
            @PathVariable Long reportId,
            @RequestHeader(value = "X-User-Id", required = false) String professorIdHeader) {

        try {
            Long professorId = professorIdHeader != null ? Long.parseLong(professorIdHeader) : 100L;

            TeamReportDTO report = teamReportService.getReportById(reportId, professorId);
            return ResponseEntity.ok(report);

        } catch (RuntimeException e) {
            if (e.getMessage().contains("Acceso denegado")) {
                return ResponseEntity.status(HttpStatus.FORBIDDEN)
                        .body(new ErrorResponse("No tienes acceso a este reporte", e.getMessage()));
            }
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(new ErrorResponse("Reporte no encontrado", e.getMessage()));
        }
    }

    /**
     * Listar reportes con filtros
     * GET /api/v1/team-reports?courseId=1&teamId=1&fromDate=2025-01-01
     */
    @GetMapping
    public ResponseEntity<List<TeamReportDTO>> listReports(
            @RequestParam(required = false) Long courseId,
            @RequestParam(required = false) Long teamId,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) OffsetDateTime fromDate,
            @RequestHeader(value = "X-User-Id", required = false) String professorIdHeader) {

        Long professorId = professorIdHeader != null ? Long.parseLong(professorIdHeader) : 100L;

        List<TeamReportDTO> reports = teamReportService.listReports(professorId, courseId, teamId, fromDate);
        return ResponseEntity.ok(reports);
    }

    /**
     * Listar reportes de un curso
     * GET /api/v1/reports/course/{courseId}
     */
    @GetMapping("/course/{courseId}")
    public ResponseEntity<List<TeamReportDTO>> listReportsByCourse(@PathVariable Long courseId) {
        List<TeamReportDTO> reports = teamReportService.listReportsByCourse(courseId);
        return ResponseEntity.ok(reports);
    }

    // DTOs internos
    public static class GenerateReportRequest {
        private Long teamId;
        private Long courseId;
        private String courseName;

        public GenerateReportRequest() {
        }

        public Long getTeamId() {
            return teamId;
        }

        public void setTeamId(Long teamId) {
            this.teamId = teamId;
        }

        public Long getCourseId() {
            return courseId;
        }

        public void setCourseId(Long courseId) {
            this.courseId = courseId;
        }

        public String getCourseName() {
            return courseName;
        }

        public void setCourseName(String courseName) {
            this.courseName = courseName;
        }
    }

    public static class ErrorResponse {
        private String message;
        private String details;

        public ErrorResponse(String message, String details) {
            this.message = message;
            this.details = details;
        }

        public String getMessage() {
            return message;
        }

        public void setMessage(String message) {
            this.message = message;
        }

        public String getDetails() {
            return details;
        }

        public void setDetails(String details) {
            this.details = details;
        }
    }
}
