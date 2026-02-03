import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/marketplace/domain/listing.dart';
import '../features/trading/presentation/purchase_providers.dart';
import '../theme/design_tokens.dart';
import '../widgets/widgets.dart';

/// User Story: US-003 Checkout & Handover
class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final TextEditingController _placeController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final listing = ModalRoute.of(context)!.settings.arguments as Listing;
    final purchaseState = ref.watch(purchaseControllerProvider);

    return AppScaffold(
      title: 'Handover Protocol',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Confirm meeting details for ${listing.title}', style: DesignTokens.body),
          const SizedBox(height: DesignTokens.md),
          InputField(label: 'Meeting place', controller: _placeController),
          const SizedBox(height: DesignTokens.md),
          InputField(label: 'Condition notes', controller: _notesController),
          const SizedBox(height: DesignTokens.lg),
          PrimaryButton(
            label: 'Confirm handover',
            isLoading: purchaseState.isLoading,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Handover confirmed.')),
              );
            },
          ),
          const SizedBox(height: DesignTokens.sm),
          PrimaryButton(
            label: 'Cancel purchase',
            onPressed: () {
              final purchase = purchaseState.value;
              if (purchase != null) {
                ref.read(purchaseControllerProvider.notifier).cancel(purchase.id);
              }
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
