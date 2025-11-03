package com.inosistemas.retroalimentacion.y.comentarios.controller;

import com.inosistemas.retroalimentacion.y.comentarios.domain.Feedback;
import com.inosistemas.retroalimentacion.y.comentarios.domain.FeedbackResponse;

import java.util.List;

/**
 * DTO para retornar un feedback con todas sus respuestas asociadas.
 */
public record FeedbackWithResponsesDTO(
        Feedback feedback,
        List<FeedbackResponse> responses) {
    /**
     * Constructor estático para crear el DTO desde las entidades.
     */
    public static FeedbackWithResponsesDTO of(Feedback feedback, List<FeedbackResponse> responses) {
        return new FeedbackWithResponsesDTO(feedback, responses);
    }
}
