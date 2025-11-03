package com.inosistemas.retroalimentacion.y.comentarios.controller;

import com.inosistemas.retroalimentacion.y.comentarios.dto.*;
import com.inosistemas.retroalimentacion.y.comentarios.service.ProfessorService;
import com.inosistemas.retroalimentacion.y.comentarios.service.StudentService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1")
public class ProfessorController {

    private final ProfessorService professorService;
    private final StudentService studentService;

    public ProfessorController(ProfessorService professorService,
            StudentService studentService) {
        this.professorService = professorService;
        this.studentService = studentService;
    }

    /**
     * Listar entregas pendientes de revisión (sin feedbacks)
     * GET /api/v1/professor/deliveries/pending
     */
    @GetMapping("/professor/deliveries/pending")
    public ResponseEntity<List<DeliveryWithCountersDTO>> listPendingDeliveries() {
        List<DeliveryWithCountersDTO> deliveries = professorService.listPendingDeliveries();
        return ResponseEntity.ok(deliveries);
    }

    /**
     * Listar todas las entregas con filtros
     * GET /api/v1/professor/deliveries?status=pending|reviewed|all&teamId=1
     */
    @GetMapping("/professor/deliveries")
    public ResponseEntity<List<DeliveryWithCountersDTO>> listAllDeliveries(
            @RequestParam(required = false) String status,
            @RequestParam(required = false) Long teamId) {

        List<DeliveryWithCountersDTO> deliveries = professorService.listAllDeliveries(status, teamId);
        return ResponseEntity.ok(deliveries);
    }

    /**
     * Ver detalle de una entrega para revisar
     * GET /api/v1/professor/deliveries/{deliveryId}
     */
    @GetMapping("/professor/deliveries/{deliveryId}")
    public ResponseEntity<DeliveryDetailDTO> getDeliveryForReview(
            @PathVariable Long deliveryId) {

        DeliveryDetailDTO detail = professorService.getDeliveryForReview(deliveryId);
        return ResponseEntity.ok(detail);
    }

    /**
     * Buscar feedbacks por contenido
     * GET
     * /api/v1/feedback/search?query=validación&deliveryId=1&taskId=1&projectId=1
     */
    @GetMapping("/feedback/search")
    public ResponseEntity<List<FeedbackWithResponsesDTO>> searchFeedbacks(
            @RequestParam String query,
            @RequestParam(required = false) Long deliveryId,
            @RequestParam(required = false) Long taskId,
            @RequestParam(required = false) Long projectId) {

        List<FeedbackWithResponsesDTO> feedbacks = professorService.searchFeedbacks(
                query, deliveryId, taskId, projectId);
        return ResponseEntity.ok(feedbacks);
    }

    /**
     * Ver tarea específica con retroalimentaciones
     * GET /api/v1/deliveries/{deliveryId}/tasks/{taskId}
     */
    @GetMapping("/deliveries/{deliveryId}/tasks/{taskId}")
    public ResponseEntity<TaskDetailDTO> getTaskDetail(
            @PathVariable Long deliveryId,
            @PathVariable Long taskId) {

        TaskDetailDTO detail = studentService.getTaskDetail(deliveryId, taskId);
        return ResponseEntity.ok(detail);
    }
}
