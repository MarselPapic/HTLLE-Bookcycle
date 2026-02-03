package com.bookcycle.communication.domain.model;

import jakarta.persistence.CascadeType;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.OneToMany;
import jakarta.persistence.Table;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@Entity
@Table(schema = "communication", name = "conversations")
public class Conversation {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(name = "listing_id", nullable = false)
    private UUID listingId;

    @Column(name = "buyer_id", nullable = false)
    private UUID buyerId;

    @Column(name = "seller_id", nullable = false)
    private UUID sellerId;

    @Column(name = "created_at", nullable = false)
    private LocalDateTime createdAt;

    @Column(name = "last_message_at")
    private LocalDateTime lastMessageAt;

    @OneToMany(mappedBy = "conversation", cascade = CascadeType.ALL, orphanRemoval = true, fetch = FetchType.LAZY)
    private List<Message> messages = new ArrayList<>();

    protected Conversation() {
        // JPA
    }

    private Conversation(UUID listingId, UUID buyerId, UUID sellerId) {
        this.listingId = listingId;
        this.buyerId = buyerId;
        this.sellerId = sellerId;
        this.createdAt = LocalDateTime.now();
        this.lastMessageAt = createdAt;
    }

    public static Conversation create(UUID listingId, UUID buyerId, UUID sellerId) {
        return new Conversation(listingId, buyerId, sellerId);
    }

    public void addMessage(Message message) {
        messages.add(message);
        lastMessageAt = message.getSentAt();
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

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public LocalDateTime getLastMessageAt() {
        return lastMessageAt;
    }

    public List<Message> getMessages() {
        return messages;
    }
}
