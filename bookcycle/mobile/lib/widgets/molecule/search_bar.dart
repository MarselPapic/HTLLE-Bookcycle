import 'package:flutter/material.dart';
import '../../theme/design_tokens.dart';
import '../atom/atoms.dart';

class SearchBarField extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSearch;

  const SearchBarField({
    super.key,
    required this.controller,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: DesignTokens.sm),
      decoration: BoxDecoration(
        color: DesignTokens.surface,
        borderRadius: BorderRadius.circular(DesignTokens.radius),
        border: Border.all(color: DesignTokens.border),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: DesignTokens.surfaceSoft,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const AppIcon(
                icon: Icons.search, color: DesignTokens.textMuted),
          ),
          const SizedBox(width: DesignTokens.sm),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Titel / Autor',
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.tune_rounded, color: DesignTokens.textMuted),
            onPressed: onSearch,
          ),
        ],
      ),
    );
  }
}
