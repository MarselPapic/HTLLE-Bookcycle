package com.bookcycle.communication.domain.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(schema = "communication", name = "messages")
public class Message {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "conversation_id", nullable = false)
    private Conversation conversation;

    @Column(name = "sender_id", nullable = false)
    private UUID senderId;

    @Column(name = "content", length = 2000, nullable = false)
    private String content;

    @Column(name = "sent_at", nullable = false)
    private LocalDateTime sentAt;

    protected Message() {
        // JPA
    }

    private Message(Conversation conversation, UUID senderId, String content) {
        this.conversation = conversation;
        this.senderId = senderId;
        this.content = content;
        this.sentAt = LocalDateTime.now();
    }

    public static Message create(Conversation conversation, UUID senderId, String content) {
        if (content == null || content.trim().isEmpty()) {
            throw new IllegalArgumentException("message content cannot be empty");
        }
        return new Message(conversation, senderId, content.trim());
    }

    public UUID getId() {
        return id;
    }

    public UUID getSenderId() {
        return senderId;
    }

    public String getContent() {
        return content;
    }

    public LocalDateTime getSentAt() {
        return sentAt;
    }
}
