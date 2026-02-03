package com.bookcycle.communication.domain.service;

import com.bookcycle.communication.domain.model.Conversation;
import com.bookcycle.communication.domain.model.Message;
import com.bookcycle.communication.infrastructure.persistence.ConversationRepository;
import com.bookcycle.communication.infrastructure.persistence.MessageRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;

/**
 * User Story: US-004 Chat
 */
@Service
@RequiredArgsConstructor
public class ChatService {
    private final ConversationRepository conversationRepository;
    private final MessageRepository messageRepository;

    @Transactional
    public Conversation getOrCreateConversation(UUID listingId, UUID buyerId, UUID sellerId) {
        return conversationRepository.findByListingIdAndBuyerIdAndSellerId(listingId, buyerId, sellerId)
            .orElseGet(() -> conversationRepository.save(Conversation.create(listingId, buyerId, sellerId)));
    }

    @Transactional
    public Message sendMessage(UUID conversationId, UUID senderId, String content) {
        Conversation conversation = conversationRepository.findById(conversationId)
            .orElseThrow(() -> new IllegalArgumentException("Conversation not found: " + conversationId));

        Message message = Message.create(conversation, senderId, content);
        conversation.addMessage(message);
        conversationRepository.save(conversation);
        return messageRepository.save(message);
    }

    @Transactional(readOnly = true)
    public List<Message> getMessages(UUID conversationId) {
        return messageRepository.findByConversationIdOrderBySentAtAsc(conversationId);
    }

    @Transactional(readOnly = true)
    public List<Conversation> getConversationsForUser(UUID userId) {
        return conversationRepository.findByBuyerIdOrSellerId(userId, userId);
    }
}
