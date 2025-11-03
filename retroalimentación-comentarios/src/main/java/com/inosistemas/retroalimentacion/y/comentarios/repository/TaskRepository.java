package com.inosistemas.retroalimentacion.y.comentarios.repository;

import com.inosistemas.retroalimentacion.y.comentarios.domain.Task;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface TaskRepository extends JpaRepository<Task, Long> {

    List<Task> findByDeliveryId(Long deliveryId);

    @Query("SELECT COUNT(t) FROM Task t WHERE t.deliveryId = :deliveryId")
    long countByDeliveryId(@Param("deliveryId") Long deliveryId);
}
