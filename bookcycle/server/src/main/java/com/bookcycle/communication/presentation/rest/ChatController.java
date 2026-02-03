package com.bookcycle.communication.presentation.rest;

import com.bookcycle.communication.application.dto.ConversationResponse;
import com.bookcycle.communication.application.dto.CreateConversationRequest;
import com.bookcycle.communication.application.dto.MessageResponse;
import com.bookcycle.communication.application.dto.SendMessageRequest;
import com.bookcycle.communication.application.service.ChatApplicationService;
import jakarta.validation.Valid;
import java.util.List;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

/**
 * User Story: US-004 Chat
 */
@RestController
@RequestMapping("/api/v1/conversations")
@RequiredArgsConstructor
public class ChatController {
    private final ChatApplicationService chatService;

    @PostMapping
    public ResponseEntity<ConversationResponse> create(@Valid @RequestBody CreateConversationRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(chatService.getOrCreateConversation(request));
    }

    @GetMapping
    public ResponseEntity<List<ConversationResponse>> list(@RequestParam UUID userId) {
        return ResponseEntity.ok(chatService.getConversations(userId));
    }

    @GetMapping("/{id}/messages")
    public ResponseEntity<List<MessageResponse>> messages(@PathVariable UUID id) {
        return ResponseEntity.ok(chatService.getMessages(id));
    }

    @PostMapping("/{id}/messages")
    public ResponseEntity<MessageResponse> sendMessage(
            @PathVariable UUID id,
            @Valid @RequestBody SendMessageRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(chatService.sendMessage(id, request));
    }
}
