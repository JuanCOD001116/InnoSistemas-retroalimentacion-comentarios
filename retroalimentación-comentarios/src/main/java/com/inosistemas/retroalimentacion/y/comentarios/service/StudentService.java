package com.inosistemas.retroalimentacion.y.comentarios.service;

import com.inosistemas.retroalimentacion.y.comentarios.domain.*;
import com.inosistemas.retroalimentacion.y.comentarios.dto.*;
import com.inosistemas.retroalimentacion.y.comentarios.repository.*;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

@Service
@Transactional(readOnly = true)
public class StudentService {

    private final DeliveryRepository deliveryRepository;
    private final TaskRepository taskRepository;
    private final FeedbackRepository feedbackRepository;
    private final FeedbackResponseRepository responseRepository;

    public StudentService(DeliveryRepository deliveryRepository,
            TaskRepository taskRepository,
            FeedbackRepository feedbackRepository,
            FeedbackResponseRepository responseRepository) {
        this.deliveryRepository = deliveryRepository;
        this.taskRepository = taskRepository;
        this.feedbackRepository = feedbackRepository;
        this.responseRepository = responseRepository;
    }

    /**
     * Lista todas las entregas de un estudiante con contadores
     * Nota: En producción esto debería filtrar por teamIds del estudiante
     */
    public List<DeliveryWithCountersDTO> listStudentDeliveries(Long studentId) {
        // Por simplicidad, listamos todas las deliveries
        // En producción: buscar teamIds donde el estudiante es miembro
        List<Delivery> deliveries = deliveryRepository.findAll();

        return deliveries.stream()
                .map(delivery -> {
                    DeliveryWithCountersDTO dto = new DeliveryWithCountersDTO();
                    dto.setId(delivery.getId());
                    dto.setTitle(delivery.getTitle());
                    dto.setDescription(delivery.getDescription());
                    dto.setTeamId(delivery.getTeamId());
                    dto.setCreatedAt(delivery.getCreatedAt());
                    dto.setUpdatedAt(delivery.getUpdatedAt());

                    // Contar feedbacks de la entrega
                    long feedbacksCount = feedbackRepository.countByDeliveryId(delivery.getId());
                    dto.setFeedbacksCount(feedbacksCount);

                    // Contar tareas de la entrega
                    long tasksCount = taskRepository.countByDeliveryId(delivery.getId());
                    dto.setTasksCount(tasksCount);

                    dto.setHasUnreadFeedbacks(false); // TODO: implementar lógica de lectura

                    return dto;
                })
                .collect(Collectors.toList());
    }

    /**
     * Ver detalle de una entrega con TODAS las retroalimentaciones
     */
    public DeliveryDetailDTO getDeliveryDetail(Long studentId, Long deliveryId) {
        Delivery delivery = deliveryRepository.findById(deliveryId)
                .orElseThrow(() -> new RuntimeException("Delivery not found: " + deliveryId));

        // Obtener feedbacks de la entrega
        List<Feedback> deliveryFeedbacks = feedbackRepository.findByDeliveryId(deliveryId);
        List<FeedbackWithResponsesDTO> feedbackDTOs = new ArrayList<>();

        for (Feedback feedback : deliveryFeedbacks) {
            List<FeedbackResponse> responses = responseRepository.findByFeedbackId(feedback.getId());
            FeedbackWithResponsesDTO dto = new FeedbackWithResponsesDTO();
            dto.setFeedback(feedback);
            dto.setResponses(responses);
            dto.setResponsesCount(responses.size());
            feedbackDTOs.add(dto);
        }

        // Obtener tareas de la entrega con contadores
        List<Task> tasks = taskRepository.findByDeliveryId(deliveryId);
        List<TaskSummaryDTO> taskSummaries = new ArrayList<>();

        for (Task task : tasks) {
            TaskSummaryDTO summary = new TaskSummaryDTO();
            summary.setId(task.getId());
            summary.setTitle(task.getTitle());
            summary.setDescription(task.getDescription());
            summary.setStatus(task.getStatus());

            long taskFeedbacksCount = feedbackRepository.countByTaskId(task.getId());
            summary.setFeedbacksCount(taskFeedbacksCount);

            taskSummaries.add(summary);
        }

        DeliveryDetailDTO result = new DeliveryDetailDTO();
        result.setDelivery(delivery);
        result.setFeedbacks(feedbackDTOs);
        result.setTasks(taskSummaries);

        return result;
    }

    /**
     * Ver detalle de una tarea con sus retroalimentaciones
     */
    public TaskDetailDTO getTaskDetail(Long deliveryId, Long taskId) {
        Task task = taskRepository.findById(taskId)
                .orElseThrow(() -> new RuntimeException("Task not found: " + taskId));

        // Verificar que la tarea pertenece a la entrega
        if (!task.getDeliveryId().equals(deliveryId)) {
            throw new RuntimeException("Task " + taskId + " does not belong to delivery " + deliveryId);
        }

        // Obtener feedbacks de la tarea
        List<Feedback> taskFeedbacks = feedbackRepository.findByTaskId(taskId);
        List<FeedbackWithResponsesDTO> feedbackDTOs = new ArrayList<>();

        for (Feedback feedback : taskFeedbacks) {
            List<FeedbackResponse> responses = responseRepository.findByFeedbackId(feedback.getId());
            FeedbackWithResponsesDTO dto = new FeedbackWithResponsesDTO();
            dto.setFeedback(feedback);
            dto.setResponses(responses);
            dto.setResponsesCount(responses.size());
            feedbackDTOs.add(dto);
        }

        TaskDetailDTO result = new TaskDetailDTO();
        result.setTask(task);
        result.setFeedbacks(feedbackDTOs);

        return result;
    }
}
