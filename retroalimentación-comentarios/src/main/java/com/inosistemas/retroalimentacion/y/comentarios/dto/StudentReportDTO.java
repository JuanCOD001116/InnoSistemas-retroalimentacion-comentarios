package com.inosistemas.retroalimentacion.y.comentarios.dto;

import java.time.OffsetDateTime;
import java.util.List;

public class StudentReportDTO {
    private Long id;
    private Long studentId;
    private String studentName;
    private Long projectId;
    private String projectName;
    private Double finalGrade;
    private OffsetDateTime generatedAt;
    private List<DeliverySummary> deliveries;
    private List<FeedbackItem> feedbackReceived;
    private List<ResponseItem> responsesGiven;
    private ReportStatistics statistics;

    // Constructors
    public StudentReportDTO() {
    }

    // Inner class for delivery summary
    public static class DeliverySummary {
        private Long deliveryId;
        private String deliveryTitle;
        private OffsetDateTime submittedAt;
        private Integer tasksCompleted;
        private Integer totalTasks;
        private Integer feedbackCount;

        public DeliverySummary() {
        }

        public Long getDeliveryId() {
            return deliveryId;
        }

        public void setDeliveryId(Long deliveryId) {
            this.deliveryId = deliveryId;
        }

        public String getDeliveryTitle() {
            return deliveryTitle;
        }

        public void setDeliveryTitle(String deliveryTitle) {
            this.deliveryTitle = deliveryTitle;
        }

        public OffsetDateTime getSubmittedAt() {
            return submittedAt;
        }

        public void setSubmittedAt(OffsetDateTime submittedAt) {
            this.submittedAt = submittedAt;
        }

        public Integer getTasksCompleted() {
            return tasksCompleted;
        }

        public void setTasksCompleted(Integer tasksCompleted) {
            this.tasksCompleted = tasksCompleted;
        }

        public Integer getTotalTasks() {
            return totalTasks;
        }

        public void setTotalTasks(Integer totalTasks) {
            this.totalTasks = totalTasks;
        }

        public Integer getFeedbackCount() {
            return feedbackCount;
        }

        public void setFeedbackCount(Integer feedbackCount) {
            this.feedbackCount = feedbackCount;
        }
    }

    // Inner class for feedback item
    public static class FeedbackItem {
        private Long feedbackId;
        private String content;
        private OffsetDateTime createdAt;
        private String scope; // "delivery", "task", or "project"
        private Long scopeId;
        private String scopeName;
        private Long authorId;
        private String authorName;

        public FeedbackItem() {
        }

        public Long getFeedbackId() {
            return feedbackId;
        }

        public void setFeedbackId(Long feedbackId) {
            this.feedbackId = feedbackId;
        }

        public String getContent() {
            return content;
        }

        public void setContent(String content) {
            this.content = content;
        }

        public OffsetDateTime getCreatedAt() {
            return createdAt;
        }

        public void setCreatedAt(OffsetDateTime createdAt) {
            this.createdAt = createdAt;
        }

        public String getScope() {
            return scope;
        }

        public void setScope(String scope) {
            this.scope = scope;
        }

        public Long getScopeId() {
            return scopeId;
        }

        public void setScopeId(Long scopeId) {
            this.scopeId = scopeId;
        }

        public String getScopeName() {
            return scopeName;
        }

        public void setScopeName(String scopeName) {
            this.scopeName = scopeName;
        }

        public Long getAuthorId() {
            return authorId;
        }

        public void setAuthorId(Long authorId) {
            this.authorId = authorId;
        }

        public String getAuthorName() {
            return authorName;
        }

        public void setAuthorName(String authorName) {
            this.authorName = authorName;
        }
    }

    // Inner class for response item
    public static class ResponseItem {
        private Long responseId;
        private Long feedbackId;
        private String content;
        private OffsetDateTime createdAt;

        public ResponseItem() {
        }

        public Long getResponseId() {
            return responseId;
        }

        public void setResponseId(Long responseId) {
            this.responseId = responseId;
        }

        public Long getFeedbackId() {
            return feedbackId;
        }

        public void setFeedbackId(Long feedbackId) {
            this.feedbackId = feedbackId;
        }

        public String getContent() {
            return content;
        }

        public void setContent(String content) {
            this.content = content;
        }

        public OffsetDateTime getCreatedAt() {
            return createdAt;
        }

        public void setCreatedAt(OffsetDateTime createdAt) {
            this.createdAt = createdAt;
        }
    }

    // Inner class for statistics
    public static class ReportStatistics {
        private Integer totalDeliveries;
        private Integer totalFeedbackReceived;
        private Integer totalResponsesGiven;
        private Integer completedTasks;
        private Integer totalTasks;
        private Double taskCompletionRate;
        private Double averageResponseTimeHours;

        public ReportStatistics() {
        }

        public Integer getTotalDeliveries() {
            return totalDeliveries;
        }

        public void setTotalDeliveries(Integer totalDeliveries) {
            this.totalDeliveries = totalDeliveries;
        }

        public Integer getTotalFeedbackReceived() {
            return totalFeedbackReceived;
        }

        public void setTotalFeedbackReceived(Integer totalFeedbackReceived) {
            this.totalFeedbackReceived = totalFeedbackReceived;
        }

        public Integer getTotalResponsesGiven() {
            return totalResponsesGiven;
        }

        public void setTotalResponsesGiven(Integer totalResponsesGiven) {
            this.totalResponsesGiven = totalResponsesGiven;
        }

        public Integer getCompletedTasks() {
            return completedTasks;
        }

        public void setCompletedTasks(Integer completedTasks) {
            this.completedTasks = completedTasks;
        }

        public Integer getTotalTasks() {
            return totalTasks;
        }

        public void setTotalTasks(Integer totalTasks) {
            this.totalTasks = totalTasks;
        }

        public Double getTaskCompletionRate() {
            return taskCompletionRate;
        }

        public void setTaskCompletionRate(Double taskCompletionRate) {
            this.taskCompletionRate = taskCompletionRate;
        }

        public Double getAverageResponseTimeHours() {
            return averageResponseTimeHours;
        }

        public void setAverageResponseTimeHours(Double averageResponseTimeHours) {
            this.averageResponseTimeHours = averageResponseTimeHours;
        }
    }

    // Main DTO Getters and Setters
    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public Long getStudentId() {
        return studentId;
    }

    public void setStudentId(Long studentId) {
        this.studentId = studentId;
    }

    public String getStudentName() {
        return studentName;
    }

    public void setStudentName(String studentName) {
        this.studentName = studentName;
    }

    public Long getProjectId() {
        return projectId;
    }

    public void setProjectId(Long projectId) {
        this.projectId = projectId;
    }

    public String getProjectName() {
        return projectName;
    }

    public void setProjectName(String projectName) {
        this.projectName = projectName;
    }

    public Double getFinalGrade() {
        return finalGrade;
    }

    public void setFinalGrade(Double finalGrade) {
        this.finalGrade = finalGrade;
    }

    public OffsetDateTime getGeneratedAt() {
        return generatedAt;
    }

    public void setGeneratedAt(OffsetDateTime generatedAt) {
        this.generatedAt = generatedAt;
    }

    public List<DeliverySummary> getDeliveries() {
        return deliveries;
    }

    public void setDeliveries(List<DeliverySummary> deliveries) {
        this.deliveries = deliveries;
    }

    public List<FeedbackItem> getFeedbackReceived() {
        return feedbackReceived;
    }

    public void setFeedbackReceived(List<FeedbackItem> feedbackReceived) {
        this.feedbackReceived = feedbackReceived;
    }

    public List<ResponseItem> getResponsesGiven() {
        return responsesGiven;
    }

    public void setResponsesGiven(List<ResponseItem> responsesGiven) {
        this.responsesGiven = responsesGiven;
    }

    public ReportStatistics getStatistics() {
        return statistics;
    }

    public void setStatistics(ReportStatistics statistics) {
        this.statistics = statistics;
    }
}
