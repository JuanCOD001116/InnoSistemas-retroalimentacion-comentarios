package com.inosistemas.retroalimentacion.y.comentarios.config;

import org.springframework.amqp.core.*;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class RabbitMQConfig {
    
    // Exchange names
    public static final String FEEDBACK_EXCHANGE = "feedback.exchange";
    public static final String FEEDBACK_RESPONSE_EXCHANGE = "feedback.response.exchange";
    
    // Queue names
    public static final String FEEDBACK_TOPIC_QUEUE = "feedback.topic";
    public static final String FEEDBACK_RESPONSE_QUEUE = "feedback.response";
    
    /**
     * Topic exchange for feedback events.
     * Allows routing messages based on patterns.
     */
    @Bean
    public TopicExchange feedbackTopicExchange() {
        return new TopicExchange(FEEDBACK_EXCHANGE);
    }

    /**
     * Topic exchange for feedback response events.
     */
    @Bean
    public TopicExchange feedbackResponseTopicExchange() {
        return new TopicExchange(FEEDBACK_RESPONSE_EXCHANGE);
    }

    /**
     * Queue for feedback events.
     */
    @Bean
    public Queue feedbackTopicQueue() {
        return QueueBuilder.durable(FEEDBACK_TOPIC_QUEUE).build();
    }

    /**
     * Queue for feedback response events.
     */
    @Bean
    public Queue feedbackResponseQueue() {
        return QueueBuilder.durable(FEEDBACK_RESPONSE_QUEUE).build();
    }

    /**
     * Bind feedback queue to feedback exchange.
     */
    @Bean
    public Binding feedbackTopicBinding() {
        return BindingBuilder
            .bind(feedbackTopicQueue())
            .to(feedbackTopicExchange())
            .with("feedback.*");
    }

    /**
     * Bind feedback response queue to response exchange.
     */
    @Bean
    public Binding feedbackResponseBinding() {
        return BindingBuilder
            .bind(feedbackResponseQueue())
            .to(feedbackResponseTopicExchange())
            .with("response.*");
    }
}

