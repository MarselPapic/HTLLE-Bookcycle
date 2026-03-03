import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/marketplace/domain/listing.dart';
import '../features/marketplace/presentation/listing_providers.dart';
import '../theme/design_tokens.dart';
import '../widgets/widgets.dart';

class MyListingsScreen extends ConsumerWidget {
  const MyListingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listingsAsync = ref.watch(myListingsProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(DesignTokens.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Meine Inserate',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => ref.invalidate(myListingsProvider),
                  icon: const Icon(Icons.refresh_rounded),
                ),
              ],
            ),
            const SizedBox(height: DesignTokens.sm),
            Expanded(
              child: listingsAsync.when(
                data: (listings) {
                  if (listings.isEmpty) {
                    return const Center(
                      child: Text(
                        'Du hast noch keine Inserate erstellt.',
                        style: TextStyle(color: DesignTokens.textMuted),
                      ),
                    );
                  }
                  return ListView.separated(
                    itemCount: listings.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: DesignTokens.sm),
                    itemBuilder: (context, index) {
                      final listing = listings[index];
                      return _MyListingTile(
                        listing: listing,
                        onEdit: () async {
                          final changed = await Navigator.of(context).push<bool>(
                            MaterialPageRoute(
                              builder: (_) => EditListingScreen(listing: listing),
                            ),
                          );
                          if (changed == true) {
                            ref.invalidate(myListingsProvider);
                            ref.invalidate(listingSearchProvider);
                          }
                        },
                        onDelete: () async {
                          final confirmed = await showDialog<bool>(
                                context: context,
                                builder: (dialogContext) => AlertDialog(
                                  title: const Text('Inserat loeschen?'),
                                  content: Text(
                                    'Moechtest du "${listing.title}" wirklich loeschen?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(dialogContext).pop(false),
                                      child: const Text('Abbrechen'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(dialogContext).pop(true),
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.red,
                                      ),
                                      child: const Text('Loeschen'),
                                    ),
                                  ],
                                ),
                              ) ??
                              false;
                          if (!confirmed) {
                            return;
                          }

                          try {
                            await ref.read(listingRepositoryProvider).deleteListing(
                                  listingId: listing.id,
                                  sellerId: listing.sellerId,
                                );
                            ref.invalidate(myListingsProvider);
                            ref.invalidate(listingSearchProvider);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Inserat wurde geloescht.'),
                                ),
                              );
                            }
                          } catch (error) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Loeschen fehlgeschlagen: ${error.toString().replaceFirst('Exception: ', '')}',
                                  ),
                                ),
                              );
                            }
                          }
                        },
                      );
                    },
                  );
                },
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(
                  child: Text(
                    'Fehler beim Laden: $error',
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MyListingTile extends StatelessWidget {
  final Listing listing;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _MyListingTile({
    required this.listing,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: DesignTokens.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: DesignTokens.border),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              listing.thumbnailUrl,
              width: 76,
              height: 104,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 76,
                height: 104,
                color: DesignTokens.surfaceSoft,
                alignment: Alignment.center,
                child: const Icon(Icons.menu_book_rounded),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  listing.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  listing.author,
                  style: const TextStyle(color: DesignTokens.textMuted),
                ),
                const SizedBox(height: 6),
                Text(
                  '${listing.price.toStringAsFixed(2)} ${listing.currency}',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Text(
                  'Status: ${_statusLabel(listing.status)}',
                  style: const TextStyle(color: DesignTokens.textMuted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            children: [
              OutlinedButton(
                onPressed: onEdit,
                child: const Text('Bearbeiten'),
              ),
              const SizedBox(height: 6),
              OutlinedButton(
                onPressed: onDelete,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                ),
                child: const Text('Loeschen'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _statusLabel(ListingStatus status) {
    switch (status) {
      case ListingStatus.draft:
        return 'Entwurf';
      case ListingStatus.published:
        return 'Veroeffentlicht';
      case ListingStatus.reserved:
        return 'Reserviert';
      case ListingStatus.sold:
        return 'Verkauft';
      case ListingStatus.closed:
        return 'Geschlossen';
      case ListingStatus.hidden:
        return 'Versteckt';
    }
  }
}

class EditListingScreen extends ConsumerStatefulWidget {
  final Listing listing;

  const EditListingScreen({super.key, required this.listing});

  @override
  ConsumerState<EditListingScreen> createState() => _EditListingScreenState();
}

class _EditListingScreenState extends ConsumerState<EditListingScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _authorController;
  late final TextEditingController _isbnController;
  late final TextEditingController _priceController;
  late final TextEditingController _cityController;
  late final TextEditingController _zipController;
  ListingCondition _condition = ListingCondition.good;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.listing.title);
    _authorController = TextEditingController(text: widget.listing.author);
    _isbnController = TextEditingController(text: widget.listing.isbn);
    _priceController = TextEditingController(
      text: widget.listing.price.toStringAsFixed(2),
    );
    _cityController = TextEditingController(text: widget.listing.city);
    _zipController = TextEditingController(text: widget.listing.zipCode);
    _condition = widget.listing.condition;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _isbnController.dispose();
    _priceController.dispose();
    _cityController.dispose();
    _zipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Inserat bearbeiten',
      body: SingleChildScrollView(
        child: Column(
          children: [
            InputField(label: 'Titel', controller: _titleController),
            const SizedBox(height: DesignTokens.sm),
            InputField(label: 'Autor', controller: _authorController),
            const SizedBox(height: DesignTokens.sm),
            InputField(label: 'ISBN', controller: _isbnController),
            const SizedBox(height: DesignTokens.sm),
            InputField(
              label: 'Preis',
              controller: _priceController,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: DesignTokens.sm),
            InputField(label: 'Stadt', controller: _cityController),
            const SizedBox(height: DesignTokens.sm),
            InputField(label: 'PLZ', controller: _zipController),
            const SizedBox(height: DesignTokens.sm),
            DropdownButtonFormField<ListingCondition>(
              initialValue: _condition,
              decoration: const InputDecoration(
                labelText: 'Zustand',
                filled: true,
                fillColor: DesignTokens.surfaceSoft,
              ),
              items: ListingCondition.values
                  .map(
                    (condition) => DropdownMenuItem(
                      value: condition,
                      child: Text(_conditionLabel(condition)),
                    ),
                  )
                  .toList(growable: false),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _condition = value);
                }
              },
            ),
            const SizedBox(height: DesignTokens.md),
            PrimaryButton(
              label: 'Aenderungen speichern',
              isLoading: _isSaving,
              onPressed: _isSaving ? null : _save,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    final author = _authorController.text.trim();
    final isbn = _isbnController.text.trim();
    final city = _cityController.text.trim();
    final zip = _zipController.text.trim();
    final price = double.tryParse(_priceController.text.replaceAll(',', '.'));

    if (title.isEmpty ||
        author.isEmpty ||
        isbn.isEmpty ||
        city.isEmpty ||
        zip.isEmpty) {
      _showMessage('Bitte alle Pflichtfelder ausfuellen.');
      return;
    }
    if (price == null || price < 0) {
      _showMessage('Bitte einen gueltigen Preis eingeben.');
      return;
    }

    final updated = Listing(
      id: widget.listing.id,
      title: title,
      author: author,
      isbn: isbn,
      condition: _condition,
      price: price,
      currency: widget.listing.currency,
      city: city,
      zipCode: zip,
      status: widget.listing.status,
      thumbnailUrl: widget.listing.thumbnailUrl,
      sellerId: widget.listing.sellerId,
    );

    setState(() => _isSaving = true);
    try {
      await ref.read(listingRepositoryProvider).updateListing(updated);
      ref.invalidate(myListingsProvider);
      ref.invalidate(listingSearchProvider);
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop(true);
    } catch (error) {
      _showMessage(
        'Speichern fehlgeschlagen: ${error.toString().replaceFirst('Exception: ', '')}',
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
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
