package com.inosistemas.retroalimentacion.y.comentarios.dto;

import com.inosistemas.retroalimentacion.y.comentarios.domain.Feedback;
import com.inosistemas.retroalimentacion.y.comentarios.domain.FeedbackResponse;
import java.util.List;

public class FeedbackWithResponsesDTO {
    private Feedback feedback;
    private List<FeedbackResponse> responses;
    private int responsesCount;

    public FeedbackWithResponsesDTO() {
    }

    // Getters and Setters
    public Feedback getFeedback() {
        return feedback;
    }

    public void setFeedback(Feedback feedback) {
        this.feedback = feedback;
    }

    public List<FeedbackResponse> getResponses() {
        return responses;
    }

    public void setResponses(List<FeedbackResponse> responses) {
        this.responses = responses;
    }

    public int getResponsesCount() {
        return responsesCount;
    }

    public void setResponsesCount(int responsesCount) {
        this.responsesCount = responsesCount;
    }
}
