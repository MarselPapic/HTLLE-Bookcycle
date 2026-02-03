package com.bookcycle.trading.infrastructure.persistence;

import com.bookcycle.trading.domain.model.Purchase;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface PurchaseRepository extends JpaRepository<Purchase, UUID> {
}
