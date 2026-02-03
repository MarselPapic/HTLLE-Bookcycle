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
      padding: const EdgeInsets.all(DesignTokens.sm),
      decoration: BoxDecoration(
        color: DesignTokens.surface,
        borderRadius: BorderRadius.circular(DesignTokens.radius),
      ),
      child: Row(
        children: [
          const AppIcon(icon: Icons.search),
          const SizedBox(width: DesignTokens.sm),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Search by title, author, ISBN',
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: onSearch,
          ),
        ],
      ),
    );
  }
}
