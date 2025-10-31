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

    private long userId(Principal p) { return Long.parseLong(p.getName()); }

    @GetMapping("/student")
    public ResponseEntity<Map<String, Object>> studentReport(@RequestParam long projectId, Principal principal) {
        return ResponseEntity.ok(service.studentProjectReport(userId(principal), projectId));
    }

    @GetMapping("/team")
    public ResponseEntity<Map<String, Object>> teamReport(@RequestParam long teamId, Principal principal) {
        return ResponseEntity.ok(service.teamReportForProfessor(userId(principal), teamId));
    }

    @GetMapping(value = "/student/pdf", produces = MediaType.APPLICATION_PDF_VALUE)
    public ResponseEntity<byte[]> studentReportPdf(@RequestParam long projectId, Principal principal) {
        Map<String, Object> data = service.studentProjectReport(userId(principal), projectId);
        String html = renderStudentHtml(data);
        byte[] pdf = pdfService.renderHtml(pdfService.wrapHtml("Reporte Estudiante - Proyecto " + projectId, html));
        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=student-project-" + projectId + ".pdf")
                .body(pdf);
    }

    @GetMapping(value = "/team/pdf", produces = MediaType.APPLICATION_PDF_VALUE)
    public ResponseEntity<byte[]> teamReportPdf(@RequestParam long teamId, Principal principal) {
        Map<String, Object> data = service.teamReportForProfessor(userId(principal), teamId);
        String html = renderTeamHtml(data);
        byte[] pdf = pdfService.renderHtml(pdfService.wrapHtml("Reporte Equipo " + teamId, html));
        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=team-" + teamId + ".pdf")
                .body(pdf);
    }

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


