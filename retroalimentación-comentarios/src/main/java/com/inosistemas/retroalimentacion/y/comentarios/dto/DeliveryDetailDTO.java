package com.inosistemas.retroalimentacion.y.comentarios.dto;

import com.inosistemas.retroalimentacion.y.comentarios.domain.Delivery;
import java.util.List;

public class DeliveryDetailDTO {
    private Delivery delivery;
    private List<FeedbackWithResponsesDTO> feedbacks;
    private List<TaskSummaryDTO> tasks;

    public DeliveryDetailDTO() {
    }

    // Getters and Setters
    public Delivery getDelivery() {
        return delivery;
    }

    public void setDelivery(Delivery delivery) {
        this.delivery = delivery;
    }

    public List<FeedbackWithResponsesDTO> getFeedbacks() {
        return feedbacks;
    }

    public void setFeedbacks(List<FeedbackWithResponsesDTO> feedbacks) {
        this.feedbacks = feedbacks;
    }

    public List<TaskSummaryDTO> getTasks() {
        return tasks;
    }

    public void setTasks(List<TaskSummaryDTO> tasks) {
        this.tasks = tasks;
    }
}
