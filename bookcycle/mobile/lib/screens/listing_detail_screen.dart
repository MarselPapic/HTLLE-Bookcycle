import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/marketplace/domain/listing.dart';
import '../features/trading/presentation/purchase_providers.dart';
import '../shared/providers.dart';
import '../theme/design_tokens.dart';
import '../widgets/widgets.dart';

/// User Story: US-003 Checkout & Handover
class ListingDetailScreen extends ConsumerWidget {
  const ListingDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listing = ModalRoute.of(context)!.settings.arguments as Listing;
    final purchaseState = ref.watch(purchaseControllerProvider);
    final user = ref.watch(currentUserProvider).value;

    return AppScaffold(
      title: 'Listing Details',
      body: DetailTemplate(
        header: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(DesignTokens.radius),
              child: Image.network(listing.thumbnailUrl, width: 90, height: 90, fit: BoxFit.cover),
            ),
            const SizedBox(width: DesignTokens.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(listing.title, style: DesignTokens.headline),
                  Text(listing.author, style: DesignTokens.caption),
                  const SizedBox(height: DesignTokens.sm),
                  StatusBadge(label: listing.status.name.toUpperCase()),
                ],
              ),
            )
          ],
        ),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ISBN: ${listing.isbn}', style: DesignTokens.caption),
            const SizedBox(height: DesignTokens.sm),
            Text('Location: ${listing.city} ${listing.zipCode}', style: DesignTokens.caption),
            const SizedBox(height: DesignTokens.sm),
            Text('Price: ${listing.price.toStringAsFixed(2)} ${listing.currency}', style: DesignTokens.body),
            const Spacer(),
            PrimaryButton(
              label: 'Checkout & create handover',
              isLoading: purchaseState.isLoading,
              onPressed: user == null
                  ? null
                  : () {
                      ref.read(purchaseControllerProvider.notifier).checkout(
                            listing.id,
                            user.id,
                            listing.sellerId,
                          );
                      Navigator.pushNamed(context, '/checkout', arguments: listing);
                    },
            ),
          ],
        ),
      ),
    );
  }
}
