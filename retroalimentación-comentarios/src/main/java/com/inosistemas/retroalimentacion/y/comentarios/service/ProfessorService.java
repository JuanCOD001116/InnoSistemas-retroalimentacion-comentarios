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
public class ProfessorService {

    private final DeliveryRepository deliveryRepository;
    private final TaskRepository taskRepository;
    private final FeedbackRepository feedbackRepository;
    private final FeedbackResponseRepository responseRepository;

    public ProfessorService(DeliveryRepository deliveryRepository,
            TaskRepository taskRepository,
            FeedbackRepository feedbackRepository,
            FeedbackResponseRepository responseRepository) {
        this.deliveryRepository = deliveryRepository;
        this.taskRepository = taskRepository;
        this.feedbackRepository = feedbackRepository;
        this.responseRepository = responseRepository;
    }

    /**
     * Listar entregas pendientes de revisión (sin feedbacks)
     */
    public List<DeliveryWithCountersDTO> listPendingDeliveries() {
        List<Delivery> allDeliveries = deliveryRepository.findAll();

        return allDeliveries.stream()
                .map(delivery -> {
                    DeliveryWithCountersDTO dto = new DeliveryWithCountersDTO();
                    dto.setId(delivery.getId());
                    dto.setTitle(delivery.getTitle());
                    dto.setDescription(delivery.getDescription());
                    dto.setTeamId(delivery.getTeamId());
                    dto.setCreatedAt(delivery.getCreatedAt());
                    dto.setUpdatedAt(delivery.getUpdatedAt());

                    long feedbacksCount = feedbackRepository.countByDeliveryId(delivery.getId());
                    dto.setFeedbacksCount(feedbacksCount);

                    long tasksCount = taskRepository.countByDeliveryId(delivery.getId());
                    dto.setTasksCount(tasksCount);

                    dto.setHasUnreadFeedbacks(false);

                    return dto;
                })
                .filter(dto -> dto.getFeedbacksCount() == 0) // Solo entregas sin feedbacks
                .collect(Collectors.toList());
    }

    /**
     * Listar todas las entregas con filtros opcionales
     */
    public List<DeliveryWithCountersDTO> listAllDeliveries(String status, Long teamId) {
        List<Delivery> deliveries;

        if (teamId != null) {
            deliveries = deliveryRepository.findByTeamId(teamId);
        } else {
            deliveries = deliveryRepository.findAll();
        }

        return deliveries.stream()
                .map(delivery -> {
                    DeliveryWithCountersDTO dto = new DeliveryWithCountersDTO();
                    dto.setId(delivery.getId());
                    dto.setTitle(delivery.getTitle());
                    dto.setDescription(delivery.getDescription());
                    dto.setTeamId(delivery.getTeamId());
                    dto.setCreatedAt(delivery.getCreatedAt());
                    dto.setUpdatedAt(delivery.getUpdatedAt());

                    long feedbacksCount = feedbackRepository.countByDeliveryId(delivery.getId());
                    dto.setFeedbacksCount(feedbacksCount);

                    long tasksCount = taskRepository.countByDeliveryId(delivery.getId());
                    dto.setTasksCount(tasksCount);

                    dto.setHasUnreadFeedbacks(false);

                    return dto;
                })
                .filter(dto -> {
                    if ("pending".equalsIgnoreCase(status)) {
                        return dto.getFeedbacksCount() == 0;
                    } else if ("reviewed".equalsIgnoreCase(status)) {
                        return dto.getFeedbacksCount() > 0;
                    }
                    // "all" o null = sin filtrar
                    return true;
                })
                .collect(Collectors.toList());
    }

    /**
     * Ver detalle de entrega para revisar (mismo que estudiantes)
     */
    public DeliveryDetailDTO getDeliveryForReview(Long deliveryId) {
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
     * Buscar feedbacks por contenido
     */
    public List<FeedbackWithResponsesDTO> searchFeedbacks(String query, Long deliveryId, Long taskId, Long projectId) {
        List<Feedback> feedbacks;

        if (deliveryId != null) {
            feedbacks = feedbackRepository.findByDeliveryId(deliveryId);
        } else if (taskId != null) {
            feedbacks = feedbackRepository.findByTaskId(taskId);
        } else if (projectId != null) {
            feedbacks = feedbackRepository.findByProjectId(projectId);
        } else {
            feedbacks = feedbackRepository.findAll();
        }

        // Filtrar por contenido
        List<Feedback> filtered = feedbacks.stream()
                .filter(f -> f.getContent().toLowerCase().contains(query.toLowerCase()))
                .collect(Collectors.toList());

        // Convertir a DTOs con respuestas
        List<FeedbackWithResponsesDTO> result = new ArrayList<>();
        for (Feedback feedback : filtered) {
            List<FeedbackResponse> responses = responseRepository.findByFeedbackId(feedback.getId());
            FeedbackWithResponsesDTO dto = new FeedbackWithResponsesDTO();
            dto.setFeedback(feedback);
            dto.setResponses(responses);
            dto.setResponsesCount(responses.size());
            result.add(dto);
        }

        return result;
    }
}
