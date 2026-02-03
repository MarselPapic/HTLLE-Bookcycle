package com.bookcycle.moderation.infrastructure.persistence;

import com.bookcycle.moderation.domain.model.ModerationAction;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ModerationActionRepository extends JpaRepository<ModerationAction, UUID> {
}
