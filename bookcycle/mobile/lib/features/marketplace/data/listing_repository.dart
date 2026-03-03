import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

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

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ListingSearchFilters &&
            other.genre == genre &&
            other.minCondition == minCondition &&
            other.minPrice == minPrice &&
            other.maxPrice == maxPrice &&
            other.city == city &&
            other.zipCode == zipCode);
  }

  @override
  int get hashCode => Object.hash(
        genre,
        minCondition,
        minPrice,
        maxPrice,
        city,
        zipCode,
      );
}

abstract class ListingRepository {
  Future<List<Listing>> searchListings(
      String query, ListingSearchFilters filters);
  Future<List<Listing>> getListingsBySeller(String sellerId);
  Future<Listing> createListing(Listing listing);
  Future<Listing> updateListing(Listing listing);
  Future<void> deleteListing({
    required String listingId,
    required String sellerId,
  });
  Future<Listing> publishListing(String listingId);
  Future<Listing?> getListing(String listingId);
  Future<String> uploadListingImage({
    required List<int> bytes,
    required String fileName,
  });
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
    const Listing(
      id: 'l-003',
      title: 'The Great Gatsby',
      author: 'F. Scott Fitzgerald',
      isbn: '9780743273565',
      condition: ListingCondition.good,
      price: 5.0,
      currency: 'EUR',
      city: 'Graz',
      zipCode: '8010',
      status: ListingStatus.published,
      thumbnailUrl: 'https://picsum.photos/seed/gatsby/300/460',
      sellerId: 'user-003',
    ),
    const Listing(
      id: 'l-004',
      title: 'Atomic Habits',
      author: 'James Clear',
      isbn: '9780735211292',
      condition: ListingCondition.veryGood,
      price: 12.0,
      currency: 'EUR',
      city: 'Salzburg',
      zipCode: '5020',
      status: ListingStatus.published,
      thumbnailUrl: 'https://picsum.photos/seed/atomic/300/460',
      sellerId: 'user-001',
    ),
    const Listing(
      id: 'l-005',
      title: 'Dune',
      author: 'Frank Herbert',
      isbn: '9780441172719',
      condition: ListingCondition.good,
      price: 0.0,
      currency: 'TAUSCH',
      city: 'Vienna',
      zipCode: '1100',
      status: ListingStatus.published,
      thumbnailUrl: 'https://picsum.photos/seed/dune/300/460',
      sellerId: 'user-002',
    ),
    const Listing(
      id: 'l-006',
      title: 'Project Hail Mary',
      author: 'Andy Weir',
      isbn: '9780593135204',
      condition: ListingCondition.veryGood,
      price: 15.0,
      currency: 'EUR',
      city: 'Linz',
      zipCode: '4020',
      status: ListingStatus.published,
      thumbnailUrl: 'https://picsum.photos/seed/hailmary/300/460',
      sellerId: 'user-003',
    ),
    const Listing(
      id: 'l-007',
      title: 'Sapiens',
      author: 'Yuval Noah Harari',
      isbn: '9780062316110',
      condition: ListingCondition.good,
      price: 0.0,
      currency: 'TAUSCH',
      city: 'Innsbruck',
      zipCode: '6020',
      status: ListingStatus.published,
      thumbnailUrl: 'https://picsum.photos/seed/sapiens/300/460',
      sellerId: 'user-001',
    ),
    const Listing(
      id: 'l-008',
      title: 'Der Alchimist',
      author: 'Paulo Coelho',
      isbn: '9783257232104',
      condition: ListingCondition.veryGood,
      price: 15.0,
      currency: 'EUR',
      city: 'Graz',
      zipCode: '8010',
      status: ListingStatus.published,
      thumbnailUrl: 'https://picsum.photos/seed/alchemist/300/460',
      sellerId: 'user-002',
    ),
  ];

  @override
  Future<List<Listing>> searchListings(
      String query, ListingSearchFilters filters) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final lower = query.toLowerCase();
    return _listings.where((listing) {
      final matchesQuery = lower.isEmpty ||
          listing.title.toLowerCase().contains(lower) ||
          listing.author.toLowerCase().contains(lower) ||
          listing.isbn.contains(lower);
      final matchesCity = filters.city == null ||
          listing.city.toLowerCase() == filters.city!.toLowerCase();
      final matchesPrice =
          (filters.minPrice == null || listing.price >= filters.minPrice!) &&
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
  Future<List<Listing>> getListingsBySeller(String sellerId) async {
    await Future.delayed(const Duration(milliseconds: 220));
    return _listings
        .where((listing) => listing.sellerId == sellerId)
        .toList(growable: false);
  }

  @override
  Future<Listing?> getListing(String listingId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _listings.firstWhere((l) => l.id == listingId,
        orElse: () => _listings.first);
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

  @override
  Future<Listing> updateListing(Listing listing) async {
    await Future.delayed(const Duration(milliseconds: 220));
    final index = _listings.indexWhere((candidate) => candidate.id == listing.id);
    if (index < 0) {
      throw Exception('Listing not found');
    }
    _listings[index] = listing;
    return listing;
  }

  @override
  Future<void> deleteListing({
    required String listingId,
    required String sellerId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 220));
    final index = _listings.indexWhere(
      (candidate) => candidate.id == listingId && candidate.sellerId == sellerId,
    );
    if (index < 0) {
      throw Exception('Listing not found');
    }
    _listings.removeAt(index);
  }

  @override
  Future<String> uploadListingImage({
    required List<int> bytes,
    required String fileName,
  }) async {
    await Future.delayed(const Duration(milliseconds: 250));
    final seed = DateTime.now().millisecondsSinceEpoch;
    return 'https://picsum.photos/seed/$seed/320/480';
  }
}

class ApiListingRepository implements ListingRepository {
  final String baseUrl;

  ApiListingRepository({required this.baseUrl});

  @override
  Future<List<Listing>> getListingsBySeller(String sellerId) async {
    final uri = Uri.parse('$baseUrl/listings/mine').replace(queryParameters: {
      'sellerId': sellerId,
      'page': '0',
      'size': '100',
    });
    final response =
        await http.get(uri, headers: const {'Accept': 'application/json'});
    if (response.statusCode != 200) {
      throw Exception(_extractErrorMessage(response));
    }

    final body = _decodeAsMap(response.body);
    final content = body['content'];
    if (content is! List) {
      return const [];
    }
    return content.whereType<Map<String, dynamic>>().map(_mapListing).toList();
  }

  @override
  Future<Listing> createListing(Listing listing) async {
    final createUri = Uri.parse('$baseUrl/listings');
    final response = await http.post(
      createUri,
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({
        'title': listing.title,
        'author': listing.author,
        'isbn': listing.isbn,
        'condition': _conditionToApi(listing.condition),
        'priceAmount': listing.price,
        'priceCurrency': _normalizeCurrencyForApi(listing.currency),
        'city': listing.city,
        'zipCode': listing.zipCode,
        'sellerId': listing.sellerId,
        'photoUrls': [listing.thumbnailUrl],
      }),
    );

    if (response.statusCode != 201) {
      throw Exception(_extractErrorMessage(response));
    }

    final body = _decodeAsMap(response.body);
    final created = _mapListing(body);

    // Search endpoint only returns PUBLISHED listings.
    return publishListing(created.id);
  }

  @override
  Future<Listing> updateListing(Listing listing) async {
    final uri = Uri.parse('$baseUrl/listings/${listing.id}');
    final response = await http.put(
      uri,
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({
        'title': listing.title,
        'author': listing.author,
        'isbn': listing.isbn,
        'condition': _conditionToApi(listing.condition),
        'priceAmount': listing.price,
        'priceCurrency': _normalizeCurrencyForApi(listing.currency),
        'city': listing.city,
        'zipCode': listing.zipCode,
        'sellerId': listing.sellerId,
        'photoUrls': [listing.thumbnailUrl],
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(_extractErrorMessage(response));
    }
    return _mapListing(_decodeAsMap(response.body));
  }

  @override
  Future<void> deleteListing({
    required String listingId,
    required String sellerId,
  }) async {
    final uri = Uri.parse('$baseUrl/listings/$listingId').replace(
      queryParameters: {'sellerId': sellerId},
    );
    final response = await http.delete(uri);
    if (response.statusCode != 204) {
      throw Exception(_extractErrorMessage(response));
    }
  }

  @override
  Future<Listing?> getListing(String listingId) async {
    final uri = Uri.parse('$baseUrl/listings/$listingId');
    final response =
        await http.get(uri, headers: const {'Accept': 'application/json'});

    if (response.statusCode == 404) {
      return null;
    }
    if (response.statusCode != 200) {
      throw Exception(_extractErrorMessage(response));
    }

    return _mapListing(_decodeAsMap(response.body));
  }

  @override
  Future<Listing> publishListing(String listingId) async {
    final uri = Uri.parse('$baseUrl/listings/$listingId/publish');
    final response = await http.post(
      uri,
      headers: const {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception(_extractErrorMessage(response));
    }

    return _mapListing(_decodeAsMap(response.body));
  }

  @override
  Future<List<Listing>> searchListings(
      String query, ListingSearchFilters filters) async {
    final queryParameters = <String, String>{
      if (query.trim().isNotEmpty) 'q': query.trim(),
      if (filters.genre != null && filters.genre!.trim().isNotEmpty)
        'genre': filters.genre!.trim(),
      if (filters.minCondition != null)
        'condition': _conditionToApi(filters.minCondition!),
      if (filters.minPrice != null) 'minPrice': filters.minPrice!.toString(),
      if (filters.maxPrice != null) 'maxPrice': filters.maxPrice!.toString(),
      if (filters.city != null && filters.city!.trim().isNotEmpty)
        'city': filters.city!.trim(),
      if (filters.zipCode != null && filters.zipCode!.trim().isNotEmpty)
        'zip': filters.zipCode!.trim(),
      'page': '0',
      'size': '50',
      'sort': 'date',
    };

    final uri = Uri.parse('$baseUrl/listings/search')
        .replace(queryParameters: queryParameters);
    final response =
        await http.get(uri, headers: const {'Accept': 'application/json'});
    if (response.statusCode != 200) {
      throw Exception(_extractErrorMessage(response));
    }

    final body = _decodeAsMap(response.body);
    final content = body['content'];
    if (content is! List) {
      return const [];
    }

    return content.whereType<Map<String, dynamic>>().map(_mapListing).toList();
  }

  @override
  Future<String> uploadListingImage({
    required List<int> bytes,
    required String fileName,
  }) async {
    final uri = Uri.parse('$baseUrl/listings/uploads');
    final contentType = _imageMediaTypeFromFileName(fileName);
    final request = http.MultipartRequest('POST', uri)
      ..files.add(http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: fileName,
        contentType: contentType,
      ));

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    if (response.statusCode != 201) {
      throw Exception(_extractErrorMessage(response));
    }

    final body = _decodeAsMap(response.body);
    final url = body['url']?.toString();
    if (url == null || url.isEmpty) {
      throw Exception('Image upload succeeded but no URL was returned.');
    }
    return url;
  }

  MediaType _imageMediaTypeFromFileName(String fileName) {
    final lowerName = fileName.toLowerCase();
    if (lowerName.endsWith('.png')) {
      return MediaType('image', 'png');
    }
    if (lowerName.endsWith('.gif')) {
      return MediaType('image', 'gif');
    }
    if (lowerName.endsWith('.webp')) {
      return MediaType('image', 'webp');
    }
    if (lowerName.endsWith('.bmp')) {
      return MediaType('image', 'bmp');
    }
    if (lowerName.endsWith('.svg')) {
      return MediaType('image', 'svg+xml');
    }
    if (lowerName.endsWith('.heic')) {
      return MediaType('image', 'heic');
    }
    if (lowerName.endsWith('.heif')) {
      return MediaType('image', 'heif');
    }
    if (lowerName.endsWith('.jpg') || lowerName.endsWith('.jpeg')) {
      return MediaType('image', 'jpeg');
    }
    return MediaType('image', 'jpeg');
  }

  Listing _mapListing(Map<String, dynamic> body) {
    final id = body['id']?.toString() ?? '';
    final photoUrls = body['photoUrls'];
    String thumbnailUrl = body['thumbnailUrl']?.toString() ?? '';
    if (thumbnailUrl.isEmpty && photoUrls is List && photoUrls.isNotEmpty) {
      thumbnailUrl = photoUrls.first.toString();
    }
    if (thumbnailUrl.isEmpty) {
      thumbnailUrl =
          'https://picsum.photos/seed/${id.isEmpty ? 'book' : id}/320/480';
    }

    return Listing(
      id: id,
      title: body['title']?.toString() ?? '',
      author: body['author']?.toString() ?? '',
      isbn: body['isbn']?.toString() ?? '',
      condition: _conditionFromApi(body['condition']?.toString()),
      price: _toDouble(body['priceAmount']),
      currency: body['priceCurrency']?.toString() ?? 'EUR',
      city: body['city']?.toString() ?? '',
      zipCode: body['zipCode']?.toString() ?? '',
      status: _statusFromApi(body['status']?.toString()),
      thumbnailUrl: thumbnailUrl,
      sellerId: body['sellerId']?.toString() ?? '',
    );
  }

  Map<String, dynamic> _decodeAsMap(String body) {
    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    throw Exception('Unexpected API response format.');
  }

  double _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }

  ListingCondition _conditionFromApi(String? value) {
    switch ((value ?? '').toUpperCase()) {
      case 'NEW':
        return ListingCondition.newBook;
      case 'VERY_GOOD':
        return ListingCondition.veryGood;
      case 'GOOD':
        return ListingCondition.good;
      case 'FAIR':
        return ListingCondition.fair;
      case 'POOR':
        return ListingCondition.poor;
      default:
        return ListingCondition.good;
    }
  }

  ListingStatus _statusFromApi(String? value) {
    switch ((value ?? '').toUpperCase()) {
      case 'DRAFT':
        return ListingStatus.draft;
      case 'PUBLISHED':
        return ListingStatus.published;
      case 'RESERVED':
        return ListingStatus.reserved;
      case 'SOLD':
        return ListingStatus.sold;
      case 'CLOSED':
        return ListingStatus.closed;
      case 'HIDDEN':
        return ListingStatus.hidden;
      default:
        return ListingStatus.draft;
    }
  }

  String _conditionToApi(ListingCondition condition) {
    switch (condition) {
      case ListingCondition.newBook:
        return 'NEW';
      case ListingCondition.veryGood:
        return 'VERY_GOOD';
      case ListingCondition.good:
        return 'GOOD';
      case ListingCondition.fair:
        return 'FAIR';
      case ListingCondition.poor:
        return 'POOR';
    }
  }

  String _normalizeCurrencyForApi(String currency) {
    final normalized = currency.trim().toUpperCase();
    if (normalized.length == 3) {
      return normalized;
    }
    return 'EUR';
  }

  String _extractErrorMessage(http.Response response) {
    try {
      final body = jsonDecode(response.body);
      if (body is Map<String, dynamic>) {
        final message = body['message']?.toString();
        final error = body['error']?.toString();
        if (message != null && message.isNotEmpty) {
          return message;
        }
        if (error != null && error.isNotEmpty) {
          return error;
        }
      }
    } catch (_) {
      // Fallback below.
    }
    return 'Request failed with status ${response.statusCode}.';
  }
}
