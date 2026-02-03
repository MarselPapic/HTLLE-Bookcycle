package com.bookcycle.moderation.infrastructure.persistence;

import com.bookcycle.moderation.domain.model.Report;
import com.bookcycle.moderation.domain.model.ReportStatus;
import java.util.List;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ReportRepository extends JpaRepository<Report, UUID> {
    List<Report> findByStatus(ReportStatus status);
}
