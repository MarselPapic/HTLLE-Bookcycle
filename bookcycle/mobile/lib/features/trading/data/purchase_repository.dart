import '../domain/purchase.dart';

abstract class PurchaseRepository {
  Future<Purchase> checkout(String listingId, String buyerId, String sellerId);
  Future<Purchase> confirm(String purchaseId, String role);
  Future<Purchase> cancel(String purchaseId);
}

class MockPurchaseRepository implements PurchaseRepository {
  Purchase? _purchase;

  @override
  Future<Purchase> checkout(String listingId, String buyerId, String sellerId) async {
    _purchase = Purchase(
      id: 'p-001',
      listingId: listingId,
      buyerId: buyerId,
      sellerId: sellerId,
      status: PurchaseStatus.pending,
      createdAt: DateTime.now(),
    );
    return _purchase!;
  }

  @override
  Future<Purchase> confirm(String purchaseId, String role) async {
    if (_purchase == null) {
      throw Exception('Purchase not found');
    }
    _purchase = Purchase(
      id: _purchase!.id,
      listingId: _purchase!.listingId,
      buyerId: _purchase!.buyerId,
      sellerId: _purchase!.sellerId,
      status: PurchaseStatus.handedOver,
      createdAt: _purchase!.createdAt,
    );
    return _purchase!;
  }

  @override
  Future<Purchase> cancel(String purchaseId) async {
    if (_purchase == null) {
      throw Exception('Purchase not found');
    }
    _purchase = Purchase(
      id: _purchase!.id,
      listingId: _purchase!.listingId,
      buyerId: _purchase!.buyerId,
      sellerId: _purchase!.sellerId,
      status: PurchaseStatus.cancelled,
      createdAt: _purchase!.createdAt,
    );
    return _purchase!;
  }
}

class ApiPurchaseRepository implements PurchaseRepository {
  final String baseUrl;

  ApiPurchaseRepository({required this.baseUrl});

  @override
  Future<Purchase> checkout(String listingId, String buyerId, String sellerId) {
    throw UnimplementedError();
  }

  @override
  Future<Purchase> confirm(String purchaseId, String role) {
    throw UnimplementedError();
  }

  @override
  Future<Purchase> cancel(String purchaseId) {
    throw UnimplementedError();
  }
}
