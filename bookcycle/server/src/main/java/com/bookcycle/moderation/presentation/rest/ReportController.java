package com.bookcycle.moderation.presentation.rest;

import com.bookcycle.moderation.application.dto.ReportRequest;
import com.bookcycle.moderation.application.dto.ReportResponse;
import com.bookcycle.moderation.application.service.ModerationApplicationService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

/**
 * User Story: US-007 Report Function
 */
@RestController
@RequestMapping("/api/v1/reports")
@RequiredArgsConstructor
public class ReportController {
    private final ModerationApplicationService moderationService;

    @PostMapping
    public ResponseEntity<ReportResponse> create(@Valid @RequestBody ReportRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(moderationService.createReport(request));
    }
}
