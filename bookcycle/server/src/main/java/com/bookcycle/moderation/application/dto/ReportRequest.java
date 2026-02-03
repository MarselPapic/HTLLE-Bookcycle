package com.bookcycle.moderation.application.dto;

import com.bookcycle.moderation.domain.model.ReportReason;
import com.bookcycle.moderation.domain.model.ReportTargetType;
import jakarta.validation.constraints.NotNull;
import java.util.UUID;
import lombok.Data;

@Data
public class ReportRequest {
    @NotNull
    private ReportTargetType targetType;

    @NotNull
    private UUID targetId;

    @NotNull
    private ReportReason reason;

    private String comment;

    @NotNull
    private UUID reporterId;
}
