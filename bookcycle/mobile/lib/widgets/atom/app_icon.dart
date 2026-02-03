import 'package:flutter/material.dart';
import '../../theme/design_tokens.dart';

class AppIcon extends StatelessWidget {
  final IconData icon;
  final double size;
  final Color? color;

  const AppIcon({
    super.key,
    required this.icon,
    this.size = 20,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Icon(icon, size: size, color: color ?? DesignTokens.textPrimary);
  }
}
