package com.bookcycle.communication.application.dto;

import java.time.LocalDateTime;
import java.util.UUID;
import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class ConversationResponse {
    private UUID id;
    private UUID listingId;
    private UUID buyerId;
    private UUID sellerId;
    private LocalDateTime createdAt;
    private LocalDateTime lastMessageAt;
}
