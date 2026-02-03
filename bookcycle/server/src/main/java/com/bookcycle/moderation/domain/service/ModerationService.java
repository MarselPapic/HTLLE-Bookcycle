package com.bookcycle.moderation.domain.service;

import com.bookcycle.communication.infrastructure.persistence.MessageRepository;
import com.bookcycle.marketplace.domain.service.ListingService;
import com.bookcycle.moderation.domain.model.ModerationAction;
import com.bookcycle.moderation.domain.model.ModerationActionType;
import com.bookcycle.moderation.domain.model.Report;
import com.bookcycle.moderation.domain.model.ReportReason;
import com.bookcycle.moderation.domain.model.ReportStatus;
import com.bookcycle.moderation.domain.model.ReportTargetType;
import com.bookcycle.moderation.infrastructure.persistence.ModerationActionRepository;
import com.bookcycle.moderation.infrastructure.persistence.ReportRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class ModerationService {
    private final ReportRepository reportRepository;
    private final ModerationActionRepository actionRepository;
    private final ListingService listingService;
    private final MessageRepository messageRepository;

    @Transactional
    public Report createReport(ReportTargetType targetType, UUID targetId, ReportReason reason, String comment, UUID reporterId) {
        validateTargetExists(targetType, targetId);
        Report report = Report.create(targetType, targetId, reason, comment, reporterId);
        return reportRepository.save(report);
    }

    @Transactional(readOnly = true)
    public List<Report> listReports(ReportStatus status) {
        if (status == null) {
            return reportRepository.findAll();
        }
        return reportRepository.findByStatus(status);
    }

    @Transactional
    public Report hideListing(UUID reportId, UUID moderatorId, String note) {
        Report report = getReport(reportId);
        if (report.getTargetType() != ReportTargetType.LISTING) {
            throw new IllegalStateException("Report is not for a listing");
        }
        listingService.hide(report.getTargetId());
        report.markHidden();
        Report saved = reportRepository.save(report);
        actionRepository.save(ModerationAction.create(saved, ModerationActionType.HIDE_LISTING, moderatorId, note));
        return saved;
    }

    @Transactional
    public Report resolveReport(UUID reportId, UUID moderatorId, String note) {
        Report report = getReport(reportId);
        report.resolve();
        Report saved = reportRepository.save(report);
        actionRepository.save(ModerationAction.create(saved, ModerationActionType.RESOLVE_REPORT, moderatorId, note));
        return saved;
    }

    private void validateTargetExists(ReportTargetType targetType, UUID targetId) {
        if (targetType == ReportTargetType.LISTING) {
            listingService.getListing(targetId);
        } else if (targetType == ReportTargetType.MESSAGE) {
            if (!messageRepository.existsById(targetId)) {
                throw new IllegalArgumentException("Message not found: " + targetId);
            }
        }
    }

    private Report getReport(UUID reportId) {
        return reportRepository.findById(reportId)
            .orElseThrow(() -> new IllegalArgumentException("Report not found: " + reportId));
    }
}
