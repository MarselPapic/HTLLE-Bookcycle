package com.bookcycle.moderation.application.dto;

import jakarta.validation.constraints.NotNull;
import java.util.UUID;
import lombok.Data;

@Data
public class ModerationDecisionRequest {
    @NotNull
    private UUID moderatorId;
    private String note;
}
