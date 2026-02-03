package com.bookcycle.trading.domain.service;

import com.bookcycle.marketplace.domain.model.Listing;
import com.bookcycle.marketplace.domain.model.ListingStatus;
import com.bookcycle.marketplace.domain.service.ListingService;
import com.bookcycle.trading.domain.model.HandoverProtocol;
import com.bookcycle.trading.domain.model.Purchase;
import com.bookcycle.trading.infrastructure.persistence.PurchaseRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.UUID;

/**
 * User Story: US-003 Checkout & Handover
 */
@Service
@RequiredArgsConstructor
public class CheckoutService {
    private final PurchaseRepository purchaseRepository;
    private final ListingService listingService;

    @Transactional
    public Purchase checkout(UUID listingId, UUID buyerId) {
        Listing listing = listingService.getListing(listingId);
        if (listing.getStatus() != ListingStatus.PUBLISHED) {
            throw new IllegalStateException("Listing is not available for checkout");
        }

        listingService.reserve(listingId);
        Purchase purchase = Purchase.create(listingId, buyerId, listing.getSellerId());
        return purchaseRepository.save(purchase);
    }

    @Transactional
    public Purchase updateHandover(UUID purchaseId, LocalDateTime meetingTime, String meetingPlace, String conditionNotes) {
        Purchase purchase = getPurchase(purchaseId);
        purchase.startHandover();
        HandoverProtocol protocol = purchase.getHandoverProtocol();
        protocol.updateDetails(meetingTime, meetingPlace, conditionNotes);
        return purchaseRepository.save(purchase);
    }

    @Transactional
    public Purchase confirmBuyer(UUID purchaseId) {
        Purchase purchase = getPurchase(purchaseId);
        purchase.startHandover();
        purchase.getHandoverProtocol().confirmBuyer();
        finalizeIfComplete(purchase);
        return purchaseRepository.save(purchase);
    }

    @Transactional
    public Purchase confirmSeller(UUID purchaseId) {
        Purchase purchase = getPurchase(purchaseId);
        purchase.startHandover();
        purchase.getHandoverProtocol().confirmSeller();
        finalizeIfComplete(purchase);
        return purchaseRepository.save(purchase);
    }

    @Transactional
    public Purchase cancel(UUID purchaseId) {
        Purchase purchase = getPurchase(purchaseId);
        if (purchase.getStatus() == com.bookcycle.trading.domain.model.PurchaseStatus.HANDED_OVER) {
            throw new IllegalStateException("Cannot cancel a handed-over purchase");
        }
        purchase.cancel();
        listingService.unreserve(purchase.getListingId());
        return purchaseRepository.save(purchase);
    }

    @Transactional(readOnly = true)
    public Purchase getPurchase(UUID purchaseId) {
        return purchaseRepository.findById(purchaseId)
            .orElseThrow(() -> new IllegalArgumentException("Purchase not found: " + purchaseId));
    }

    private void finalizeIfComplete(Purchase purchase) {
        if (purchase.getHandoverProtocol().isFullyConfirmed()) {
            purchase.markHandedOver();
            listingService.markSold(purchase.getListingId());
        }
    }
}
