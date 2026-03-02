import 'package:flutter/material.dart';
import '../../features/marketplace/domain/listing.dart';
import '../molecule/listing_card.dart';
import '../../theme/design_tokens.dart';

class ListingList extends StatelessWidget {
  final List<Listing> listings;
  final void Function(Listing)? onSelect;

  const ListingList({
    super.key,
    required this.listings,
    this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: listings.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: DesignTokens.md,
        crossAxisSpacing: DesignTokens.md,
        childAspectRatio: 0.66,
      ),
      itemBuilder: (context, index) {
        final listing = listings[index];
        return ListingCard(
          listing: listing,
          onTap: onSelect != null ? () => onSelect!(listing) : null,
        );
      },
    );
  }
}
