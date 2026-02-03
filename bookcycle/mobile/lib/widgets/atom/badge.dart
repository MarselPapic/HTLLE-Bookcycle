import 'package:flutter/material.dart';
import '../../theme/design_tokens.dart';

class StatusBadge extends StatelessWidget {
  final String label;
  final Color? color;

  const StatusBadge({
    super.key,
    required this.label,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final badgeColor = color ?? DesignTokens.secondary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: DesignTokens.caption.copyWith(color: badgeColor),
      ),
    );
  }
}
