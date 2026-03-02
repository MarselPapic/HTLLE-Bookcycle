import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/marketplace/data/listing_repository.dart';
import '../features/marketplace/domain/listing.dart';
import '../features/marketplace/presentation/listing_providers.dart';
import '../shared/image_picker_bridge.dart';
import '../shared/providers.dart';
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
  bool _isUploadingPhoto = false;
  String? _uploadedPhotoUrl;
  String? _uploadedPhotoName;

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
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: _isUploadingPhoto ? null : _pickAndUploadPhoto,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    children: [
                      _isUploadingPhoto
                          ? const SizedBox(
                              width: 26,
                              height: 26,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.add_a_photo_rounded,
                              color: DesignTokens.secondary, size: 38),
                      const SizedBox(height: 8),
                      Text(
                        _uploadedPhotoName != null
                            ? 'Bild: $_uploadedPhotoName'
                            : 'Foto hochladen',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      if (_uploadedPhotoUrl != null) ...[
                        const SizedBox(height: 8),
                        const Text(
                          'Bild erfolgreich hochgeladen',
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
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
                final repository = ref.read(listingRepositoryProvider);
                final isApiMode = repository is ApiListingRepository;
                final currentUser = ref.read(currentUserProvider).value;
                if (currentUser == null) {
                  _showMessage('Bitte zuerst einloggen.');
                  return;
                }
                if (isApiMode && _uploadedPhotoUrl == null) {
                  _showMessage('Bitte zuerst ein Bild hochladen.');
                  return;
                }

                final enteredPrice = double.tryParse(
                        _priceController.text.replaceAll(',', '.')) ??
                    0;
                final effectivePrice = _exchangePossible ? 0.0 : enteredPrice;
                final effectiveCurrency =
                    _exchangePossible && !isApiMode ? 'TAUSCH' : 'EUR';

                final listing = Listing(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  title: _titleController.text,
                  author: _authorController.text,
                  isbn: _isbnController.text,
                  condition: _condition,
                  price: effectivePrice,
                  currency: effectiveCurrency,
                  city: _cityController.text,
                  zipCode: _zipController.text,
                  status: ListingStatus.published,
                  thumbnailUrl:
                      _uploadedPhotoUrl ?? 'https://picsum.photos/202',
                  sellerId: currentUser.id,
                );
                await ref
                    .read(listingCreationProvider.notifier)
                    .createListing(listing);
                ref.invalidate(listingSearchProvider);
                if (!mounted) {
                  return;
                }
                _showMessage('Listing created');
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

  Future<void> _pickAndUploadPhoto() async {
    final pickedImage = await pickImageForUpload();
    if (pickedImage == null) {
      return;
    }

    final repository = ref.read(listingRepositoryProvider);
    setState(() => _isUploadingPhoto = true);
    try {
      final uploadedUrl = await repository.uploadListingImage(
        bytes: pickedImage.bytes,
        fileName: pickedImage.fileName,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _uploadedPhotoUrl = uploadedUrl;
        _uploadedPhotoName = pickedImage.fileName;
      });
      _showMessage('Bild erfolgreich hochgeladen.');
    } catch (error) {
      _showMessage('Bildupload fehlgeschlagen: $error');
    } finally {
      if (mounted) {
        setState(() => _isUploadingPhoto = false);
      }
    }
  }

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
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
