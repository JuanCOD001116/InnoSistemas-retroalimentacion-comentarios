package com.inosistemas.retroalimentacion.y.comentarios.repository;

import com.inosistemas.retroalimentacion.y.comentarios.domain.Delivery;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface DeliveryRepository extends JpaRepository<Delivery, Long> {

    List<Delivery> findByTeamId(Long teamId);

    @Query("SELECT d FROM Delivery d WHERE d.teamId IN :teamIds")
    List<Delivery> findByTeamIdIn(@Param("teamIds") List<Long> teamIds);
}
