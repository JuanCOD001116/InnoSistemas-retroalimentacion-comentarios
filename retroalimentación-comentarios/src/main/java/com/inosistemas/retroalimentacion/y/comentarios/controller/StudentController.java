package com.inosistemas.retroalimentacion.y.comentarios.controller;

import com.inosistemas.retroalimentacion.y.comentarios.dto.*;
import com.inosistemas.retroalimentacion.y.comentarios.service.StudentService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/students")
public class StudentController {

    private final StudentService studentService;

    public StudentController(StudentService studentService) {
        this.studentService = studentService;
    }

    /**
     * Lista todas las entregas del estudiante con contadores
     * GET /api/v1/students/{studentId}/deliveries
     */
    @GetMapping("/{studentId}/deliveries")
    public ResponseEntity<List<DeliveryWithCountersDTO>> listStudentDeliveries(
            @PathVariable Long studentId) {

        List<DeliveryWithCountersDTO> deliveries = studentService.listStudentDeliveries(studentId);
        return ResponseEntity.ok(deliveries);
    }

    /**
     * Ver detalle de una entrega con TODAS las retroalimentaciones
     * GET /api/v1/students/{studentId}/deliveries/{deliveryId}
     */
    @GetMapping("/{studentId}/deliveries/{deliveryId}")
    public ResponseEntity<DeliveryDetailDTO> getDeliveryDetail(
            @PathVariable Long studentId,
            @PathVariable Long deliveryId) {

        DeliveryDetailDTO detail = studentService.getDeliveryDetail(studentId, deliveryId);
        return ResponseEntity.ok(detail);
    }
}
