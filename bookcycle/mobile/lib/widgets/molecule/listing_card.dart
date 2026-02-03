import 'package:flutter/material.dart';
import '../../theme/design_tokens.dart';
import '../../features/marketplace/domain/listing.dart';
import '../atom/atoms.dart';

class ListingCard extends StatelessWidget {
  final Listing listing;
  final VoidCallback? onTap;

  const ListingCard({
    super.key,
    required this.listing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(DesignTokens.md),
        decoration: BoxDecoration(
          color: DesignTokens.surface,
          borderRadius: BorderRadius.circular(DesignTokens.radius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(DesignTokens.radius),
              child: Image.network(
                listing.thumbnailUrl,
                width: 72,
                height: 72,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: DesignTokens.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(listing.title, style: DesignTokens.body.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: DesignTokens.xs),
                  Text(listing.author, style: DesignTokens.caption),
                  const SizedBox(height: DesignTokens.xs),
                  Text('${listing.city} · ${listing.price.toStringAsFixed(2)} ${listing.currency}',
                      style: DesignTokens.caption),
                ],
              ),
            ),
            StatusBadge(label: listing.status.name.toUpperCase(), color: DesignTokens.primary),
          ],
        ),
      ),
    );
  }
}

