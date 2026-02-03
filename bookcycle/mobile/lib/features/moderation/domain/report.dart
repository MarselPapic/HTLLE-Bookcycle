enum ReportReason { spam, inappropriate, fraud }

class ReportRequest {
  final String targetId;
  final String targetType;
  final ReportReason reason;
  final String comment;

  const ReportRequest({
    required this.targetId,
    required this.targetType,
    required this.reason,
    required this.comment,
  });
}
