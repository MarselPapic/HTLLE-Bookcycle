import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../shared/providers.dart';
import '../theme/design_tokens.dart';
import '../widgets/widgets.dart';

/// User Story: US-005 User Management
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userProfileControllerProvider);

    return userState.when(
      data: (user) {
        if (user == null) {
          return const Center(child: Text('No user loaded.'));
        }
        _nameController.text = user.displayName;
        _locationController.text = user.location ?? '';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            UserProfileTile(user: user),
            const SizedBox(height: DesignTokens.lg),
            ProfileForm(
              nameController: _nameController,
              locationController: _locationController,
              onSave: () {
                final updated = user.copyWith(
                  displayName: _nameController.text,
                  location: _locationController.text,
                );
                ref.read(userProfileControllerProvider.notifier).updateProfile(updated);
              },
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error: $err')),
    );
  }
}
