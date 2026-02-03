import 'package:flutter/material.dart';
import '../../features/identity/domain/user.dart';
import '../../theme/design_tokens.dart';

class UserProfileTile extends StatelessWidget {
  final User user;

  const UserProfileTile({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DesignTokens.md),
      decoration: BoxDecoration(
        color: DesignTokens.surface,
        borderRadius: BorderRadius.circular(DesignTokens.radius),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: DesignTokens.primary.withOpacity(0.2),
            backgroundImage: user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
            child: user.avatarUrl == null
                ? Text(user.displayName.substring(0, 1).toUpperCase())
                : null,
          ),
          const SizedBox(width: DesignTokens.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.displayName, style: DesignTokens.body.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: DesignTokens.xs),
                Text(user.location ?? 'No location set', style: DesignTokens.caption),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
