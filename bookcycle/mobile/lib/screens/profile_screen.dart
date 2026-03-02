import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../shared/providers.dart';
import '../theme/design_tokens.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userProfileControllerProvider);

    return userState.when(
      data: (user) {
        if (user == null) {
          return const Center(child: Text('No user loaded.'));
        }

        final initials = user.displayName.isEmpty
            ? 'U'
            : user.displayName
                .split(' ')
                .where((part) => part.isNotEmpty)
                .take(2)
                .map((part) => part.substring(0, 1).toUpperCase())
                .join();

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(DesignTokens.md),
            child: Column(
              children: [
                Row(
                  children: [
                    const Spacer(),
                    const Text(
                      'Profil',
                      style:
                          TextStyle(fontSize: 36, fontWeight: FontWeight.w800),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.notifications_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: DesignTokens.md),
                CircleAvatar(
                  radius: 58,
                  backgroundColor: DesignTokens.surface,
                  child: CircleAvatar(
                    radius: 54,
                    backgroundImage: user.avatarUrl != null
                        ? NetworkImage(user.avatarUrl!)
                        : null,
                    backgroundColor: DesignTokens.surfaceSoft,
                    child: user.avatarUrl == null
                        ? Text(
                            initials,
                            style: const TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.w800,
                              color: DesignTokens.primaryDark,
                            ),
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: DesignTokens.md),
                Text(
                  user.displayName,
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w800,
                    color: DesignTokens.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.email,
                  style: const TextStyle(
                    fontSize: 20,
                    color: DesignTokens.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: DesignTokens.sm),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD6ECEC),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'ROLE: ${user.roles.isEmpty ? 'USER' : user.roles.first}',
                    style: const TextStyle(
                      color: DesignTokens.primaryDark,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: DesignTokens.xl),
                _optionTile(
                  icon: Icons.person_2_outlined,
                  title: 'Profil bearbeiten',
                  onTap: () {},
                ),
                const SizedBox(height: DesignTokens.md),
                _optionTile(
                  icon: Icons.logout_rounded,
                  title: 'Logout',
                  iconColor: DesignTokens.error,
                  textColor: DesignTokens.error,
                  onTap: () async {
                    await ref.read(userRepositoryProvider).logout();
                    ref.invalidate(currentUserProvider);
                    ref.invalidate(userProfileControllerProvider);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Abgemeldet.')),
                      );
                    }
                  },
                ),
                const Spacer(),
                const Text(
                  'BookCycle v2.4.0',
                  style: TextStyle(color: DesignTokens.textMuted),
                ),
                const SizedBox(height: DesignTokens.md),
              ],
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error: $err')),
    );
  }

  Widget _optionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color iconColor = DesignTokens.primary,
    Color textColor = DesignTokens.textPrimary,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Ink(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: BoxDecoration(
          color: DesignTokens.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: DesignTokens.border),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: DesignTokens.surfaceSoft,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Icon(icon, color: iconColor),
            ),
            const SizedBox(width: 14),
            Text(
              title,
              style: TextStyle(
                  fontSize: 26, fontWeight: FontWeight.w700, color: textColor),
            ),
            const Spacer(),
            const Icon(Icons.chevron_right_rounded,
                color: DesignTokens.textMuted),
          ],
        ),
      ),
    );
  }
}
