package com.bookcycle.marketplace.domain.service;

import com.bookcycle.marketplace.domain.model.Listing;
import com.bookcycle.marketplace.domain.model.ListingStatus;
import com.bookcycle.marketplace.infrastructure.persistence.ListingRepository;
import com.bookcycle.marketplace.infrastructure.persistence.ListingSpecifications;
import com.bookcycle.marketplace.application.dto.ListingSearchCriteria;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.UUID;

/**
 * User Stories: US-001 Search Listings, US-002 Create & Publish Listing
 */
@Service
@RequiredArgsConstructor
public class ListingService {
    private final ListingRepository repository;

    @Transactional
    public Listing save(Listing listing) {
        return repository.save(listing);
    }

    @Transactional
    public Listing publish(UUID listingId) {
        Listing listing = getListing(listingId);
        listing.publish();
        return repository.save(listing);
    }

    @Transactional
    public Listing close(UUID listingId) {
        Listing listing = getListing(listingId);
        listing.close();
        return repository.save(listing);
    }

    @Transactional
    public Listing reserve(UUID listingId) {
        Listing listing = getListing(listingId);
        listing.reserve();
        return repository.save(listing);
    }

    @Transactional
    public Listing unreserve(UUID listingId) {
        Listing listing = getListing(listingId);
        listing.unreserve();
        return repository.save(listing);
    }

    @Transactional
    public Listing markSold(UUID listingId) {
        Listing listing = getListing(listingId);
        listing.markSold();
        return repository.save(listing);
    }

    @Transactional
    public Listing hide(UUID listingId) {
        Listing listing = getListing(listingId);
        listing.hide();
        return repository.save(listing);
    }

    @Transactional
    public void delete(UUID listingId) {
        Listing listing = getListing(listingId);
        repository.delete(listing);
    }

    @Transactional(readOnly = true)
    public Listing getListing(UUID listingId) {
        return repository.findById(listingId)
            .orElseThrow(() -> new IllegalArgumentException("Listing not found: " + listingId));
    }

    @Transactional(readOnly = true)
    public Page<Listing> search(ListingSearchCriteria criteria, Pageable pageable) {
        return repository.findAll(ListingSpecifications.withCriteria(criteria), pageable);
    }

    @Transactional(readOnly = true)
    public Page<Listing> findBySellerId(UUID sellerId, Pageable pageable) {
        return repository.findBySellerId(sellerId, pageable);
    }

    @Transactional(readOnly = true)
    public long countPublished() {
        return repository.countByStatus(ListingStatus.PUBLISHED);
    }
}
