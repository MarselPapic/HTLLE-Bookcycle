package com.bookcycle.trading.application.dto;

import jakarta.validation.constraints.NotNull;
import java.util.UUID;
import lombok.Data;

@Data
public class CheckoutRequest {
    @NotNull
    private UUID listingId;

    @NotNull
    private UUID buyerId;
}
