package com.inosistemas.retroalimentacion.y.comentarios.repository;

import com.inosistemas.retroalimentacion.y.comentarios.domain.FeedbackResponse;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface FeedbackResponseRepository extends JpaRepository<FeedbackResponse, Long> {

    @Query("select r from FeedbackResponse r where r.feedbackId = :feedbackId and r.deleted = false order by r.createdAt asc")
    List<FeedbackResponse> findByFeedbackIdOrderByCreatedAtAsc(@Param("feedbackId") Long feedbackId);
}


