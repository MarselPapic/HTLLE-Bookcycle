import '../domain/listing.dart';

class ListingSearchFilters {
  final String? genre;
  final ListingCondition? minCondition;
  final double? minPrice;
  final double? maxPrice;
  final String? city;
  final String? zipCode;

  const ListingSearchFilters({
    this.genre,
    this.minCondition,
    this.minPrice,
    this.maxPrice,
    this.city,
    this.zipCode,
  });
}

abstract class ListingRepository {
  Future<List<Listing>> searchListings(String query, ListingSearchFilters filters);
  Future<Listing> createListing(Listing listing);
  Future<Listing> publishListing(String listingId);
  Future<Listing?> getListing(String listingId);
}

class MockListingRepository implements ListingRepository {
  final List<Listing> _listings = [
    const Listing(
      id: 'l-001',
      title: 'Clean Code',
      author: 'Robert C. Martin',
      isbn: '9780132350884',
      condition: ListingCondition.good,
      price: 20.0,
      currency: 'EUR',
      city: 'Vienna',
      zipCode: '1010',
      status: ListingStatus.published,
      thumbnailUrl: 'https://picsum.photos/200',
      sellerId: 'user-001',
    ),
    const Listing(
      id: 'l-002',
      title: 'Design Patterns',
      author: 'Erich Gamma',
      isbn: '9780201633610',
      condition: ListingCondition.veryGood,
      price: 35.0,
      currency: 'EUR',
      city: 'Linz',
      zipCode: '4020',
      status: ListingStatus.published,
      thumbnailUrl: 'https://picsum.photos/201',
      sellerId: 'user-002',
    ),
  ];

  @override
  Future<List<Listing>> searchListings(String query, ListingSearchFilters filters) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final lower = query.toLowerCase();
    return _listings.where((listing) {
      final matchesQuery = lower.isEmpty ||
          listing.title.toLowerCase().contains(lower) ||
          listing.author.toLowerCase().contains(lower) ||
          listing.isbn.contains(lower);
      final matchesCity = filters.city == null || listing.city.toLowerCase() == filters.city!.toLowerCase();
      final matchesPrice = (filters.minPrice == null || listing.price >= filters.minPrice!) &&
          (filters.maxPrice == null || listing.price <= filters.maxPrice!);
      return matchesQuery && matchesCity && matchesPrice;
    }).toList();
  }

  @override
  Future<Listing> createListing(Listing listing) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _listings.add(listing);
    return listing;
  }

  @override
  Future<Listing?> getListing(String listingId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _listings.firstWhere((l) => l.id == listingId, orElse: () => _listings.first);
  }

  @override
  Future<Listing> publishListing(String listingId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _listings.indexWhere((l) => l.id == listingId);
    if (index == -1) {
      throw Exception('Listing not found');
    }
    final updated = _listings[index].copyWith(status: ListingStatus.published);
    _listings[index] = updated;
    return updated;
  }
}

class ApiListingRepository implements ListingRepository {
  final String baseUrl;

  ApiListingRepository({required this.baseUrl});

  @override
  Future<Listing> createListing(Listing listing) {
    throw UnimplementedError();
  }

  @override
  Future<Listing?> getListing(String listingId) {
    throw UnimplementedError();
  }

  @override
  Future<Listing> publishListing(String listingId) {
    throw UnimplementedError();
  }

  @override
  Future<List<Listing>> searchListings(String query, ListingSearchFilters filters) {
    throw UnimplementedError();
  }
}
