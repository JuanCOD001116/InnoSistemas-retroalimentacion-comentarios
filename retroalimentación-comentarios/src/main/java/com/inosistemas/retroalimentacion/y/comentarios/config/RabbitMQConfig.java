package com.inosistemas.retroalimentacion.y.comentarios.config;

import org.springframework.amqp.core.Queue;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class RabbitMQConfig {
    
    @Bean
    public Queue feedbackTopicQueue() {
        return new Queue("feedback.topic", false);
    }

    @Bean
    public Queue feedbackResponseQueue() {
        return new Queue("feedback.response", false);
    }
}

