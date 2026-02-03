package com.bookcycle.communication.application.service;

import com.bookcycle.communication.application.dto.ConversationResponse;
import com.bookcycle.communication.application.dto.CreateConversationRequest;
import com.bookcycle.communication.application.dto.MessageResponse;
import com.bookcycle.communication.application.dto.SendMessageRequest;
import com.bookcycle.communication.domain.model.Conversation;
import com.bookcycle.communication.domain.model.Message;
import com.bookcycle.communication.domain.service.ChatService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ChatApplicationService {
    private final ChatService chatService;

    @Transactional
    public ConversationResponse getOrCreateConversation(CreateConversationRequest request) {
        Conversation conversation = chatService.getOrCreateConversation(
            request.getListingId(),
            request.getBuyerId(),
            request.getSellerId()
        );
        return toConversationResponse(conversation);
    }

    @Transactional
    public MessageResponse sendMessage(UUID conversationId, SendMessageRequest request) {
        Message message = chatService.sendMessage(conversationId, request.getSenderId(), request.getContent());
        return toMessageResponse(message);
    }

    @Transactional(readOnly = true)
    public List<MessageResponse> getMessages(UUID conversationId) {
        return chatService.getMessages(conversationId).stream()
            .map(this::toMessageResponse)
            .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<ConversationResponse> getConversations(UUID userId) {
        return chatService.getConversationsForUser(userId).stream()
            .map(this::toConversationResponse)
            .collect(Collectors.toList());
    }

    private ConversationResponse toConversationResponse(Conversation conversation) {
        return ConversationResponse.builder()
            .id(conversation.getId())
            .listingId(conversation.getListingId())
            .buyerId(conversation.getBuyerId())
            .sellerId(conversation.getSellerId())
            .createdAt(conversation.getCreatedAt())
            .lastMessageAt(conversation.getLastMessageAt())
            .build();
    }

    private MessageResponse toMessageResponse(Message message) {
        return MessageResponse.builder()
            .id(message.getId())
            .senderId(message.getSenderId())
            .content(message.getContent())
            .sentAt(message.getSentAt())
            .build();
    }
}
