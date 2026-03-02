import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bookcycle_mobile/features/moderation/data/report_repository.dart';
import 'package:bookcycle_mobile/features/moderation/domain/report.dart';
import 'package:bookcycle_mobile/features/moderation/presentation/report_providers.dart';

class _FakeReportRepository implements ReportRepository {
  @override
  Future<ReportReceipt> submitReport(ReportRequest request) async {
    return ReportReceipt(
      reportId: 'r-123',
      submittedAt: DateTime.utc(2026, 1, 1),
    );
  }
}

void main() {
  test('report submission stores receipt in provider state', () async {
    final container = ProviderContainer(
      overrides: [
        reportRepositoryProvider.overrideWithValue(_FakeReportRepository()),
      ],
    );
    addTearDown(container.dispose);

    final controller = container.read(reportSubmissionProvider.notifier);
    final receipt = await controller.submitReport(
      const ReportRequest(
        targetId: 'listing-1',
        targetType: 'LISTING',
        reason: ReportReason.spam,
        comment: 'Spam listing',
        reporterId: 'user-001',
      ),
    );

    final state = container.read(reportSubmissionProvider);
    expect(receipt.reportId, 'r-123');
    expect(state.value?.reportId, 'r-123');
  });
}
