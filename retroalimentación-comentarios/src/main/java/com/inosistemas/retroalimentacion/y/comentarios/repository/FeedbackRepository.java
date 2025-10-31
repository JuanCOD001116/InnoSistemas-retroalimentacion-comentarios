package com.inosistemas.retroalimentacion.y.comentarios.repository;

import com.inosistemas.retroalimentacion.y.comentarios.domain.Feedback;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface FeedbackRepository extends JpaRepository<Feedback, Long> {

    @Query("select f from Feedback f where f.deliveryId = :deliveryId and f.deleted = false order by f.createdAt asc")
    List<Feedback> findByDeliveryIdOrderByCreatedAtAsc(@Param("deliveryId") Long deliveryId);

    @Query("select f from Feedback f where f.projectId = :projectId and f.deleted = false order by f.createdAt asc")
    List<Feedback> findByProjectIdOrderByCreatedAtAsc(@Param("projectId") Long projectId);

    @Query("select f from Feedback f where f.taskId = :taskId and f.deleted = false order by f.createdAt asc")
    List<Feedback> findByTaskIdOrderByCreatedAtAsc(@Param("taskId") Long taskId);
}


