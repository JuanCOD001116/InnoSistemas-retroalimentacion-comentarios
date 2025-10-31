package com.inosistemas.retroalimentacion.y.comentarios.controller;

import com.inosistemas.retroalimentacion.y.comentarios.domain.Feedback;
import com.inosistemas.retroalimentacion.y.comentarios.domain.FeedbackResponse;
import com.inosistemas.retroalimentacion.y.comentarios.service.FeedbackService;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.security.Principal;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import java.util.List;

@RestController
@RequestMapping("/api/v1")
public class FeedbackController {

    private final FeedbackService service;

    public FeedbackController(FeedbackService service) { this.service = service; }

    private record CreateFeedbackRequest(Long projectId, Long taskId, Long deliveryId, @NotBlank String content) {}
    private record UpdateRequest(@NotBlank String content) {}
    private record CreateResponseRequest(@NotNull Long feedbackId, @NotNull Long deliveryId, @NotBlank String content) {}

    private long userId(Principal p) { return Long.parseLong(p.getName()); }
    private boolean isProfessor(String roleHeader) {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth != null) {
            for (GrantedAuthority ga : auth.getAuthorities()) {
                if ("ROLE_PROFESOR".equals(ga.getAuthority())) return true;
            }
        }
        return roleHeader != null && roleHeader.equalsIgnoreCase("profesor");
    }

    @GetMapping("/feedback")
    public List<Feedback> listByScope(@RequestParam(required = false) Long projectId,
                                      @RequestParam(required = false) Long taskId,
                                      @RequestParam(required = false) Long deliveryId,
                                      @RequestHeader(value = "X-User-Role", required = false) String role, Principal principal) {
        return service.listByScope(userId(principal), isProfessor(role), projectId, taskId, deliveryId);
    }

    @PostMapping("/feedback")
    public ResponseEntity<Feedback> create(@RequestBody CreateFeedbackRequest req, @RequestHeader(value = "X-User-Role", required = false) String role, Principal principal) {
        Feedback created = service.createFeedback(userId(principal), isProfessor(role), req.projectId(), req.taskId(), req.deliveryId(), req.content());
        return ResponseEntity.ok(created);
    }

    @PatchMapping("/feedback/{id}")
    public Feedback update(@PathVariable long id, @RequestBody UpdateRequest req, @RequestHeader(value = "X-User-Role", required = false) String role, Principal principal) {
        return service.updateFeedback(userId(principal), isProfessor(role), id, req.content());
    }

    @DeleteMapping("/feedback/{id}")
    public ResponseEntity<Void> delete(@PathVariable long id, @RequestHeader(value = "X-User-Role", required = false) String role, Principal principal) {
        service.deleteFeedback(userId(principal), isProfessor(role), id);
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/feedback/{id}/responses")
    public List<FeedbackResponse> listResponses(@PathVariable long id, @RequestParam long deliveryId, @RequestHeader(value = "X-User-Role", required = false) String role, Principal principal) {
        return service.listResponses(userId(principal), isProfessor(role), id, deliveryId);
    }

    @PostMapping("/feedback/{id}/responses")
    public ResponseEntity<FeedbackResponse> createResponse(@PathVariable long id, @RequestBody UpdateRequest req, @RequestParam long deliveryId, @RequestHeader(value = "X-User-Role", required = false) String role, Principal principal) {
        FeedbackResponse created = service.createResponse(userId(principal), isProfessor(role), id, deliveryId, req.content());
        return ResponseEntity.ok(created);
    }

    @PatchMapping("/feedback-responses/{id}")
    public FeedbackResponse updateResponse(@PathVariable long id, @RequestBody UpdateRequest req, @RequestHeader(value = "X-User-Role", required = false) String role, Principal principal) {
        return service.updateResponse(userId(principal), isProfessor(role), id, req.content());
    }

    @DeleteMapping("/feedback-responses/{id}")
    public ResponseEntity<Void> deleteResponse(@PathVariable long id, @RequestHeader(value = "X-User-Role", required = false) String role, Principal principal) {
        service.deleteResponse(userId(principal), isProfessor(role), id);
        return ResponseEntity.noContent().build();
    }
}


