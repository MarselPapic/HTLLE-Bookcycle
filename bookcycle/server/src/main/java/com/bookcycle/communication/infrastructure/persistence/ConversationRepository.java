package com.bookcycle.communication.infrastructure.persistence;

import com.bookcycle.communication.domain.model.Conversation;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ConversationRepository extends JpaRepository<Conversation, UUID> {
    Optional<Conversation> findByListingIdAndBuyerIdAndSellerId(UUID listingId, UUID buyerId, UUID sellerId);
    List<Conversation> findByBuyerIdOrSellerId(UUID buyerId, UUID sellerId);
}
