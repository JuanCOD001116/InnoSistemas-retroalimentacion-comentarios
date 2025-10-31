 package com.inosistemas.retroalimentacion.y.comentarios.service;

import com.inosistemas.retroalimentacion.y.comentarios.domain.AuditLog;
import com.inosistemas.retroalimentacion.y.comentarios.repository.AuditLogRepository;
import org.springframework.stereotype.Service;

import java.time.OffsetDateTime;

@Service
public class AuditLogService {

    private final AuditLogRepository repository;

    public AuditLogService(AuditLogRepository repository) { this.repository = repository; }

    public void logAccessDenied(Long userId, String targetType, Long targetId, String ip, String userAgent, String reason) {
        AuditLog l = new AuditLog();
        l.setUserId(userId);
        l.setAction("ACCESS_DENIED");
        l.setTargetType(targetType);
        l.setTargetId(targetId);
        l.setMetadata("{\"reason\":\"" + safe(reason) + "\"}");
        l.setIp(ip);
        l.setUserAgent(userAgent);
        l.setCreatedAt(OffsetDateTime.now());
        repository.save(l);
    }

    public void logAction(Long userId, String action, String targetType, Long targetId) {
        AuditLog l = new AuditLog();
        l.setUserId(userId);
        l.setAction(action);
        l.setTargetType(targetType);
        l.setTargetId(targetId);
        l.setCreatedAt(OffsetDateTime.now());
        repository.save(l);
    }

    private String safe(String s) { return s == null ? "" : s.replace("\"", "'"); }
}


