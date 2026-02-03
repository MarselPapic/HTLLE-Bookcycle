import 'package:flutter/material.dart';
import '../../theme/design_tokens.dart';

class DetailTemplate extends StatelessWidget {
  final Widget header;
  final Widget content;

  const DetailTemplate({
    super.key,
    required this.header,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(DesignTokens.md),
          decoration: BoxDecoration(
            color: DesignTokens.surface,
            borderRadius: BorderRadius.circular(DesignTokens.radius),
          ),
          child: header,
        ),
        const SizedBox(height: DesignTokens.md),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(DesignTokens.md),
            decoration: BoxDecoration(
              color: DesignTokens.surface,
              borderRadius: BorderRadius.circular(DesignTokens.radius),
            ),
            child: content,
          ),
        ),
      ],
    );
  }
}
