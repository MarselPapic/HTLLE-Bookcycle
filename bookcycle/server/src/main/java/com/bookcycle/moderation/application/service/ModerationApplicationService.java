package com.bookcycle.moderation.application.service;

import com.bookcycle.moderation.application.dto.ModerationDecisionRequest;
import com.bookcycle.moderation.application.dto.ReportRequest;
import com.bookcycle.moderation.application.dto.ReportResponse;
import com.bookcycle.moderation.domain.model.Report;
import com.bookcycle.moderation.domain.model.ReportStatus;
import com.bookcycle.moderation.domain.service.ModerationService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ModerationApplicationService {
    private final ModerationService moderationService;

    @Transactional
    public ReportResponse createReport(ReportRequest request) {
        Report report = moderationService.createReport(
            request.getTargetType(),
            request.getTargetId(),
            request.getReason(),
            request.getComment(),
            request.getReporterId()
        );
        return toResponse(report);
    }

    @Transactional(readOnly = true)
    public List<ReportResponse> listReports(ReportStatus status) {
        return moderationService.listReports(status).stream()
            .map(this::toResponse)
            .collect(Collectors.toList());
    }

    @Transactional
    public ReportResponse hideListing(UUID reportId, ModerationDecisionRequest request) {
        Report report = moderationService.hideListing(reportId, request.getModeratorId(), request.getNote());
        return toResponse(report);
    }

    @Transactional
    public ReportResponse resolveReport(UUID reportId, ModerationDecisionRequest request) {
        Report report = moderationService.resolveReport(reportId, request.getModeratorId(), request.getNote());
        return toResponse(report);
    }

    private ReportResponse toResponse(Report report) {
        return ReportResponse.builder()
            .id(report.getId())
            .targetType(report.getTargetType())
            .targetId(report.getTargetId())
            .reason(report.getReason())
            .comment(report.getComment())
            .reporterId(report.getReporterId())
            .status(report.getStatus())
            .createdAt(report.getCreatedAt())
            .updatedAt(report.getUpdatedAt())
            .build();
    }
}
