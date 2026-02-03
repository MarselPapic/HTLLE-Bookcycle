import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/purchase_repository.dart';
import '../domain/purchase.dart';

final purchaseRepositoryProvider = Provider<PurchaseRepository>((ref) {
  return MockPurchaseRepository();
});

final purchaseControllerProvider = StateNotifierProvider<PurchaseController, AsyncValue<Purchase?>>((ref) {
  final repo = ref.watch(purchaseRepositoryProvider);
  return PurchaseController(repo);
});

class PurchaseController extends StateNotifier<AsyncValue<Purchase?>> {
  final PurchaseRepository repository;

  PurchaseController(this.repository) : super(const AsyncValue.data(null));

  Future<void> checkout(String listingId, String buyerId, String sellerId) async {
    state = const AsyncValue.loading();
    try {
      final purchase = await repository.checkout(listingId, buyerId, sellerId);
      state = AsyncValue.data(purchase);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> cancel(String purchaseId) async {
    state = const AsyncValue.loading();
    try {
      final purchase = await repository.cancel(purchaseId);
      state = AsyncValue.data(purchase);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}
