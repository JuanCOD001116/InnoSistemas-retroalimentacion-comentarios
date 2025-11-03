package com.inosistemas.retroalimentacion.y.comentarios.controller;

import com.inosistemas.retroalimentacion.y.comentarios.dto.StudentReportDTO;
import com.inosistemas.retroalimentacion.y.comentarios.service.StudentReportService;
import com.inosistemas.retroalimentacion.y.comentarios.service.StudentReportPdfService;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.OffsetDateTime;
import java.util.List;

@RestController
@RequestMapping("/api/v1/student-reports")
public class StudentReportController {

    private final StudentReportService studentReportService;
    private final StudentReportPdfService pdfService;

    public StudentReportController(StudentReportService studentReportService,
            StudentReportPdfService pdfService) {
        this.studentReportService = studentReportService;
        this.pdfService = pdfService;
    }

    /**
     * Scenario 1: Generate student final report
     * POST /api/v1/student-reports/generate
     */
    @PostMapping("/generate")
    public ResponseEntity<?> generateReport(
            @RequestBody GenerateReportRequest request,
            @RequestHeader("X-User-Id") Long studentId) {
        try {
            StudentReportDTO report = studentReportService.generateStudentReport(
                    studentId,
                    request.projectId(),
                    request.projectName());
            return ResponseEntity.ok(report);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(new ErrorResponse(
                            "No se pudo generar el reporte, inténtalo de nuevo",
                            e.getMessage()));
        }
    }

    /**
     * Scenario 2: Download report as PDF
     * GET /api/v1/student-reports/{reportId}/pdf
     */
    @GetMapping(value = "/{reportId}/pdf", produces = MediaType.APPLICATION_PDF_VALUE)
    public ResponseEntity<?> downloadPdf(
            @PathVariable Long reportId,
            @RequestHeader("X-User-Id") Long studentId) {
        try {
            // Get report with access control
            StudentReportDTO report = studentReportService.getReportById(reportId, studentId);

            // Generate PDF
            byte[] pdfBytes = pdfService.generatePdf(report);

            // Prepare response headers
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_PDF);
            headers.setContentDispositionFormData("attachment",
                    "reporte-final-estudiante-" + studentId + ".pdf");
            headers.setContentLength(pdfBytes.length);

            return new ResponseEntity<>(pdfBytes, headers, HttpStatus.OK);
        } catch (RuntimeException e) {
            if (e.getMessage().contains("no encontrado")) {
                return ResponseEntity.status(HttpStatus.NOT_FOUND)
                        .body(new ErrorResponse("Reporte no encontrado", e.getMessage()).toString().getBytes());
            } else if (e.getMessage().contains("Acceso denegado")) {
                return ResponseEntity.status(HttpStatus.FORBIDDEN)
                        .body(new ErrorResponse("Acceso denegado", e.getMessage()).toString().getBytes());
            }
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(new ErrorResponse("Error al generar PDF", e.getMessage()).toString().getBytes());
        }
    }

    /**
     * Scenario 3: Get report by ID (for viewing/printing)
     * GET /api/v1/student-reports/{reportId}
     */
    @GetMapping("/{reportId}")
    public ResponseEntity<?> getReport(
            @PathVariable Long reportId,
            @RequestHeader("X-User-Id") Long studentId) {
        try {
            StudentReportDTO report = studentReportService.getReportById(reportId, studentId);
            return ResponseEntity.ok(report);
        } catch (RuntimeException e) {
            if (e.getMessage().contains("no encontrado")) {
                return ResponseEntity.status(HttpStatus.NOT_FOUND)
                        .body(new ErrorResponse("Reporte no encontrado", e.getMessage()));
            } else if (e.getMessage().contains("Acceso denegado")) {
                return ResponseEntity.status(HttpStatus.FORBIDDEN)
                        .body(new ErrorResponse("Acceso denegado", e.getMessage()));
            }
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(new ErrorResponse("Error al obtener el reporte", e.getMessage()));
        }
    }

    /**
     * Scenario 5: List student reports with filters
     * GET /api/v1/student-reports
     */
    @GetMapping
    public ResponseEntity<List<StudentReportDTO>> listReports(
            @RequestHeader("X-User-Id") Long studentId,
            @RequestParam(required = false) Long projectId,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) OffsetDateTime fromDate) {
        List<StudentReportDTO> reports = studentReportService.listReports(studentId, projectId, fromDate);
        return ResponseEntity.ok(reports);
    }

    /**
     * Check if student can access a project (for UI visibility - Scenario 4)
     * GET /api/v1/student-reports/can-access/{projectId}
     */
    @GetMapping("/can-access/{projectId}")
    public ResponseEntity<CanAccessResponse> canAccessProject(
            @PathVariable Long projectId,
            @RequestHeader("X-User-Id") Long studentId) {
        boolean canAccess = studentReportService.canAccessReport(studentId, projectId);
        return ResponseEntity.ok(new CanAccessResponse(canAccess));
    }

    /**
     * Scenario 3: Get printable view (HTML optimized for printing)
     * GET /api/v1/student-reports/{reportId}/print
     */
    @GetMapping("/{reportId}/print")
    public ResponseEntity<?> getPrintableView(
            @PathVariable Long reportId,
            @RequestHeader("X-User-Id") Long studentId) {
        try {
            StudentReportDTO report = studentReportService.getReportById(reportId, studentId);
            String html = generatePrintableHtml(report);
            return ResponseEntity.ok()
                    .header("Content-Type", "text/html; charset=UTF-8")
                    .body(html);
        } catch (RuntimeException e) {
            if (e.getMessage().contains("no encontrado")) {
                return ResponseEntity.status(HttpStatus.NOT_FOUND)
                        .body("<html><body><h1>404 - Reporte no encontrado</h1></body></html>");
            } else if (e.getMessage().contains("Acceso denegado")) {
                return ResponseEntity.status(HttpStatus.FORBIDDEN)
                        .body("<html><body><h1>403 - Acceso denegado</h1></body></html>");
            }
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("<html><body><h1>500 - Error del servidor</h1></body></html>");
        }
    }

    // Inner classes
    public record GenerateReportRequest(Long projectId, String projectName) {
    }

    public record ErrorResponse(String message, String details) {
    }

    public record CanAccessResponse(boolean canAccess) {
    }

    // Helper method to generate HTML for printing
    private String generatePrintableHtml(StudentReportDTO report) {
        StringBuilder html = new StringBuilder();
        html.append("<!DOCTYPE html>");
        html.append("<html><head>");
        html.append("<meta charset='UTF-8'>");
        html.append("<title>Reporte Final - ").append(report.getStudentName()).append("</title>");
        html.append("<style>");
        html.append("body { font-family: Arial, sans-serif; margin: 20px; }");
        html.append("h1, h2 { color: #333; }");
        html.append("table { width: 100%; border-collapse: collapse; margin: 20px 0; }");
        html.append("th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }");
        html.append("th { background-color: #4CAF50; color: white; }");
        html.append(".summary { background-color: #f9f9f9; padding: 15px; margin: 20px 0; border-radius: 5px; }");
        html.append(".grade { font-size: 24px; font-weight: bold; color: #4CAF50; }");
        html.append("@media print { body { margin: 0; } .no-print { display: none; } }");
        html.append("</style>");
        html.append("</head><body>");

        // Header
        html.append("<h1>Reporte Final de Evaluación</h1>");
        html.append("<div class='summary'>");
        html.append("<p><strong>Estudiante:</strong> ").append(report.getStudentName()).append("</p>");
        html.append("<p><strong>Proyecto:</strong> ").append(report.getProjectName()).append("</p>");
        html.append("<p><strong>Fecha de Generación:</strong> ").append(report.getGeneratedAt()).append("</p>");
        if (report.getFinalGrade() != null) {
            html.append("<p><strong>Calificación Final:</strong> <span class='grade'>")
                    .append(report.getFinalGrade()).append("/100</span></p>");
        }
        html.append("</div>");

        // Statistics
        if (report.getStatistics() != null) {
            StudentReportDTO.ReportStatistics stats = report.getStatistics();
            html.append("<h2>Estadísticas</h2>");
            html.append("<table>");
            html.append("<tr><th>Métrica</th><th>Valor</th></tr>");
            html.append("<tr><td>Total de Entregas</td><td>").append(stats.getTotalDeliveries()).append("</td></tr>");
            html.append("<tr><td>Tareas Completadas</td><td>").append(stats.getCompletedTasks())
                    .append(" / ").append(stats.getTotalTasks()).append("</td></tr>");
            html.append("<tr><td>Tasa de Completación de Tareas</td><td>")
                    .append(String.format("%.2f", stats.getTaskCompletionRate())).append("%</td></tr>");
            html.append("<tr><td>Retroalimentaciones Recibidas</td><td>")
                    .append(stats.getTotalFeedbackReceived()).append("</td></tr>");
            html.append("<tr><td>Respuestas Dadas</td><td>").append(stats.getTotalResponsesGiven())
                    .append("</td></tr>");
            html.append("<tr><td>Tiempo Promedio de Respuesta</td><td>")
                    .append(String.format("%.2f", stats.getAverageResponseTimeHours())).append(" horas</td></tr>");
            html.append("</table>");
        }

        // Deliveries
        if (report.getDeliveries() != null && !report.getDeliveries().isEmpty()) {
            html.append("<h2>Entregas</h2>");
            html.append("<table>");
            html.append("<tr><th>Título</th><th>Fecha</th><th>Tareas Completadas</th><th>Feedback Recibido</th></tr>");
            for (StudentReportDTO.DeliverySummary delivery : report.getDeliveries()) {
                html.append("<tr>");
                html.append("<td>").append(delivery.getDeliveryTitle()).append("</td>");
                html.append("<td>").append(delivery.getSubmittedAt()).append("</td>");
                html.append("<td>").append(delivery.getTasksCompleted()).append(" / ")
                        .append(delivery.getTotalTasks()).append("</td>");
                html.append("<td>").append(delivery.getFeedbackCount()).append("</td>");
                html.append("</tr>");
            }
            html.append("</table>");
        }

        // Feedback Received
        if (report.getFeedbackReceived() != null && !report.getFeedbackReceived().isEmpty()) {
            html.append("<h2>Retroalimentación Recibida</h2>");
            html.append("<table>");
            html.append("<tr><th>Fecha</th><th>Ámbito</th><th>Autor</th><th>Contenido</th></tr>");
            for (StudentReportDTO.FeedbackItem feedback : report.getFeedbackReceived()) {
                html.append("<tr>");
                html.append("<td>").append(feedback.getCreatedAt()).append("</td>");
                html.append("<td>").append(feedback.getScope()).append(": ").append(feedback.getScopeName())
                        .append("</td>");
                html.append("<td>").append(feedback.getAuthorName()).append("</td>");
                html.append("<td>").append(feedback.getContent()).append("</td>");
                html.append("</tr>");
            }
            html.append("</table>");
        }

        // Responses Given
        if (report.getResponsesGiven() != null && !report.getResponsesGiven().isEmpty()) {
            html.append("<h2>Respuestas del Estudiante</h2>");
            html.append("<table>");
            html.append("<tr><th>Fecha</th><th>Contenido</th></tr>");
            for (StudentReportDTO.ResponseItem response : report.getResponsesGiven()) {
                html.append("<tr>");
                html.append("<td>").append(response.getCreatedAt()).append("</td>");
                html.append("<td>").append(response.getContent()).append("</td>");
                html.append("</tr>");
            }
            html.append("</table>");
        }

        html.append("<div class='no-print'>");
        html.append("<button onclick='window.print()'>Imprimir</button>");
        html.append("</div>");

        html.append("</body></html>");
        return html.toString();
    }
}
