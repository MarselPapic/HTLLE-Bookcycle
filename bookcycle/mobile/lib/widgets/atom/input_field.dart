import 'package:flutter/material.dart';
import '../../theme/design_tokens.dart';

class InputField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final bool obscureText;

  const InputField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: DesignTokens.caption),
        const SizedBox(height: DesignTokens.xs),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: DesignTokens.surface,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: DesignTokens.md,
              vertical: DesignTokens.sm,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DesignTokens.radius),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
