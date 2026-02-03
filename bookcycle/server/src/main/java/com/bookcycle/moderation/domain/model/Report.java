package com.bookcycle.moderation.domain.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(schema = "moderation", name = "reports")
public class Report {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Enumerated(EnumType.STRING)
    @Column(name = "target_type", length = 20, nullable = false)
    private ReportTargetType targetType;

    @Column(name = "target_id", nullable = false)
    private UUID targetId;

    @Enumerated(EnumType.STRING)
    @Column(name = "reason", length = 30, nullable = false)
    private ReportReason reason;

    @Column(name = "comment", length = 1000)
    private String comment;

    @Column(name = "reporter_id", nullable = false)
    private UUID reporterId;

    @Enumerated(EnumType.STRING)
    @Column(name = "status", length = 20, nullable = false)
    private ReportStatus status;

    @Column(name = "created_at", nullable = false)
    private LocalDateTime createdAt;

    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;

    protected Report() {
        // JPA
    }

    private Report(ReportTargetType targetType, UUID targetId, ReportReason reason, String comment, UUID reporterId) {
        this.targetType = targetType;
        this.targetId = targetId;
        this.reason = reason;
        this.comment = comment != null ? comment.trim() : null;
        this.reporterId = reporterId;
        this.status = ReportStatus.OPEN;
        this.createdAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
    }

    public static Report create(ReportTargetType targetType, UUID targetId, ReportReason reason, String comment, UUID reporterId) {
        return new Report(targetType, targetId, reason, comment, reporterId);
    }

    public void markHidden() {
        status = ReportStatus.HIDDEN;
        updatedAt = LocalDateTime.now();
    }

    public void resolve() {
        status = ReportStatus.RESOLVED;
        updatedAt = LocalDateTime.now();
    }

    public UUID getId() {
        return id;
    }

    public ReportTargetType getTargetType() {
        return targetType;
    }

    public UUID getTargetId() {
        return targetId;
    }

    public ReportReason getReason() {
        return reason;
    }

    public String getComment() {
        return comment;
    }

    public UUID getReporterId() {
        return reporterId;
    }

    public ReportStatus getStatus() {
        return status;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }
}
