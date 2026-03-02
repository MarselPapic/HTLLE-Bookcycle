import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/report_repository.dart';
import '../domain/report.dart';

final reportRepositoryProvider = Provider<ReportRepository>((ref) {
  return MockReportRepository();
});

final reportSubmissionProvider = StateNotifierProvider<
    ReportSubmissionController, AsyncValue<ReportReceipt?>>((ref) {
  final repository = ref.watch(reportRepositoryProvider);
  return ReportSubmissionController(repository);
});

class ReportSubmissionController
    extends StateNotifier<AsyncValue<ReportReceipt?>> {
  final ReportRepository repository;

  ReportSubmissionController(this.repository)
      : super(const AsyncValue.data(null));

  Future<ReportReceipt> submitReport(ReportRequest request) async {
    state = const AsyncValue.loading();
    try {
      final receipt = await repository.submitReport(request);
      state = AsyncValue.data(receipt);
      return receipt;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }
}
