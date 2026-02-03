import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/marketplace/domain/listing.dart';
import '../features/marketplace/presentation/listing_providers.dart';
import '../theme/design_tokens.dart';
import '../widgets/widgets.dart';

/// User Story: US-002 Create & Publish Listing
class CreateListingScreen extends ConsumerStatefulWidget {
  const CreateListingScreen({super.key});

  @override
  ConsumerState<CreateListingScreen> createState() => _CreateListingScreenState();
}

class _CreateListingScreenState extends ConsumerState<CreateListingScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  final TextEditingController _isbnController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _zipController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final creationState = ref.watch(listingCreationProvider);

    return SingleChildScrollView(
      child: Column(
        children: [
          InputField(label: 'Title', controller: _titleController),
          const SizedBox(height: DesignTokens.md),
          InputField(label: 'Author', controller: _authorController),
          const SizedBox(height: DesignTokens.md),
          InputField(label: 'ISBN', controller: _isbnController),
          const SizedBox(height: DesignTokens.md),
          InputField(
            label: 'Price',
            controller: _priceController,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: DesignTokens.md),
          InputField(label: 'City', controller: _cityController),
          const SizedBox(height: DesignTokens.md),
          InputField(label: 'ZIP Code', controller: _zipController),
          const SizedBox(height: DesignTokens.lg),
          PrimaryButton(
            label: 'Create draft listing',
            isLoading: creationState.isLoading,
            onPressed: () async {
              final listing = Listing(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                title: _titleController.text,
                author: _authorController.text,
                isbn: _isbnController.text,
                condition: ListingCondition.good,
                price: double.tryParse(_priceController.text) ?? 0,
                currency: 'EUR',
                city: _cityController.text,
                zipCode: _zipController.text,
                status: ListingStatus.draft,
                thumbnailUrl: 'https://picsum.photos/202',
                sellerId: 'user-001',
              );
              await ref.read(listingCreationProvider.notifier).createListing(listing);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Listing created')),
                );
              }
            },
          ),
          if (creationState.hasError)
            Padding(
              padding: const EdgeInsets.only(top: DesignTokens.md),
              child: Text('Error: ${creationState.error}', style: const TextStyle(color: Colors.red)),
            ),
        ],
      ),
    );
  }
}
