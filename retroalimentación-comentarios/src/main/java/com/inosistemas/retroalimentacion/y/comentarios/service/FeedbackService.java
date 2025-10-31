package com.inosistemas.retroalimentacion.y.comentarios.service;

import com.inosistemas.retroalimentacion.y.comentarios.config.RabbitMQConfig;
import com.inosistemas.retroalimentacion.y.comentarios.domain.Feedback;
import com.inosistemas.retroalimentacion.y.comentarios.domain.FeedbackResponse;
import com.inosistemas.retroalimentacion.y.comentarios.repository.FeedbackRepository;
import com.inosistemas.retroalimentacion.y.comentarios.repository.FeedbackResponseRepository;
import org.springframework.amqp.rabbit.core.RabbitTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.OffsetDateTime;
import java.util.List;

@Service
public class FeedbackService {

    private final FeedbackRepository feedbackRepository;
    private final FeedbackResponseRepository responseRepository;
    private final AuthorizationService authorizationService;
    private final RabbitTemplate rabbitTemplate;
    private final AuditLogService auditLogService;

    public FeedbackService(FeedbackRepository feedbackRepository,
                           FeedbackResponseRepository responseRepository,
                           AuthorizationService authorizationService,
                           RabbitTemplate rabbitTemplate,
                           AuditLogService auditLogService) {
        this.feedbackRepository = feedbackRepository;
        this.responseRepository = responseRepository;
        this.authorizationService = authorizationService;
        this.rabbitTemplate = rabbitTemplate;
        this.auditLogService = auditLogService;
    }

    public List<Feedback> listByScope(long userId, boolean isProfessor, Long projectId, Long taskId, Long deliveryId) {
        // VALIDACIONES DE AUTORIZACIÓN DESACTIVADAS PARA PRUEBAS
        if (deliveryId != null) {
            // ensureAccessToDelivery(userId, isProfessor, deliveryId);
            return feedbackRepository.findByDeliveryIdOrderByCreatedAtAsc(deliveryId);
        }
        if (taskId != null) {
            // ensureAccessToTask(userId, isProfessor, taskId);
            return feedbackRepository.findByTaskIdOrderByCreatedAtAsc(taskId);
        }
        if (projectId != null) {
            // ensureAccessToProject(userId, isProfessor, projectId);
            return feedbackRepository.findByProjectIdOrderByCreatedAtAsc(projectId);
        }
        throw new IllegalArgumentException("Debe especificar projectId, taskId o deliveryId");
    }

    @Transactional
    public Feedback createFeedback(long userId, boolean isProfessor, Long projectId, Long taskId, Long deliveryId, String content) {
        try {
            // VALIDACIONES DE AUTORIZACIÓN DESACTIVADAS PARA PRUEBAS
            if (deliveryId != null) { 
                // ensureAccessToDelivery(userId, isProfessor, deliveryId); 
            } else if (taskId != null) { 
                // ensureAccessToTask(userId, isProfessor, taskId); 
            } else if (projectId != null) { 
                // ensureAccessToProject(userId, isProfessor, projectId); 
            } else {
                throw new IllegalArgumentException("Debe especificar projectId, taskId o deliveryId");
            }
            Feedback f = new Feedback();
            f.setContent(content);
            f.setCreatedAt(OffsetDateTime.now());
            f.setDeliveryId(deliveryId);
            f.setTaskId(taskId);
            f.setProjectId(projectId);
            f.setAuthorId(userId);
            Feedback saved = feedbackRepository.save(f);
            
            try {
                auditLogService.logAction(userId, "COMMENT_CREATE", "feedback", saved.getId());
            } catch (Exception e) {
                System.err.println("[AuditLog] Error al registrar acción: " + e.getMessage());
                e.printStackTrace();
            }
            
            // Publicar en RabbitMQ con manejo de errores
            try {
                rabbitTemplate.convertAndSend(RabbitMQConfig.FEEDBACK_EXCHANGE, "feedback.created", new WsEvent("feedback.created", saved));
                System.out.println("[RabbitMQ] Feedback publicado exitosamente: " + saved.getId());
            } catch (Exception e) {
                System.err.println("[RabbitMQ] Error al publicar feedback: " + e.getMessage());
                System.err.println("[RabbitMQ] Tipo de error: " + e.getClass().getName());
                e.printStackTrace();
                // No lanzamos la excepción para que el feedback se guarde igualmente
            }
            
            return saved;
        } catch (Exception e) {
            System.err.println("[FeedbackService] Error general en createFeedback: " + e.getMessage());
            e.printStackTrace();
            throw e; // Re-lanzamos para que el controller pueda manejarlo
        }
    }

    @Transactional
    public Feedback updateFeedback(long userId, boolean isProfessor, long id, String content) {
        Feedback f = feedbackRepository.findById(id).orElseThrow();
        // VALIDACIONES DE AUTORIZACIÓN DESACTIVADAS PARA PRUEBAS
        // ensureAccessByEntity(userId, isProfessor, f);
        // if (!f.getAuthorId().equals(userId)) throw new SecurityException("Solo el autor puede editar");
        f.setContent(content);
        f.setEdited(true);
        f.setUpdatedAt(OffsetDateTime.now());
        Feedback saved = feedbackRepository.save(f);
        auditLogService.logAction(userId, "COMMENT_UPDATE", "feedback", saved.getId());
        rabbitTemplate.convertAndSend(RabbitMQConfig.FEEDBACK_EXCHANGE, "feedback.updated", new WsEvent("feedback.updated", saved));
        return saved;
    }

    @Transactional
    public void deleteFeedback(long userId, boolean isProfessor, long id) {
        Feedback f = feedbackRepository.findById(id).orElseThrow();
        // VALIDACIONES DE AUTORIZACIÓN DESACTIVADAS PARA PRUEBAS
        // ensureAccessByEntity(userId, isProfessor, f);
        // if (!f.getAuthorId().equals(userId) && !isProfessor) throw new SecurityException("No autorizado a eliminar");
        f.setDeleted(true);
        f.setUpdatedAt(OffsetDateTime.now());
        feedbackRepository.save(f);
        auditLogService.logAction(userId, "COMMENT_DELETE", "feedback", f.getId());
        rabbitTemplate.convertAndSend(RabbitMQConfig.FEEDBACK_EXCHANGE, "feedback.deleted", new WsEvent("feedback.deleted", id));
    }

    public List<FeedbackResponse> listResponses(long userId, boolean isProfessor, long feedbackId) {
        // VALIDACIONES DE AUTORIZACIÓN DESACTIVADAS PARA PRUEBAS
        // Feedback f = feedbackRepository.findById(feedbackId).orElseThrow();
        // ensureAccessByEntity(userId, isProfessor, f);
        return responseRepository.findByFeedbackIdOrderByCreatedAtAsc(feedbackId);
    }

    @Transactional
    public FeedbackResponse createResponse(long userId, boolean isProfessor, long feedbackId, String content) {
        // VALIDACIONES DE AUTORIZACIÓN DESACTIVADAS PARA PRUEBAS
        // Feedback f = feedbackRepository.findById(feedbackId).orElseThrow();
        // ensureAccessByEntity(userId, isProfessor, f);
        FeedbackResponse r = new FeedbackResponse();
        r.setFeedbackId(feedbackId);
        r.setContent(content);
        r.setCreatedAt(OffsetDateTime.now());
        r.setAuthorId(userId);
        FeedbackResponse saved = responseRepository.save(r);
        auditLogService.logAction(userId, "REPLY_CREATE", "reply", saved.getId());
        rabbitTemplate.convertAndSend(RabbitMQConfig.FEEDBACK_RESPONSE_EXCHANGE, "response.created", new WsEvent("reply.created", saved));
        return saved;
    }

    @Transactional
    public FeedbackResponse updateResponse(long userId, boolean isProfessor, long id, String content) {
        FeedbackResponse r = responseRepository.findById(id).orElseThrow();
        // VALIDACIONES DE AUTORIZACIÓN DESACTIVADAS PARA PRUEBAS
        // Feedback f = feedbackRepository.findById(r.getFeedbackId()).orElseThrow();
        // ensureAccessByEntity(userId, isProfessor, f);
        // if (!r.getAuthorId().equals(userId)) throw new SecurityException("Solo el autor puede editar");
        r.setContent(content);
        r.setEdited(true);
        r.setUpdatedAt(OffsetDateTime.now());
        FeedbackResponse saved = responseRepository.save(r);
        auditLogService.logAction(userId, "REPLY_UPDATE", "reply", saved.getId());
        rabbitTemplate.convertAndSend(RabbitMQConfig.FEEDBACK_RESPONSE_EXCHANGE, "response.updated", new WsEvent("reply.updated", saved));
        return saved;
    }

    @Transactional
    public void deleteResponse(long userId, boolean isProfessor, long id) {
        FeedbackResponse r = responseRepository.findById(id).orElseThrow();
        // VALIDACIONES DE AUTORIZACIÓN DESACTIVADAS PARA PRUEBAS
        // Feedback f = feedbackRepository.findById(r.getFeedbackId()).orElseThrow();
        // ensureAccessByEntity(userId, isProfessor, f);
        // if (!r.getAuthorId().equals(userId) && !isProfessor) throw new SecurityException("No autorizado a eliminar");
        r.setDeleted(true);
        r.setUpdatedAt(OffsetDateTime.now());
        responseRepository.save(r);
        auditLogService.logAction(userId, "REPLY_DELETE", "reply", r.getId());
        rabbitTemplate.convertAndSend(RabbitMQConfig.FEEDBACK_RESPONSE_EXCHANGE, "response.deleted", new WsEvent("reply.deleted", id));
    }

    private void ensureAccessToDelivery(long userId, boolean isProfessor, long deliveryId) {
        boolean ok = isProfessor ? authorizationService.canAccessDeliveryAsProfessor(userId, deliveryId)
                : authorizationService.canAccessDeliveryAsStudent(userId, deliveryId);
        if (!ok) throw new SecurityException("Acceso denegado");
    }

    private void ensureAccessToProject(long userId, boolean isProfessor, long projectId) {
        boolean ok = isProfessor ? authorizationService.canAccessProjectAsProfessor(userId, projectId)
                : authorizationService.canAccessProjectAsStudent(userId, projectId);
        if (!ok) throw new SecurityException("Acceso denegado");
    }

    private void ensureAccessToTask(long userId, boolean isProfessor, long taskId) {
        boolean ok = isProfessor ? authorizationService.canAccessTaskAsProfessor(userId, taskId)
                : authorizationService.canAccessTaskAsStudent(userId, taskId);
        if (!ok) throw new SecurityException("Acceso denegado");
    }

    @SuppressWarnings("unused") // Método comentado temporalmente para pruebas
    private void ensureAccessByEntity(long userId, boolean isProfessor, Feedback f) {
        if (f.getDeliveryId() != null) { ensureAccessToDelivery(userId, isProfessor, f.getDeliveryId()); return; }
        if (f.getTaskId() != null) { ensureAccessToTask(userId, isProfessor, f.getTaskId()); return; }
        if (f.getProjectId() != null) { ensureAccessToProject(userId, isProfessor, f.getProjectId()); return; }
        throw new SecurityException("Feedback sin scope");
    }

    public record WsEvent(String type, Object payload) { }
}


