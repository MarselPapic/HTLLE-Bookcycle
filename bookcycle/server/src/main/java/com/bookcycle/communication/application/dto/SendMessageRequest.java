package com.bookcycle.communication.application.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import java.util.UUID;
import lombok.Data;

@Data
public class SendMessageRequest {
    @NotNull
    private UUID senderId;

    @NotBlank
    private String content;
}
