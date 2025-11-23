package com.inosistemas.retroalimentacion.y.comentarios.service;

import com.inosistemas.retroalimentacion.y.comentarios.dto.StudentReportDTO;
import com.itextpdf.html2pdf.ConverterProperties;
import com.itextpdf.html2pdf.HtmlConverter;
import org.springframework.stereotype.Service;

import java.io.ByteArrayOutputStream;
import java.time.format.DateTimeFormatter;

@Service
public class StudentReportPdfService {

    private static final DateTimeFormatter DATE_FORMATTER = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");

    /**
     * Generate PDF from StudentReportDTO
     */
    public byte[] generatePdf(StudentReportDTO report) {
        try {
            String html = generateHtml(report);
            ByteArrayOutputStream outputStream = new ByteArrayOutputStream();

            ConverterProperties converterProperties = new ConverterProperties();
            HtmlConverter.convertToPdf(html, outputStream, converterProperties);

            return outputStream.toByteArray();
        } catch (Exception e) {
            throw new RuntimeException("Error al generar el PDF del reporte", e);
        }
    }

    /**
     * Generate HTML content for the report
     */
    private String generateHtml(StudentReportDTO report) {
        StringBuilder html = new StringBuilder();

        html.append("<!DOCTYPE html>");
        html.append("<html>");
        html.append("<head>");
        html.append("<meta charset='UTF-8'/>");
        html.append("<title>Reporte Final - ").append(escapeHtml(report.getStudentName())).append("</title>");
        html.append("<style>");
        html.append(getCssStyles());
        html.append("</style>");
        html.append("</head>");
        html.append("<body>");

        // Header
        html.append("<div class='header'>");
        html.append("<h1>Reporte Final de Evaluación</h1>");
        html.append("<div class='subtitle'>Sistema de Gestión Académica</div>");
        html.append("</div>");

        // Summary section
        html.append("<div class='summary'>");
        html.append("<table class='summary-table'>");
        html.append("<tr>");
        html.append("<td><strong>Nombre de usuario:</strong></td>");
        html.append("<td>").append(escapeHtml(report.getStudentName())).append("</td>");
        html.append("<td><strong>Proyecto:</strong></td>");
        html.append("<td>").append(escapeHtml(report.getProjectName())).append("</td>");
        html.append("</tr>");
        html.append("<tr>");
        html.append("<td><strong>Fecha de Generación:</strong></td>");
        html.append("<td>").append(report.getGeneratedAt().format(DATE_FORMATTER)).append("</td>");

        if (report.getFinalGrade() != null) {
            html.append("<td><strong>Calificación Final:</strong></td>");
            html.append("<td class='grade'>").append(String.format("%.1f", report.getFinalGrade())).append("/100</td>");
        } else {
            html.append("<td colspan='2'></td>");
        }
        html.append("</tr>");
        html.append("</table>");
        html.append("</div>");

        // Statistics section
        if (report.getStatistics() != null) {
            html.append(generateStatisticsSection(report.getStatistics()));
        }

        // Deliveries section
        if (report.getDeliveries() != null && !report.getDeliveries().isEmpty()) {
            html.append(generateDeliveriesSection(report.getDeliveries()));
        }

        // Feedback section
        if (report.getFeedbackReceived() != null && !report.getFeedbackReceived().isEmpty()) {
            html.append(generateFeedbackSection(report.getFeedbackReceived()));
        }

        // Responses section
        if (report.getResponsesGiven() != null && !report.getResponsesGiven().isEmpty()) {
            html.append(generateResponsesSection(report.getResponsesGiven()));
        }

        // Footer
        html.append("<div class='footer'>");
        html.append("<p>Reporte generado automáticamente - ").append(report.getGeneratedAt().format(DATE_FORMATTER))
                .append("</p>");
        html.append("</div>");

        html.append("</body>");
        html.append("</html>");

        return html.toString();
    }

    private String generateStatisticsSection(StudentReportDTO.ReportStatistics stats) {
        StringBuilder html = new StringBuilder();

        html.append("<div class='section'>");
        html.append("<h2>Estadísticas de Desempeño</h2>");
        html.append("<table class='data-table'>");
        html.append("<thead>");
        html.append("<tr><th>Métrica</th><th>Valor</th></tr>");
        html.append("</thead>");
        html.append("<tbody>");

        html.append("<tr><td>Total de Entregas</td><td>").append(stats.getTotalDeliveries()).append("</td></tr>");
        html.append("<tr><td>Tareas Completadas</td><td>").append(stats.getCompletedTasks())
                .append(" / ").append(stats.getTotalTasks()).append("</td></tr>");
        html.append("<tr><td>Tasa de Completación de Tareas</td><td>")
                .append(String.format("%.2f", stats.getTaskCompletionRate())).append("%</td></tr>");
        html.append("<tr><td>Retroalimentaciones Recibidas</td><td>")
                .append(stats.getTotalFeedbackReceived()).append("</td></tr>");
        html.append("<tr><td>Respuestas Dadas</td><td>").append(stats.getTotalResponsesGiven()).append("</td></tr>");
        html.append("<tr><td>Tiempo Promedio de Respuesta</td><td>")
                .append(String.format("%.2f", stats.getAverageResponseTimeHours())).append(" horas</td></tr>");

        html.append("</tbody>");
        html.append("</table>");
        html.append("</div>");

        return html.toString();
    }

    private String generateDeliveriesSection(java.util.List<StudentReportDTO.DeliverySummary> deliveries) {
        StringBuilder html = new StringBuilder();

        html.append("<div class='section'>");
        html.append("<h2>Entregas Realizadas</h2>");
        html.append("<table class='data-table'>");
        html.append("<thead>");
        html.append("<tr><th>Título</th><th>Fecha</th><th>Tareas</th><th>Feedback</th></tr>");
        html.append("</thead>");
        html.append("<tbody>");

        for (StudentReportDTO.DeliverySummary delivery : deliveries) {
            html.append("<tr>");
            html.append("<td>").append(escapeHtml(delivery.getDeliveryTitle())).append("</td>");
            html.append("<td>").append(delivery.getSubmittedAt().format(DATE_FORMATTER)).append("</td>");
            html.append("<td>").append(delivery.getTasksCompleted()).append(" / ")
                    .append(delivery.getTotalTasks()).append("</td>");
            html.append("<td>").append(delivery.getFeedbackCount()).append("</td>");
            html.append("</tr>");
        }

        html.append("</tbody>");
        html.append("</table>");
        html.append("</div>");

        return html.toString();
    }

    private String generateFeedbackSection(java.util.List<StudentReportDTO.FeedbackItem> feedbacks) {
        StringBuilder html = new StringBuilder();

        html.append("<div class='section'>");
        html.append("<h2>Retroalimentación Recibida</h2>");
        html.append("<table class='data-table'>");
        html.append("<thead>");
        html.append(
                "<tr><th style='width: 15%;'>Fecha</th><th style='width: 20%;'>Ámbito</th><th style='width: 65%;'>Contenido</th></tr>");
        html.append("</thead>");
        html.append("<tbody>");

        for (StudentReportDTO.FeedbackItem feedback : feedbacks) {
            html.append("<tr>");
            html.append("<td>").append(feedback.getCreatedAt().format(DATE_FORMATTER)).append("</td>");
            html.append("<td><em>").append(escapeHtml(feedback.getScope())).append(":</em><br/>")
                    .append(escapeHtml(feedback.getScopeName())).append("</td>");
            html.append("<td>").append(escapeHtml(feedback.getContent())).append("</td>");
            html.append("</tr>");
        }

        html.append("</tbody>");
        html.append("</table>");
        html.append("</div>");

        return html.toString();
    }

    private String generateResponsesSection(java.util.List<StudentReportDTO.ResponseItem> responses) {
        StringBuilder html = new StringBuilder();

        html.append("<div class='section'>");
        html.append("<h2>Respuestas del Estudiante</h2>");
        html.append("<table class='data-table'>");
        html.append("<thead>");
        html.append("<tr><th style='width: 20%;'>Fecha</th><th style='width: 80%;'>Contenido</th></tr>");
        html.append("</thead>");
        html.append("<tbody>");

        for (StudentReportDTO.ResponseItem response : responses) {
            html.append("<tr>");
            html.append("<td>").append(response.getCreatedAt().format(DATE_FORMATTER)).append("</td>");
            html.append("<td>").append(escapeHtml(response.getContent())).append("</td>");
            html.append("</tr>");
        }

        html.append("</tbody>");
        html.append("</table>");
        html.append("</div>");

        return html.toString();
    }

    private String getCssStyles() {
        return """
                    body {
                        font-family: 'Arial', sans-serif;
                        margin: 0;
                        padding: 20px;
                        color: #333;
                        font-size: 11pt;
                    }

                    .header {
                        text-align: center;
                        margin-bottom: 30px;
                        padding-bottom: 15px;
                        border-bottom: 3px solid #4CAF50;
                    }

                    .header h1 {
                        margin: 0;
                        color: #2C3E50;
                        font-size: 24pt;
                    }

                    .header .subtitle {
                        font-size: 12pt;
                        color: #7F8C8D;
                        margin-top: 5px;
                    }

                    .summary {
                        background-color: #F0F8FF;
                        padding: 15px;
                        border-radius: 8px;
                        margin-bottom: 20px;
                        border: 1px solid #4CAF50;
                    }

                    .summary-table {
                        width: 100%;
                        border-collapse: collapse;
                    }

                    .summary-table td {
                        padding: 8px 12px;
                        font-size: 10pt;
                    }

                    .summary-table strong {
                        color: #2C3E50;
                    }

                    .grade {
                        font-size: 16pt;
                        font-weight: bold;
                        color: #4CAF50;
                    }

                    .section {
                        margin-bottom: 25px;
                        page-break-inside: avoid;
                    }

                    .section h2 {
                        color: #2C3E50;
                        font-size: 14pt;
                        margin-bottom: 10px;
                        padding-bottom: 5px;
                        border-bottom: 2px solid #4CAF50;
                    }

                    .data-table {
                        width: 100%;
                        border-collapse: collapse;
                        margin-top: 10px;
                        font-size: 9pt;
                    }

                    .data-table thead {
                        background-color: #4CAF50;
                        color: white;
                    }

                    .data-table th {
                        padding: 10px;
                        text-align: left;
                        font-weight: bold;
                    }

                    .data-table td {
                        padding: 8px;
                        border-bottom: 1px solid #DDD;
                        vertical-align: top;
                    }

                    .data-table tbody tr:nth-child(even) {
                        background-color: #F9F9F9;
                    }

                    .data-table tbody tr:hover {
                        background-color: #F0F8FF;
                    }

                    .footer {
                        margin-top: 30px;
                        padding-top: 15px;
                        border-top: 2px solid #DDD;
                        text-align: center;
                        font-size: 9pt;
                        color: #7F8C8D;
                    }

                    em {
                        color: #7F8C8D;
                        font-style: italic;
                    }
                """;
    }

    private String escapeHtml(String text) {
        if (text == null) {
            return "";
        }
        return text.replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#39;");
    }
}
