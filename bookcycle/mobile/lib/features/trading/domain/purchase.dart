enum PurchaseStatus { pending, handoverInProgress, handedOver, cancelled }

class Purchase {
  final String id;
  final String listingId;
  final String buyerId;
  final String sellerId;
  final PurchaseStatus status;
  final DateTime createdAt;

  const Purchase({
    required this.id,
    required this.listingId,
    required this.buyerId,
    required this.sellerId,
    required this.status,
    required this.createdAt,
  });
}
