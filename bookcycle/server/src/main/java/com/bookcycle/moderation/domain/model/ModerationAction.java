package com.bookcycle.moderation.domain.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(schema = "moderation", name = "moderation_actions")
public class ModerationAction {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "report_id", nullable = false)
    private Report report;

    @Enumerated(EnumType.STRING)
    @Column(name = "action_type", length = 30, nullable = false)
    private ModerationActionType actionType;

    @Column(name = "moderator_id", nullable = false)
    private UUID moderatorId;

    @Column(name = "note", length = 1000)
    private String note;

    @Column(name = "created_at", nullable = false)
    private LocalDateTime createdAt;

    protected ModerationAction() {
        // JPA
    }

    private ModerationAction(Report report, ModerationActionType actionType, UUID moderatorId, String note) {
        this.report = report;
        this.actionType = actionType;
        this.moderatorId = moderatorId;
        this.note = note != null ? note.trim() : null;
        this.createdAt = LocalDateTime.now();
    }

    public static ModerationAction create(Report report, ModerationActionType actionType, UUID moderatorId, String note) {
        return new ModerationAction(report, actionType, moderatorId, note);
    }

    public UUID getId() {
        return id;
    }
}
