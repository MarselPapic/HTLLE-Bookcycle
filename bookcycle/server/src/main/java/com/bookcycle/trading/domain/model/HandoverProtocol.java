package com.bookcycle.trading.domain.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.OneToOne;
import jakarta.persistence.Table;
import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(schema = "trading", name = "handover_protocols")
public class HandoverProtocol {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "purchase_id", nullable = false)
    private Purchase purchase;

    @Column(name = "meeting_time")
    private LocalDateTime meetingTime;

    @Column(name = "meeting_place", length = 200)
    private String meetingPlace;

    @Column(name = "condition_notes", length = 1000)
    private String conditionNotes;

    @Column(name = "buyer_confirmed", nullable = false)
    private boolean buyerConfirmed;

    @Column(name = "seller_confirmed", nullable = false)
    private boolean sellerConfirmed;

    @Column(name = "created_at", nullable = false)
    private LocalDateTime createdAt;

    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;

    protected HandoverProtocol() {
        // JPA
    }

    private HandoverProtocol(Purchase purchase) {
        this.purchase = purchase;
        this.createdAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
        this.buyerConfirmed = false;
        this.sellerConfirmed = false;
    }

    public static HandoverProtocol create(Purchase purchase) {
        return new HandoverProtocol(purchase);
    }

    public void updateDetails(LocalDateTime meetingTime, String meetingPlace, String conditionNotes) {
        this.meetingTime = meetingTime;
        this.meetingPlace = meetingPlace != null ? meetingPlace.trim() : null;
        this.conditionNotes = conditionNotes != null ? conditionNotes.trim() : null;
        this.updatedAt = LocalDateTime.now();
    }

    public void confirmBuyer() {
        this.buyerConfirmed = true;
        this.updatedAt = LocalDateTime.now();
    }

    public void confirmSeller() {
        this.sellerConfirmed = true;
        this.updatedAt = LocalDateTime.now();
    }

    public boolean isFullyConfirmed() {
        return buyerConfirmed && sellerConfirmed;
    }

    public UUID getId() {
        return id;
    }

    public LocalDateTime getMeetingTime() {
        return meetingTime;
    }

    public String getMeetingPlace() {
        return meetingPlace;
    }

    public String getConditionNotes() {
        return conditionNotes;
    }

    public boolean isBuyerConfirmed() {
        return buyerConfirmed;
    }

    public boolean isSellerConfirmed() {
        return sellerConfirmed;
    }
}
