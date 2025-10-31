package com.inosistemas.retroalimentacion.y.comentarios.service;

import org.springframework.amqp.rabbit.annotation.RabbitListener;
import org.springframework.stereotype.Component;

@Component
public class NotificationListener {

    @RabbitListener(queues = "feedback.topic")
    public void handleFeedbackEvent(Object event) {
        System.out.println("[RabbitMQ] Evento feedback: " + event);
    }

    @RabbitListener(queues = "feedback.response")
    public void handleResponseEvent(Object event) {
        System.out.println("[RabbitMQ] Evento respuesta: " + event);
    }
}



