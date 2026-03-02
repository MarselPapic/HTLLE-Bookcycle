import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/marketplace/domain/listing.dart';
import '../features/marketplace/presentation/listing_providers.dart';
import '../theme/design_tokens.dart';
import '../widgets/widgets.dart';

class CreateListingScreen extends ConsumerStatefulWidget {
  const CreateListingScreen({super.key});

  @override
  ConsumerState<CreateListingScreen> createState() =>
      _CreateListingScreenState();
}

class _CreateListingScreenState extends ConsumerState<CreateListingScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  final TextEditingController _isbnController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _zipController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool _exchangePossible = true;
  ListingCondition _condition = ListingCondition.veryGood;

  @override
  Widget build(BuildContext context) {
    final creationState = ref.watch(listingCreationProvider);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(DesignTokens.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                'Neues Inserat',
                style: TextStyle(fontSize: 34, fontWeight: FontWeight.w800),
              ),
            ),
            const SizedBox(height: DesignTokens.md),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 30),
              decoration: BoxDecoration(
                color: DesignTokens.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: DesignTokens.border, style: BorderStyle.solid),
              ),
              child: Column(
                children: const [
                  Icon(Icons.add_a_photo_rounded,
                      color: DesignTokens.secondary, size: 38),
                  SizedBox(height: 8),
                  Text('Foto hochladen',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                ],
              ),
            ),
            const SizedBox(height: DesignTokens.md),
            InputField(
                label: 'Buchtitel',
                controller: _titleController,
                hint: 'z.B. Harry Potter'),
            const SizedBox(height: DesignTokens.sm),
            InputField(
                label: 'Autor',
                controller: _authorController,
                hint: 'z.B. J.K. Rowling'),
            const SizedBox(height: DesignTokens.sm),
            InputField(label: 'ISBN', controller: _isbnController),
            const SizedBox(height: DesignTokens.sm),
            Row(
              children: [
                Expanded(
                  child: InputField(
                    label: 'Preis (€)',
                    controller: _priceController,
                    hint: '0,00',
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(top: 28),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    height: 54,
                    decoration: BoxDecoration(
                      color: DesignTokens.surfaceSoft,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Tausch moeglich',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        Switch(
                          value: _exchangePossible,
                          onChanged: (value) =>
                              setState(() => _exchangePossible = value),
                          activeThumbColor: DesignTokens.secondary,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: DesignTokens.sm),
            const Text(
              'Zustand',
              style: TextStyle(fontSize: 21, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: DesignTokens.surfaceSoft,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                children: [
                  _conditionButton('Sehr gut', ListingCondition.veryGood),
                  _conditionButton('Gut', ListingCondition.good),
                  _conditionButton('Akzeptabel', ListingCondition.fair),
                ],
              ),
            ),
            const SizedBox(height: DesignTokens.sm),
            InputField(label: 'Stadt', controller: _cityController),
            const SizedBox(height: DesignTokens.sm),
            InputField(label: 'PLZ', controller: _zipController),
            const SizedBox(height: DesignTokens.sm),
            InputField(
              label: 'Beschreibung',
              controller: _descriptionController,
              hint: 'Kurze Beschreibung des Buches...',
            ),
            const SizedBox(height: DesignTokens.md),
            PrimaryButton(
              label: 'Inserat veroeffentlichen',
              isLoading: creationState.isLoading,
              onPressed: () async {
                final listing = Listing(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  title: _titleController.text,
                  author: _authorController.text,
                  isbn: _isbnController.text,
                  condition: _condition,
                  price: double.tryParse(
                          _priceController.text.replaceAll(',', '.')) ??
                      0,
                  currency: _exchangePossible ? 'TAUSCH' : 'EUR',
                  city: _cityController.text,
                  zipCode: _zipController.text,
                  status: ListingStatus.draft,
                  thumbnailUrl: 'https://picsum.photos/202',
                  sellerId: 'user-001',
                );
                await ref
                    .read(listingCreationProvider.notifier)
                    .createListing(listing);
                if (!mounted) {
                  return;
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Listing created')),
                );
              },
            ),
            if (creationState.hasError)
              Padding(
                padding: const EdgeInsets.only(top: DesignTokens.md),
                child: Text(
                  'Error: ${creationState.error}',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _conditionButton(String label, ListingCondition condition) {
    final selected = _condition == condition;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _condition = condition),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? DesignTokens.secondary : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : DesignTokens.textMuted,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
