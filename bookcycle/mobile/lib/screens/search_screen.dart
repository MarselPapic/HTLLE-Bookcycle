import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/marketplace/data/listing_repository.dart';
import '../features/marketplace/presentation/listing_providers.dart';
import '../theme/design_tokens.dart';
import '../widgets/widgets.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<String> _categories = const [
    'Alle',
    'Romane',
    'Ratgeber',
    'Sci-Fi',
    'Tausch'
  ];
  int _selectedCategory = 0;
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

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(DesignTokens.md),
        child: Column(
          children: [
            Row(
              children: [
                const Text(
                  'BookCycle',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    color: DesignTokens.textPrimary,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.notifications_rounded),
                  color: DesignTokens.textPrimary,
                ),
              ],
            ),
            SearchBarField(
              controller: _controller,
              onSearch: () {
                setState(() => _query = _controller.text.trim());
              },
            ),
            const SizedBox(height: DesignTokens.md),
            SizedBox(
              height: 38,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final selected = index == _selectedCategory;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedCategory = index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: selected
                            ? DesignTokens.primary
                            : DesignTokens.surface,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: selected
                              ? DesignTokens.primary
                              : DesignTokens.border,
                        ),
                      ),
                      child: Text(
                        _categories[index],
                        style: TextStyle(
                          color:
                              selected ? Colors.white : DesignTokens.textMuted,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: DesignTokens.md),
            Expanded(
              child: results.when(
                data: (listings) => listings.isEmpty
                    ? const Center(
                        child: Text(
                          'Keine Inserate gefunden.',
                          style: TextStyle(color: DesignTokens.textMuted),
                        ),
                      )
                    : ListingList(
                        listings: listings,
                        onSelect: (listing) {
                          Navigator.pushNamed(context, '/listing',
                              arguments: listing);
                        },
                      ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(child: Text('Error: $err')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
