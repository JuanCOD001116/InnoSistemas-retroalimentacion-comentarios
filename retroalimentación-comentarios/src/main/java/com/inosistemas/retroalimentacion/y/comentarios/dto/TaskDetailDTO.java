package com.inosistemas.retroalimentacion.y.comentarios.dto;

import com.inosistemas.retroalimentacion.y.comentarios.domain.Task;
import java.util.List;

public class TaskDetailDTO {
    private Task task;
    private List<FeedbackWithResponsesDTO> feedbacks;

    public TaskDetailDTO() {
    }

    // Getters and Setters
    public Task getTask() {
        return task;
    }

    public void setTask(Task task) {
        this.task = task;
    }

    public List<FeedbackWithResponsesDTO> getFeedbacks() {
        return feedbacks;
    }

    public void setFeedbacks(List<FeedbackWithResponsesDTO> feedbacks) {
        this.feedbacks = feedbacks;
    }
}
