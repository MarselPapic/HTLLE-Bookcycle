package com.bookcycle.trading.presentation.rest;

import com.bookcycle.trading.application.dto.CheckoutRequest;
import com.bookcycle.trading.application.dto.HandoverUpdateRequest;
import com.bookcycle.trading.application.dto.PurchaseResponse;
import com.bookcycle.trading.application.service.TradingApplicationService;
import jakarta.validation.Valid;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

/**
 * User Story: US-003 Checkout & Handover
 */
@RestController
@RequestMapping("/api/v1/purchases")
@RequiredArgsConstructor
public class PurchaseController {
    private final TradingApplicationService tradingService;

    @PostMapping("/checkout")
    public ResponseEntity<PurchaseResponse> checkout(@Valid @RequestBody CheckoutRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(tradingService.checkout(request));
    }

    @GetMapping("/{id}")
    public ResponseEntity<PurchaseResponse> get(@PathVariable UUID id) {
        return ResponseEntity.ok(tradingService.getPurchase(id));
    }

    @PutMapping("/{id}/handover")
    public ResponseEntity<PurchaseResponse> updateHandover(
            @PathVariable UUID id,
            @RequestBody HandoverUpdateRequest request) {
        return ResponseEntity.ok(tradingService.updateHandover(id, request));
    }

    @PostMapping("/{id}/confirm-buyer")
    public ResponseEntity<PurchaseResponse> confirmBuyer(@PathVariable UUID id) {
        return ResponseEntity.ok(tradingService.confirmBuyer(id));
    }

    @PostMapping("/{id}/confirm-seller")
    public ResponseEntity<PurchaseResponse> confirmSeller(@PathVariable UUID id) {
        return ResponseEntity.ok(tradingService.confirmSeller(id));
    }

    @PostMapping("/{id}/cancel")
    public ResponseEntity<PurchaseResponse> cancel(@PathVariable UUID id) {
        return ResponseEntity.ok(tradingService.cancel(id));
    }
}
