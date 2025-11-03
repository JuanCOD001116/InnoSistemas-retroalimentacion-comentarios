package com.inosistemas.retroalimentacion.y.comentarios.dto;

import java.time.OffsetDateTime;

public class DeliveryWithCountersDTO {
    private Long id;
    private String title;
    private String description;
    private Long teamId;
    private OffsetDateTime createdAt;
    private OffsetDateTime updatedAt;

    // Contadores
    private long feedbacksCount;
    private long tasksCount;
    private boolean hasUnreadFeedbacks;

    public DeliveryWithCountersDTO() {
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

    public Long getTeamId() {
        return teamId;
    }

    public void setTeamId(Long teamId) {
        this.teamId = teamId;
    }

    public OffsetDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(OffsetDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public OffsetDateTime getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(OffsetDateTime updatedAt) {
        this.updatedAt = updatedAt;
    }

    public long getFeedbacksCount() {
        return feedbacksCount;
    }

    public void setFeedbacksCount(long feedbacksCount) {
        this.feedbacksCount = feedbacksCount;
    }

    public long getTasksCount() {
        return tasksCount;
    }

    public void setTasksCount(long tasksCount) {
        this.tasksCount = tasksCount;
    }

    public boolean isHasUnreadFeedbacks() {
        return hasUnreadFeedbacks;
    }

    public void setHasUnreadFeedbacks(boolean hasUnreadFeedbacks) {
        this.hasUnreadFeedbacks = hasUnreadFeedbacks;
    }
}
