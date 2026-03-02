import '../domain/report.dart';

abstract class ReportRepository {
  Future<ReportReceipt> submitReport(ReportRequest request);
}

class MockReportRepository implements ReportRepository {
  @override
  Future<ReportReceipt> submitReport(ReportRequest request) async {
    await Future.delayed(const Duration(milliseconds: 350));
    return ReportReceipt(
      reportId: 'r-${DateTime.now().millisecondsSinceEpoch}',
      submittedAt: DateTime.now(),
    );
  }
}

class ApiReportRepository implements ReportRepository {
  final String baseUrl;

  ApiReportRepository({required this.baseUrl});

  @override
  Future<ReportReceipt> submitReport(ReportRequest request) {
    throw UnimplementedError();
  }
}
