package com.inosistemas.retroalimentacion.y.comentarios.repository;

import com.inosistemas.retroalimentacion.y.comentarios.domain.TeamReport;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.OffsetDateTime;
import java.util.List;

@Repository
public interface TeamReportRepository extends JpaRepository<TeamReport, Long> {

    List<TeamReport> findByProfessorIdOrderByGeneratedAtDesc(Long professorId);

    List<TeamReport> findByTeamIdOrderByGeneratedAtDesc(Long teamId);

    @Query("SELECT tr FROM TeamReport tr WHERE tr.professorId = :professorId " +
            "AND (:courseId IS NULL OR tr.courseId = :courseId) " +
            "AND (:teamId IS NULL OR tr.teamId = :teamId) " +
            "AND (CAST(:fromDate AS timestamp) IS NULL OR tr.generatedAt >= :fromDate) " +
            "ORDER BY tr.generatedAt DESC")
    List<TeamReport> findByFilters(
            @Param("professorId") Long professorId,
            @Param("courseId") Long courseId,
            @Param("teamId") Long teamId,
            @Param("fromDate") OffsetDateTime fromDate);

    List<TeamReport> findByCourseIdOrderByGeneratedAtDesc(Long courseId);
}
