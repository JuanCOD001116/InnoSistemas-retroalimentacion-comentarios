package com.inosistemas.retroalimentacion.y.comentarios.service;

import com.inosistemas.retroalimentacion.y.comentarios.config.RabbitMQConfig;
import org.springframework.amqp.rabbit.annotation.RabbitListener;
import org.springframework.stereotype.Component;

/**
 * Optional listener for logging RabbitMQ events.
 * WebSocketMessagingService handles forwarding messages to WebSocket clients.
 */
@Component
public class NotificationListener {

    @RabbitListener(queues = RabbitMQConfig.FEEDBACK_TOPIC_QUEUE)
    public void handleFeedbackEvent(Object event) {
        System.out.println("[RabbitMQ] Evento feedback: " + event);
    }

    @RabbitListener(queues = RabbitMQConfig.FEEDBACK_RESPONSE_QUEUE)
    public void handleResponseEvent(Object event) {
        System.out.println("[RabbitMQ] Evento respuesta: " + event);
    }
}



