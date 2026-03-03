import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/listing_repository.dart';
import '../domain/listing.dart';
import '../../../shared/providers.dart';

class ListingSearchQuery {
  final String query;
  final ListingSearchFilters filters;

  const ListingSearchQuery({
    required this.query,
    required this.filters,
  });

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ListingSearchQuery &&
            other.query == query &&
            other.filters == filters);
  }

  @override
  int get hashCode => Object.hash(query, filters);
}

final listingRepositoryProvider = Provider<ListingRepository>((ref) {
  return MockListingRepository();
});

final listingSearchProvider = FutureProvider.family<List<Listing>, ListingSearchQuery>((ref, query) async {
  final repository = ref.watch(listingRepositoryProvider);
  return repository.searchListings(query.query, query.filters);
});

final myListingsProvider = FutureProvider<List<Listing>>((ref) async {
  final user = await ref.watch(currentUserProvider.future);
  if (user == null) {
    return const [];
  }
  final repository = ref.watch(listingRepositoryProvider);
  return repository.getListingsBySeller(user.id);
});

final listingCreationProvider = StateNotifierProvider<ListingCreationNotifier, AsyncValue<Listing?>>((ref) {
  final repository = ref.watch(listingRepositoryProvider);
  return ListingCreationNotifier(repository);
});

class ListingCreationNotifier extends StateNotifier<AsyncValue<Listing?>> {
  final ListingRepository repository;

  ListingCreationNotifier(this.repository) : super(const AsyncValue.data(null));

  Future<Listing> createListing(Listing listing) async {
    state = const AsyncValue.loading();
    try {
      final created = await repository.createListing(listing);
      state = AsyncValue.data(created);
      return created;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }
}
