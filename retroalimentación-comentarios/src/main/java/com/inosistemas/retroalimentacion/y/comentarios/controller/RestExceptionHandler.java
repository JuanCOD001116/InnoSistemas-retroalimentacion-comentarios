package com.inosistemas.retroalimentacion.y.comentarios.controller;

import com.inosistemas.retroalimentacion.y.comentarios.service.AuditLogService;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.ExceptionHandler;

import java.util.Map;
import java.io.PrintWriter;
import java.io.StringWriter;
import org.springframework.web.bind.annotation.ControllerAdvice;

// TEMPORALMENTE ACTIVADO PARA DEPURACIÓN
@ControllerAdvice
public class RestExceptionHandler {

    private final AuditLogService auditLogService;

    public RestExceptionHandler(AuditLogService auditLogService) {
        this.auditLogService = auditLogService;
    }

    @ExceptionHandler(SecurityException.class)
    public ResponseEntity<Object> handleSecurity(SecurityException ex, HttpServletRequest req) {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        Long userId = null;
        if (auth != null && auth.getName() != null) {
            try {
                userId = Long.parseLong(auth.getName());
            } catch (NumberFormatException ignored) {
            }
        }
        auditLogService.logAccessDenied(userId, "delivery", null, req.getRemoteAddr(), req.getHeader("User-Agent"),
                ex.getMessage());
        return ResponseEntity.status(HttpStatus.FORBIDDEN).body(Map.of("message", "Acceso denegado"));
    }

    @ExceptionHandler(Exception.class)
    public ResponseEntity<Object> handleAll(Exception ex, HttpServletRequest req) {
        // Capturar stacktrace completo
        StringWriter sw = new StringWriter();
        PrintWriter pw = new PrintWriter(sw);
        ex.printStackTrace(pw);
        String stackTrace = sw.toString();

        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(Map.of(
                "message", ex.getMessage() != null ? ex.getMessage() : "Error desconocido",
                "exception", ex.getClass().getName(),
                "stackTrace", stackTrace,
                "path", req.getRequestURI()));
    }
}
