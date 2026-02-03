import 'package:flutter/material.dart';
import '../theme/design_tokens.dart';
import '../widgets/widgets.dart';

/// User Story: US-008 Password Reset
class PasswordResetScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();

  PasswordResetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Password Reset',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Enter your email to receive a reset link.', style: DesignTokens.body),
          const SizedBox(height: DesignTokens.md),
          InputField(label: 'Email', controller: emailController),
          const SizedBox(height: DesignTokens.lg),
          PrimaryButton(
            label: 'Send reset link',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Reset link sent.')),
              );
            },
          ),
        ],
      ),
    );
  }
}
