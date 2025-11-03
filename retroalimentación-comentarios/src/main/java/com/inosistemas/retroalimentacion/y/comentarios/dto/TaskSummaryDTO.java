package com.inosistemas.retroalimentacion.y.comentarios.dto;

public class TaskSummaryDTO {
    private Long id;
    private String title;
    private String description;
    private String status;
    private long feedbacksCount;

    public TaskSummaryDTO() {
    }

    // Getters and Setters
    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public long getFeedbacksCount() {
        return feedbacksCount;
    }

    public void setFeedbacksCount(long feedbacksCount) {
        this.feedbacksCount = feedbacksCount;
    }
}
