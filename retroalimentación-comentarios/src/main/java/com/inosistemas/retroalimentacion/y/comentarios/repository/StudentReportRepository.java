package com.inosistemas.retroalimentacion.y.comentarios.repository;

import com.inosistemas.retroalimentacion.y.comentarios.domain.StudentReport;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.OffsetDateTime;
import java.util.List;
import java.util.Optional;

public interface StudentReportRepository extends JpaRepository<StudentReport, Long> {

    @Query("SELECT sr FROM StudentReport sr WHERE sr.studentId = :studentId " +
            "AND (:projectId IS NULL OR sr.projectId = :projectId) " +
            "AND (CAST(:fromDate AS timestamp) IS NULL OR sr.generatedAt >= :fromDate) " +
            "ORDER BY sr.generatedAt DESC")
    List<StudentReport> findByFilters(
            @Param("studentId") Long studentId,
            @Param("projectId") Long projectId,
            @Param("fromDate") OffsetDateTime fromDate);

    Optional<StudentReport> findByStudentIdAndProjectId(Long studentId, Long projectId);

    List<StudentReport> findByStudentIdOrderByGeneratedAtDesc(Long studentId);

    List<StudentReport> findByProjectIdOrderByGeneratedAtDesc(Long projectId);
}
