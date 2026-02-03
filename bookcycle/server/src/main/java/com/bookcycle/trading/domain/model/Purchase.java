package com.bookcycle.trading.domain.model;

import jakarta.persistence.CascadeType;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.OneToOne;
import jakarta.persistence.Table;
import java.time.LocalDateTime;
import java.util.Objects;
import java.util.UUID;

@Entity
@Table(schema = "trading", name = "purchases")
public class Purchase {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(name = "listing_id", nullable = false)
    private UUID listingId;

    @Column(name = "buyer_id", nullable = false)
    private UUID buyerId;

    @Column(name = "seller_id", nullable = false)
    private UUID sellerId;

    @Enumerated(EnumType.STRING)
    @Column(name = "status", length = 30, nullable = false)
    private PurchaseStatus status;

    @OneToOne(mappedBy = "purchase", cascade = CascadeType.ALL, orphanRemoval = true, fetch = FetchType.LAZY)
    private HandoverProtocol handoverProtocol;

    @Column(name = "created_at", nullable = false)
    private LocalDateTime createdAt;

    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;

    protected Purchase() {
        // JPA
    }

    private Purchase(UUID listingId, UUID buyerId, UUID sellerId) {
        this.listingId = Objects.requireNonNull(listingId, "listingId cannot be null");
        this.buyerId = Objects.requireNonNull(buyerId, "buyerId cannot be null");
        this.sellerId = Objects.requireNonNull(sellerId, "sellerId cannot be null");
        this.status = PurchaseStatus.PENDING;
        this.createdAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
    }

    public static Purchase create(UUID listingId, UUID buyerId, UUID sellerId) {
        return new Purchase(listingId, buyerId, sellerId);
    }

    public void startHandover() {
        if (status == PurchaseStatus.CANCELLED) {
            throw new IllegalStateException("Purchase is cancelled");
        }
        status = PurchaseStatus.HANDOVER_IN_PROGRESS;
        updatedAt = LocalDateTime.now();
        if (handoverProtocol == null) {
            handoverProtocol = HandoverProtocol.create(this);
        }
    }

    public void cancel() {
        status = PurchaseStatus.CANCELLED;
        updatedAt = LocalDateTime.now();
    }

    public void markHandedOver() {
        status = PurchaseStatus.HANDED_OVER;
        updatedAt = LocalDateTime.now();
    }

    public UUID getId() {
        return id;
    }

    public UUID getListingId() {
        return listingId;
    }

    public UUID getBuyerId() {
        return buyerId;
    }

    public UUID getSellerId() {
        return sellerId;
    }

    public PurchaseStatus getStatus() {
        return status;
    }

    public HandoverProtocol getHandoverProtocol() {
        return handoverProtocol;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }
}
