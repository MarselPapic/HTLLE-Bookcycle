import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/marketplace/data/listing_repository.dart';
import '../features/marketplace/presentation/listing_providers.dart';
import '../theme/design_tokens.dart';
import '../widgets/widgets.dart';

/// User Story: US-001 Search Listings
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final results = ref.watch(
      listingSearchProvider(
        ListingSearchQuery(
          query: _query,
          filters: const ListingSearchFilters(),
        ),
      ),
    );

    return Column(
      children: [
        SearchBarField(
          controller: _controller,
          onSearch: () {
            setState(() => _query = _controller.text.trim());
          },
        ),
        const SizedBox(height: DesignTokens.md),
        Expanded(
          child: results.when(
            data: (listings) => listings.isEmpty
                ? Center(
                    child: Text('No listings found.', style: DesignTokens.caption),
                  )
                : ListingList(
                    listings: listings,
                    onSelect: (listing) {
                      Navigator.pushNamed(context, '/listing', arguments: listing);
                    },
                  ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(child: Text('Error: $err')),
          ),
        ),
      ],
    );
  }
}
