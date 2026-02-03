package com.bookcycle.communication.application.dto;

import java.time.LocalDateTime;
import java.util.UUID;
import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class MessageResponse {
    private UUID id;
    private UUID senderId;
    private String content;
    private LocalDateTime sentAt;
}
