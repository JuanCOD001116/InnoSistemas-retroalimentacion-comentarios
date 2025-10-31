package com.inosistemas.retroalimentacion.y.comentarios.controller;

import com.inosistemas.retroalimentacion.y.comentarios.service.PdfService;
import com.inosistemas.retroalimentacion.y.comentarios.service.ReportService;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.security.Principal;
import java.util.Map;

@RestController
@RequestMapping("/api/v1/reports")
public class ReportController {

    private final ReportService service;
    private final PdfService pdfService;

    public ReportController(ReportService service, PdfService pdfService) {
        this.service = service;
        this.pdfService = pdfService;
    }

    // MÉTODO SIMPLIFICADO PARA PRUEBAS - Sin restricciones de seguridad
    private long userId(Principal p, @RequestHeader(value = "X-User-Id", required = false) String userIdHeader) {
        // Acepta cualquier usuario del header, Principal, o usa 1 por defecto
        if (userIdHeader != null && !userIdHeader.isBlank()) {
            try {
                return Long.parseLong(userIdHeader);
            } catch (NumberFormatException ignored) {}
        }
        if (p != null && p.getName() != null) {
            try {
                return Long.parseLong(p.getName());
            } catch (NumberFormatException ignored) {}
        }
        return 1L; // Usuario por defecto - CUALQUIERA puede usar cualquier endpoint
    }

    // ENDPOINT COMPLETAMENTE ABIERTO - Cualquier usuario puede ver reportes de estudiante
    @GetMapping("/student")
    public ResponseEntity<Map<String, Object>> studentReport(@RequestParam long projectId,
                                                              @RequestHeader(value = "X-User-Id", required = false) String userIdHeader,
                                                              Principal principal) {
        // Sin validaciones - cualquiera puede ver cualquier reporte
        return ResponseEntity.ok(service.studentProjectReport(userId(principal, userIdHeader), projectId));
    }

    // ENDPOINT COMPLETAMENTE ABIERTO - Cualquier usuario puede ver reportes de equipo
    @GetMapping("/team")
    public ResponseEntity<Map<String, Object>> teamReport(@RequestParam long teamId,
                                                          @RequestHeader(value = "X-User-Id", required = false) String userIdHeader,
                                                          Principal principal) {
        // Sin validaciones - cualquiera puede ver cualquier reporte
        return ResponseEntity.ok(service.teamReportForProfessor(userId(principal, userIdHeader), teamId));
    }

    // ENDPOINT COMPLETAMENTE ABIERTO - Cualquier usuario puede descargar PDF de estudiante
    @GetMapping(value = "/student/pdf", produces = MediaType.APPLICATION_PDF_VALUE)
    public ResponseEntity<byte[]> studentReportPdf(@RequestParam long projectId,
                                                    @RequestHeader(value = "X-User-Id", required = false) String userIdHeader,
                                                    Principal principal) {
        // Sin validaciones - cualquiera puede descargar cualquier PDF
        Map<String, Object> data = service.studentProjectReport(userId(principal, userIdHeader), projectId);
        String html = renderStudentHtml(data);
        byte[] pdf = pdfService.renderHtml(pdfService.wrapHtml("Reporte Estudiante - Proyecto " + projectId, html));
        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=student-project-" + projectId + ".pdf")
                .body(pdf);
    }

    // ENDPOINT COMPLETAMENTE ABIERTO - Cualquier usuario puede descargar PDF de equipo
    @GetMapping(value = "/team/pdf", produces = MediaType.APPLICATION_PDF_VALUE)
    public ResponseEntity<byte[]> teamReportPdf(@RequestParam long teamId,
                                                @RequestHeader(value = "X-User-Id", required = false) String userIdHeader,
                                                Principal principal) {
        // Sin validaciones - cualquiera puede descargar cualquier PDF
        Map<String, Object> data = service.teamReportForProfessor(userId(principal, userIdHeader), teamId);
        String html = renderTeamHtml(data);
        byte[] pdf = pdfService.renderHtml(pdfService.wrapHtml("Reporte Equipo " + teamId, html));
        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=team-" + teamId + ".pdf")
                .body(pdf);
    }

    @SuppressWarnings("unchecked")
    private String renderStudentHtml(Map<String, Object> data) {
        Map<String, Object> project = (Map<String, Object>) data.get("project");
        StringBuilder sb = new StringBuilder();
        sb.append("<p><b>Proyecto:</b> ").append(project.get("name")).append("</p>");
        sb.append("<table><thead><tr><th>Fecha</th><th>Autor</th><th>Ámbito</th><th>Contenido</th></tr></thead><tbody>");
        for (Map<String, Object> row : (Iterable<Map<String, Object>>) data.get("feedback")) {
            sb.append("<tr>");
            sb.append("<td>").append(row.get("created_at")).append("</td>");
            sb.append("<td>").append(row.get("author_id")).append("</td>");
            sb.append("<td>").append(row.get("scope")).append("</td>");
            sb.append("<td>").append(row.get("content")).append("</td>");
            sb.append("</tr>");
        }
        sb.append("</tbody></table>");
        return sb.toString();
    }

    @SuppressWarnings("unchecked")
    private String renderTeamHtml(Map<String, Object> data) {
        Map<String, Object> team = (Map<String, Object>) data.get("team");
        StringBuilder sb = new StringBuilder();
        sb.append("<p><b>Equipo:</b> ").append(team.get("name")).append("</p>");
        sb.append("<h3>Entregas</h3><ul>");
        for (Map<String, Object> row : (Iterable<Map<String, Object>>) data.get("deliveries")) {
            sb.append("<li>").append(row.get("title")).append(" - ").append(row.get("created_at")).append("</li>");
        }
        sb.append("</ul><h3>Retroalimentación</h3><table><thead><tr><th>Fecha</th><th>Autor</th><th>Contenido</th></tr></thead><tbody>");
        for (Map<String, Object> row : (Iterable<Map<String, Object>>) data.get("feedback")) {
            sb.append("<tr>");
            sb.append("<td>").append(row.get("created_at")).append("</td>");
            sb.append("<td>").append(row.get("author_id")).append("</td>");
            sb.append("<td>").append(row.get("content")).append("</td>");
            sb.append("</tr>");
        }
        sb.append("</tbody></table>");
        return sb.toString();
    }
}


