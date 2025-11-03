package com.inosistemas.retroalimentacion.y.comentarios.dto;

import java.time.OffsetDateTime;
import java.util.List;

public class TeamReportDTO {
    private Long id;
    private Long teamId;
    private String teamName;
    private Long courseId;
    private String courseName;
    private Long professorId;
    private String professorName;
    private OffsetDateTime generatedAt;

    // Datos del reporte
    private List<ProjectSummary> projects;
    private List<FeedbackSummary> feedbacks;
    private ReportStatistics statistics;

    public TeamReportDTO() {
    }

    // Getters and Setters
    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public Long getTeamId() {
        return teamId;
    }

    public void setTeamId(Long teamId) {
        this.teamId = teamId;
    }

    public String getTeamName() {
        return teamName;
    }

    public void setTeamName(String teamName) {
        this.teamName = teamName;
    }

    public Long getCourseId() {
        return courseId;
    }

    public void setCourseId(Long courseId) {
        this.courseId = courseId;
    }

    public String getCourseName() {
        return courseName;
    }

    public void setCourseName(String courseName) {
        this.courseName = courseName;
    }

    public Long getProfessorId() {
        return professorId;
    }

    public void setProfessorId(Long professorId) {
        this.professorId = professorId;
    }

    public String getProfessorName() {
        return professorName;
    }

    public void setProfessorName(String professorName) {
        this.professorName = professorName;
    }

    public OffsetDateTime getGeneratedAt() {
        return generatedAt;
    }

    public void setGeneratedAt(OffsetDateTime generatedAt) {
        this.generatedAt = generatedAt;
    }

    public List<ProjectSummary> getProjects() {
        return projects;
    }

    public void setProjects(List<ProjectSummary> projects) {
        this.projects = projects;
    }

    public List<FeedbackSummary> getFeedbacks() {
        return feedbacks;
    }

    public void setFeedbacks(List<FeedbackSummary> feedbacks) {
        this.feedbacks = feedbacks;
    }

    public ReportStatistics getStatistics() {
        return statistics;
    }

    public void setStatistics(ReportStatistics statistics) {
        this.statistics = statistics;
    }

    // Clases internas
    public static class ProjectSummary {
        private Long projectId;
        private String projectName;
        private int deliveriesCount;
        private int completedTasks;
        private int totalTasks;
        private OffsetDateTime lastDeliveryDate;

        public ProjectSummary() {
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

        public int getDeliveriesCount() {
            return deliveriesCount;
        }

        public void setDeliveriesCount(int deliveriesCount) {
            this.deliveriesCount = deliveriesCount;
        }

        public int getCompletedTasks() {
            return completedTasks;
        }

        public void setCompletedTasks(int completedTasks) {
            this.completedTasks = completedTasks;
        }

        public int getTotalTasks() {
            return totalTasks;
        }

        public void setTotalTasks(int totalTasks) {
            this.totalTasks = totalTasks;
        }

        public OffsetDateTime getLastDeliveryDate() {
            return lastDeliveryDate;
        }

        public void setLastDeliveryDate(OffsetDateTime lastDeliveryDate) {
            this.lastDeliveryDate = lastDeliveryDate;
        }
    }

    public static class FeedbackSummary {
        private String category;
        private int count;
        private String mostCommonTopic;

        public FeedbackSummary() {
        }

        public String getCategory() {
            return category;
        }

        public void setCategory(String category) {
            this.category = category;
        }

        public int getCount() {
            return count;
        }

        public void setCount(int count) {
            this.count = count;
        }

        public String getMostCommonTopic() {
            return mostCommonTopic;
        }

        public void setMostCommonTopic(String mostCommonTopic) {
            this.mostCommonTopic = mostCommonTopic;
        }
    }

    public static class ReportStatistics {
        private int totalDeliveries;
        private int totalFeedbacks;
        private int totalResponses;
        private double averageResponseTime; // en horas
        private int pendingDeliveries;

        public ReportStatistics() {
        }

        public int getTotalDeliveries() {
            return totalDeliveries;
        }

        public void setTotalDeliveries(int totalDeliveries) {
            this.totalDeliveries = totalDeliveries;
        }

        public int getTotalFeedbacks() {
            return totalFeedbacks;
        }

        public void setTotalFeedbacks(int totalFeedbacks) {
            this.totalFeedbacks = totalFeedbacks;
        }

        public int getTotalResponses() {
            return totalResponses;
        }

        public void setTotalResponses(int totalResponses) {
            this.totalResponses = totalResponses;
        }

        public double getAverageResponseTime() {
            return averageResponseTime;
        }

        public void setAverageResponseTime(double averageResponseTime) {
            this.averageResponseTime = averageResponseTime;
        }

        public int getPendingDeliveries() {
            return pendingDeliveries;
        }

        public void setPendingDeliveries(int pendingDeliveries) {
            this.pendingDeliveries = pendingDeliveries;
        }
    }
}
