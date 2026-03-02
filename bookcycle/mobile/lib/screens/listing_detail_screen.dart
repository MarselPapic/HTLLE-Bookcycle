import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/marketplace/domain/listing.dart';
import '../features/trading/presentation/purchase_providers.dart';
import '../shared/providers.dart';
import '../theme/design_tokens.dart';
import '../widgets/widgets.dart';

class ListingDetailScreen extends ConsumerWidget {
  const ListingDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listing = ModalRoute.of(context)!.settings.arguments as Listing;
    final purchaseState = ref.watch(purchaseControllerProvider);
    final user = ref.watch(currentUserProvider).value;

    return Scaffold(
      backgroundColor: DesignTokens.background,
      body: Column(
        children: [
          Expanded(
            flex: 5,
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFF021427), Color(0xFF04213A)],
                    ),
                  ),
                  child: Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Image.network(
                        listing.thumbnailUrl,
                        width: 170,
                        height: 250,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      children: [
                        _iconButton(Icons.arrow_back_rounded,
                            () => Navigator.pop(context)),
                        const Spacer(),
                        _iconButton(Icons.share_outlined, () {}),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 6,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
              decoration: const BoxDecoration(
                color: DesignTokens.background,
                borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      listing.title,
                      style: const TextStyle(
                          fontSize: 42, fontWeight: FontWeight.w800),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Center(
                    child: Text(
                      listing.author,
                      style: const TextStyle(
                          fontSize: 23, color: DesignTokens.textMuted),
                    ),
                  ),
                  const SizedBox(height: DesignTokens.md),
                  Row(
                    children: [
                      _infoCard(
                          'Preis', '${listing.price.toStringAsFixed(0)} €'),
                      _infoCard('Zustand', _conditionLabel(listing.condition)),
                      _infoCard('Genre', 'Roman'),
                    ],
                  ),
                  const SizedBox(height: DesignTokens.md),
                  const Text(
                    'Beschreibung',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${listing.title} von ${listing.author}. Standort: ${listing.city}, ${listing.zipCode}.',
                    style: const TextStyle(
                        fontSize: 18, color: DesignTokens.textMuted),
                  ),
                  const Spacer(),
                  PrimaryButton(
                    label: 'Anfragen',
                    isLoading: purchaseState.isLoading,
                    onPressed: user == null
                        ? null
                        : () {
                            ref
                                .read(purchaseControllerProvider.notifier)
                                .checkout(
                                  listing.id,
                                  user.id,
                                  listing.sellerId,
                                );
                            Navigator.pushNamed(context, '/checkout',
                                arguments: listing);
                          },
                  ),
                  const SizedBox(height: DesignTokens.sm),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          '/report',
                          arguments: {
                            'targetId': listing.id,
                            'targetType': 'LISTING',
                          },
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: DesignTokens.border),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Inserat melden'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _iconButton(IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.black54,
      shape: const CircleBorder(),
      child: IconButton(
        onPressed: onTap,
        icon: Icon(icon, color: Colors.white),
      ),
    );
  }

  Widget _infoCard(String title, String value) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: DesignTokens.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: DesignTokens.border),
        ),
        child: Column(
          children: [
            Text(
              title.toUpperCase(),
              style: const TextStyle(
                fontSize: 11,
                color: DesignTokens.textMuted,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              value,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _conditionLabel(ListingCondition condition) {
    switch (condition) {
      case ListingCondition.newBook:
        return 'Neu';
      case ListingCondition.veryGood:
        return 'Sehr gut';
      case ListingCondition.good:
        return 'Gut';
      case ListingCondition.fair:
        return 'Akzeptabel';
      case ListingCondition.poor:
        return 'Schlecht';
    }
  }
}
