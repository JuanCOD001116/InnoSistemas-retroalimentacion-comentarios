package com.inosistemas.retroalimentacion.y.comentarios.controller;

import com.inosistemas.retroalimentacion.y.comentarios.service.AuditLogService;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.ExceptionHandler;

import java.util.Map;

// TEMPORALMENTE DESACTIVADO PARA RESOLVER PROBLEMA CON SWAGGER
// @ControllerAdvice
public class RestExceptionHandler {

    private final AuditLogService auditLogService;

    public RestExceptionHandler(AuditLogService auditLogService) { this.auditLogService = auditLogService; }

    @ExceptionHandler(SecurityException.class)
    public ResponseEntity<Object> handleSecurity(SecurityException ex, HttpServletRequest req) {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        Long userId = null;
        if (auth != null && auth.getName() != null) {
            try { userId = Long.parseLong(auth.getName()); } catch (NumberFormatException ignored) {}
        }
        auditLogService.logAccessDenied(userId, "delivery", null, req.getRemoteAddr(), req.getHeader("User-Agent"), ex.getMessage());
        return ResponseEntity.status(HttpStatus.FORBIDDEN).body(Map.of("message", "Acceso denegado"));
    }
}


