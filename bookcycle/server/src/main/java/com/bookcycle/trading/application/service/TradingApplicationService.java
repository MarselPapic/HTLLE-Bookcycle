package com.bookcycle.trading.application.service;

import com.bookcycle.trading.application.dto.CheckoutRequest;
import com.bookcycle.trading.application.dto.HandoverUpdateRequest;
import com.bookcycle.trading.application.dto.PurchaseResponse;
import com.bookcycle.trading.domain.model.HandoverProtocol;
import com.bookcycle.trading.domain.model.Purchase;
import com.bookcycle.trading.domain.service.CheckoutService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.UUID;

@Service
@RequiredArgsConstructor
public class TradingApplicationService {
    private final CheckoutService checkoutService;

    @Transactional
    public PurchaseResponse checkout(CheckoutRequest request) {
        Purchase purchase = checkoutService.checkout(request.getListingId(), request.getBuyerId());
        return toResponse(purchase);
    }

    @Transactional
    public PurchaseResponse updateHandover(UUID purchaseId, HandoverUpdateRequest request) {
        Purchase purchase = checkoutService.updateHandover(
            purchaseId,
            request.getMeetingTime(),
            request.getMeetingPlace(),
            request.getConditionNotes()
        );
        return toResponse(purchase);
    }

    @Transactional
    public PurchaseResponse confirmBuyer(UUID purchaseId) {
        return toResponse(checkoutService.confirmBuyer(purchaseId));
    }

    @Transactional
    public PurchaseResponse confirmSeller(UUID purchaseId) {
        return toResponse(checkoutService.confirmSeller(purchaseId));
    }

    @Transactional
    public PurchaseResponse cancel(UUID purchaseId) {
        return toResponse(checkoutService.cancel(purchaseId));
    }

    @Transactional(readOnly = true)
    public PurchaseResponse getPurchase(UUID purchaseId) {
        return toResponse(checkoutService.getPurchase(purchaseId));
    }

    private PurchaseResponse toResponse(Purchase purchase) {
        HandoverProtocol protocol = purchase.getHandoverProtocol();
        return PurchaseResponse.builder()
            .id(purchase.getId())
            .listingId(purchase.getListingId())
            .buyerId(purchase.getBuyerId())
            .sellerId(purchase.getSellerId())
            .status(purchase.getStatus())
            .meetingTime(protocol != null ? protocol.getMeetingTime() : null)
            .meetingPlace(protocol != null ? protocol.getMeetingPlace() : null)
            .conditionNotes(protocol != null ? protocol.getConditionNotes() : null)
            .buyerConfirmed(protocol != null && protocol.isBuyerConfirmed())
            .sellerConfirmed(protocol != null && protocol.isSellerConfirmed())
            .createdAt(purchase.getCreatedAt())
            .updatedAt(purchase.getUpdatedAt())
            .build();
    }
}
