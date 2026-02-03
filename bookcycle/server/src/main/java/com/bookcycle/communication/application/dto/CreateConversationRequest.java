package com.bookcycle.communication.application.dto;

import jakarta.validation.constraints.NotNull;
import java.util.UUID;
import lombok.Data;

@Data
public class CreateConversationRequest {
    @NotNull
    private UUID listingId;

    @NotNull
    private UUID buyerId;

    @NotNull
    private UUID sellerId;
}
