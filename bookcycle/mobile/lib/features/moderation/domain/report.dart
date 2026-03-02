enum ReportReason { spam, inappropriate, fraud }

class ReportRequest {
  final String targetId;
  final String targetType;
  final ReportReason reason;
  final String comment;
  final String reporterId;

  const ReportRequest({
    required this.targetId,
    required this.targetType,
    required this.reason,
    required this.comment,
    required this.reporterId,
  });
}

class ReportReceipt {
  final String reportId;
  final DateTime submittedAt;

  const ReportReceipt({
    required this.reportId,
    required this.submittedAt,
  });
}
