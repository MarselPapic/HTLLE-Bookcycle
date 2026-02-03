package com.bookcycle.marketplace.infrastructure.persistence;

import com.bookcycle.marketplace.domain.model.Listing;
import com.bookcycle.marketplace.domain.model.ListingStatus;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;

public interface ListingRepository extends JpaRepository<Listing, UUID>, JpaSpecificationExecutor<Listing> {
    long countByStatus(ListingStatus status);
}
