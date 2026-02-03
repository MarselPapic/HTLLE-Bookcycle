package com.bookcycle.moderation.application.dto;

import com.bookcycle.moderation.domain.model.ReportReason;
import com.bookcycle.moderation.domain.model.ReportStatus;
import com.bookcycle.moderation.domain.model.ReportTargetType;
import java.time.LocalDateTime;
import java.util.UUID;
import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class ReportResponse {
    private UUID id;
    private ReportTargetType targetType;
    private UUID targetId;
    private ReportReason reason;
    private String comment;
    private UUID reporterId;
    private ReportStatus status;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
