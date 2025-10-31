package com.inosistemas.retroalimentacion.y.comentarios.controller;

import com.inosistemas.retroalimentacion.y.comentarios.domain.Feedback;
import com.inosistemas.retroalimentacion.y.comentarios.domain.FeedbackResponse;
import com.inosistemas.retroalimentacion.y.comentarios.service.FeedbackService;
import jakarta.validation.constraints.NotBlank;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.security.Principal;
import java.util.List;

@RestController
@RequestMapping("/api/v1")
public class FeedbackController {

    private final FeedbackService service;

    public FeedbackController(FeedbackService service) { this.service = service; }

    private record CreateFeedbackRequest(Long projectId, Long taskId, Long deliveryId, @NotBlank String content) {}
    private record UpdateRequest(@NotBlank String content) {}

    // MÉTODOS SIMPLIFICADOS PARA PRUEBAS - Sin restricciones de seguridad
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
    
    private boolean isProfessor(String roleHeader) {
        // Si el header dice "profesor", se usa, sino false - no hay restricciones reales
        return roleHeader != null && roleHeader.equalsIgnoreCase("profesor");
    }

    // ENDPOINT COMPLETAMENTE ABIERTO - Cualquier usuario puede acceder sin restricciones
    @GetMapping("/feedback")
    public List<Feedback> listByScope(@RequestParam(required = false) Long projectId,
                                      @RequestParam(required = false) Long taskId,
                                      @RequestParam(required = false) Long deliveryId,
                                      @RequestHeader(value = "X-User-Role", required = false) String role,
                                      @RequestHeader(value = "X-User-Id", required = false) String userIdHeader,
                                      Principal principal) {
        // Sin validaciones - cualquiera puede listar feedback
        return service.listByScope(userId(principal, userIdHeader), isProfessor(role), projectId, taskId, deliveryId);
    }

    // ENDPOINT COMPLETAMENTE ABIERTO - Cualquier usuario puede crear feedback
    @PostMapping("/feedback")
    public ResponseEntity<Feedback> create(@RequestBody CreateFeedbackRequest req,
                                            @RequestHeader(value = "X-User-Role", required = false) String role,
                                            @RequestHeader(value = "X-User-Id", required = false) String userIdHeader,
                                            Principal principal) {
        // Sin validaciones - cualquiera puede crear feedback
        Feedback created = service.createFeedback(userId(principal, userIdHeader), isProfessor(role), req.projectId(), req.taskId(), req.deliveryId(), req.content());
        return ResponseEntity.ok(created);
    }

    // ENDPOINT COMPLETAMENTE ABIERTO - Cualquier usuario puede actualizar cualquier feedback
    @PatchMapping("/feedback/{id}")
    public Feedback update(@PathVariable long id, @RequestBody UpdateRequest req,
                           @RequestHeader(value = "X-User-Role", required = false) String role,
                           @RequestHeader(value = "X-User-Id", required = false) String userIdHeader,
                           Principal principal) {
        // Sin validaciones - cualquiera puede editar cualquier feedback
        return service.updateFeedback(userId(principal, userIdHeader), isProfessor(role), id, req.content());
    }

    // ENDPOINT COMPLETAMENTE ABIERTO - Cualquier usuario puede eliminar cualquier feedback
    @DeleteMapping("/feedback/{id}")
    public ResponseEntity<Void> delete(@PathVariable long id,
                                       @RequestHeader(value = "X-User-Role", required = false) String role,
                                       @RequestHeader(value = "X-User-Id", required = false) String userIdHeader,
                                       Principal principal) {
        // Sin validaciones - cualquiera puede eliminar cualquier feedback
        service.deleteFeedback(userId(principal, userIdHeader), isProfessor(role), id);
        return ResponseEntity.noContent().build();
    }

    // ENDPOINT COMPLETAMENTE ABIERTO - Cualquier usuario puede ver respuestas
    @GetMapping("/feedback/{id}/responses")
    public List<FeedbackResponse> listResponses(@PathVariable long id,
                                                   @RequestHeader(value = "X-User-Role", required = false) String role,
                                                   @RequestHeader(value = "X-User-Id", required = false) String userIdHeader,
                                                   Principal principal) {
        // Sin validaciones - cualquiera puede ver respuestas
        return service.listResponses(userId(principal, userIdHeader), isProfessor(role), id);
    }

    // ENDPOINT COMPLETAMENTE ABIERTO - Cualquier usuario puede crear respuestas
    @PostMapping("/feedback/{id}/responses")
    public ResponseEntity<FeedbackResponse> createResponse(@PathVariable long id, @RequestBody UpdateRequest req,
                                                           @RequestHeader(value = "X-User-Role", required = false) String role,
                                                           @RequestHeader(value = "X-User-Id", required = false) String userIdHeader,
                                                           Principal principal) {
        // Sin validaciones - cualquiera puede crear respuestas
        FeedbackResponse created = service.createResponse(userId(principal, userIdHeader), isProfessor(role), id, req.content());
        return ResponseEntity.ok(created);
    }

    // ENDPOINT COMPLETAMENTE ABIERTO - Cualquier usuario puede actualizar cualquier respuesta
    @PatchMapping("/feedback-responses/{id}")
    public FeedbackResponse updateResponse(@PathVariable long id, @RequestBody UpdateRequest req,
                                           @RequestHeader(value = "X-User-Role", required = false) String role,
                                           @RequestHeader(value = "X-User-Id", required = false) String userIdHeader,
                                           Principal principal) {
        // Sin validaciones - cualquiera puede editar cualquier respuesta
        return service.updateResponse(userId(principal, userIdHeader), isProfessor(role), id, req.content());
    }

    // ENDPOINT COMPLETAMENTE ABIERTO - Cualquier usuario puede eliminar cualquier respuesta
    @DeleteMapping("/feedback-responses/{id}")
    public ResponseEntity<Void> deleteResponse(@PathVariable long id,
                                               @RequestHeader(value = "X-User-Role", required = false) String role,
                                               @RequestHeader(value = "X-User-Id", required = false) String userIdHeader,
                                               Principal principal) {
        // Sin validaciones - cualquiera puede eliminar cualquier respuesta
        service.deleteResponse(userId(principal, userIdHeader), isProfessor(role), id);
        return ResponseEntity.noContent().build();
    }
}


