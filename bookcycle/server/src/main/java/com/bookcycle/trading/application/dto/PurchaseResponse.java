package com.bookcycle.trading.application.dto;

import com.bookcycle.trading.domain.model.PurchaseStatus;
import java.time.LocalDateTime;
import java.util.UUID;
import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class PurchaseResponse {
    private UUID id;
    private UUID listingId;
    private UUID buyerId;
    private UUID sellerId;
    private PurchaseStatus status;
    private LocalDateTime meetingTime;
    private String meetingPlace;
    private String conditionNotes;
    private boolean buyerConfirmed;
    private boolean sellerConfirmed;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
