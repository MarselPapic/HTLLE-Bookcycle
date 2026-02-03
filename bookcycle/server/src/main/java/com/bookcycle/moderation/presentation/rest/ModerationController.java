package com.bookcycle.moderation.presentation.rest;

import com.bookcycle.moderation.application.dto.ModerationDecisionRequest;
import com.bookcycle.moderation.application.dto.ReportResponse;
import com.bookcycle.moderation.application.service.ModerationApplicationService;
import com.bookcycle.moderation.domain.model.ReportStatus;
import jakarta.validation.Valid;
import java.util.List;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

/**
 * User Story: US-006 Moderation Dashboard
 */
@RestController
@RequestMapping("/api/v1/moderation")
@RequiredArgsConstructor
public class ModerationController {
    private final ModerationApplicationService moderationService;

    @GetMapping("/reports")
    public ResponseEntity<List<ReportResponse>> list(@RequestParam(required = false) ReportStatus status) {
        return ResponseEntity.ok(moderationService.listReports(status));
    }

    @PostMapping("/reports/{id}/hide")
    public ResponseEntity<ReportResponse> hide(@PathVariable UUID id, @Valid @RequestBody ModerationDecisionRequest request) {
        return ResponseEntity.ok(moderationService.hideListing(id, request));
    }

    @PostMapping("/reports/{id}/resolve")
    public ResponseEntity<ReportResponse> resolve(@PathVariable UUID id, @Valid @RequestBody ModerationDecisionRequest request) {
        return ResponseEntity.ok(moderationService.resolveReport(id, request));
    }
}
