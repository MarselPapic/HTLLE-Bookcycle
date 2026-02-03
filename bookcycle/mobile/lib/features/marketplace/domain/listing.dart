enum ListingStatus { draft, published, reserved, sold, closed, hidden }

enum ListingCondition { newBook, veryGood, good, fair, poor }

class Listing {
  final String id;
  final String title;
  final String author;
  final String isbn;
  final ListingCondition condition;
  final double price;
  final String currency;
  final String city;
  final String zipCode;
  final ListingStatus status;
  final String thumbnailUrl;
  final String sellerId;

  const Listing({
    required this.id,
    required this.title,
    required this.author,
    required this.isbn,
    required this.condition,
    required this.price,
    required this.currency,
    required this.city,
    required this.zipCode,
    required this.status,
    required this.thumbnailUrl,
    required this.sellerId,
  });

  Listing copyWith({
    ListingStatus? status,
  }) {
    return Listing(
      id: id,
      title: title,
      author: author,
      isbn: isbn,
      condition: condition,
      price: price,
      currency: currency,
      city: city,
      zipCode: zipCode,
      status: status ?? this.status,
      thumbnailUrl: thumbnailUrl,
      sellerId: sellerId,
    );
  }
}
