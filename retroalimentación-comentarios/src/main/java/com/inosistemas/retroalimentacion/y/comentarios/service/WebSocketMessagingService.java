package com.inosistemas.retroalimentacion.y.comentarios.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.inosistemas.retroalimentacion.y.comentarios.config.RabbitMQConfig;
import com.inosistemas.retroalimentacion.y.comentarios.domain.Feedback;
import com.inosistemas.retroalimentacion.y.comentarios.repository.FeedbackRepository;
import org.springframework.amqp.rabbit.annotation.RabbitListener;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Service;

/**
 * Service that bridges RabbitMQ messages to WebSocket clients.
 * Consumes messages from RabbitMQ queues and forwards them to WebSocket topics.
 */
@Service
public class WebSocketMessagingService {

    private final SimpMessagingTemplate messagingTemplate;
    private final ObjectMapper objectMapper;
    private final FeedbackRepository feedbackRepository;

    public WebSocketMessagingService(SimpMessagingTemplate messagingTemplate, 
                                     ObjectMapper objectMapper,
                                     FeedbackRepository feedbackRepository) {
        this.messagingTemplate = messagingTemplate;
        this.objectMapper = objectMapper;
        this.feedbackRepository = feedbackRepository;
    }

    /**
     * Listen to feedback events from RabbitMQ and forward to WebSocket clients.
     * Determines the appropriate STOMP topic based on the feedback scope.
     */
    @RabbitListener(queues = RabbitMQConfig.FEEDBACK_TOPIC_QUEUE)
    public void handleFeedbackEvent(FeedbackService.WsEvent event) {
        try {
            Object payload = event.payload();
            
            // Extract topic from payload
            String topic = determineTopic(payload);
            if (topic != null) {
                // Forward the event to WebSocket clients subscribed to the topic
                messagingTemplate.convertAndSend(topic, event);
            }
        } catch (Exception e) {
            System.err.println("[WebSocket] Error forwarding feedback event: " + e.getMessage());
        }
    }

    /**
     * Listen to feedback response events from RabbitMQ and forward to WebSocket clients.
     */
    @RabbitListener(queues = RabbitMQConfig.FEEDBACK_RESPONSE_QUEUE)
    public void handleResponseEvent(FeedbackService.WsEvent event) {
        try {
            Object payload = event.payload();
            
            // For responses, we need to find the parent feedback to determine the topic
            String topic = determineTopicForResponse(payload);
            if (topic != null) {
                messagingTemplate.convertAndSend(topic, event);
            }
        } catch (Exception e) {
            System.err.println("[WebSocket] Error forwarding response event: " + e.getMessage());
        }
    }

    /**
     * Determine the STOMP topic based on the feedback payload.
     * Topics: /topic/delivery/{id}, /topic/task/{id}, or /topic/project/{id}
     */
    private String determineTopic(Object payload) {
        // If payload is a Feedback entity directly, extract topic from it
        if (payload instanceof Feedback) {
            return determineTopicFromFeedback((Feedback) payload);
        }
        
        // If payload is wrapped in WsEvent, unwrap it
        if (payload instanceof FeedbackService.WsEvent) {
            payload = ((FeedbackService.WsEvent) payload).payload();
            if (payload instanceof Feedback) {
                return determineTopicFromFeedback((Feedback) payload);
            }
        }
        
        try {
            // Convert payload to a Map to extract scope information
            String json = objectMapper.writeValueAsString(payload);
            var map = objectMapper.readValue(json, java.util.Map.class);
            
            Long deliveryId = getLong(map, "deliveryId");
            Long taskId = getLong(map, "taskId");
            Long projectId = getLong(map, "projectId");
            
            if (deliveryId != null) {
                return "/topic/delivery/" + deliveryId;
            } else if (taskId != null) {
                return "/topic/task/" + taskId;
            } else if (projectId != null) {
                return "/topic/project/" + projectId;
            }
        } catch (Exception e) {
            System.err.println("[WebSocket] Error parsing payload: " + e.getMessage());
        }
        
        return null;
    }

    /**
     * Determine topic for response events.
     * Responses need to look up the parent feedback to determine the scope.
     */
    private String determineTopicForResponse(Object payload) {
        try {
            String json = objectMapper.writeValueAsString(payload);
            var map = objectMapper.readValue(json, java.util.Map.class);
            
            Long feedbackId = getLong(map, "feedbackId");
            if (feedbackId != null) {
                // Look up the parent feedback to determine the scope
                return feedbackRepository.findById(feedbackId)
                    .map(this::determineTopicFromFeedback)
                    .orElse(null);
            }
        } catch (Exception e) {
            System.err.println("[WebSocket] Error parsing response payload: " + e.getMessage());
        }
        
        return null;
    }

    /**
     * Determine topic from a Feedback entity.
     */
    private String determineTopicFromFeedback(Feedback feedback) {
        if (feedback.getDeliveryId() != null) {
            return "/topic/delivery/" + feedback.getDeliveryId();
        } else if (feedback.getTaskId() != null) {
            return "/topic/task/" + feedback.getTaskId();
        } else if (feedback.getProjectId() != null) {
            return "/topic/project/" + feedback.getProjectId();
        }
        return null;
    }

    private Long getLong(java.util.Map<?, ?> map, String key) {
        Object value = map.get(key);
        if (value == null) return null;
        if (value instanceof Number) {
            return ((Number) value).longValue();
        }
        if (value instanceof String) {
            try {
                return Long.parseLong((String) value);
            } catch (NumberFormatException e) {
                return null;
            }
        }
        return null;
    }
}

