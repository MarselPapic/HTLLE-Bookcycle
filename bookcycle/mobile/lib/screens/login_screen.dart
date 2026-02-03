import 'package:flutter/material.dart';
import '../theme/design_tokens.dart';
import '../widgets/widgets.dart';

/// User Story: US-005 User Management
class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Login',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InputField(label: 'Email', controller: emailController),
          const SizedBox(height: DesignTokens.md),
          InputField(label: 'Password', controller: passwordController, obscureText: true),
          const SizedBox(height: DesignTokens.lg),
          PrimaryButton(
            label: 'Sign in',
            onPressed: () {},
          ),
          const SizedBox(height: DesignTokens.sm),
          TextButton(
            onPressed: () => Navigator.pushNamed(context, '/password-reset'),
            child: const Text('Forgot password?'),
          ),
        ],
      ),
    );
  }
}
