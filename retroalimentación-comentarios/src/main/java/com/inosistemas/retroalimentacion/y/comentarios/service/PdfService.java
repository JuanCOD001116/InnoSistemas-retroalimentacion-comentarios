package com.inosistemas.retroalimentacion.y.comentarios.service;

import com.openhtmltopdf.pdfboxout.PdfRendererBuilder;
import org.springframework.stereotype.Service;

import java.io.ByteArrayOutputStream;

@Service
public class PdfService {

    public byte[] renderHtml(String html) {
        try (ByteArrayOutputStream os = new ByteArrayOutputStream()) {
            PdfRendererBuilder builder = new PdfRendererBuilder();
            builder.useFastMode();
            builder.withHtmlContent(html, null);
            builder.toStream(os);
            builder.run();
            return os.toByteArray();
        } catch (Exception e) {
            throw new IllegalStateException("No se pudo generar el PDF", e);
        }
    }

    public String wrapHtml(String title, String body) {
        String head = "<meta charset='UTF-8'><style>body{font-family:sans-serif}h1{font-size:18px}table{width:100%;border-collapse:collapse}td,th{border:1px solid #ddd;padding:6px;font-size:12px}</style>";
        return "<!DOCTYPE html><html><head>" + head + "<title>" + esc(title) + "</title></head><body><h1>" + esc(title) + "</h1>" + body + "</body></html>";
    }

    private String esc(String s) { return s == null ? "" : s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;"); }
}


