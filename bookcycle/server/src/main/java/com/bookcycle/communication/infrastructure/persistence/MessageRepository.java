package com.bookcycle.communication.infrastructure.persistence;

import com.bookcycle.communication.domain.model.Message;
import java.util.List;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface MessageRepository extends JpaRepository<Message, UUID> {
    List<Message> findByConversationIdOrderBySentAtAsc(UUID conversationId);
}
