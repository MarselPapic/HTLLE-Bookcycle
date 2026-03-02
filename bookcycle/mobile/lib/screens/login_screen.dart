import 'package:flutter/material.dart';

import '../theme/design_tokens.dart';
import '../widgets/widgets.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignTokens.backgroundWarm,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(DesignTokens.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white70,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Icon(Icons.arrow_back,
                    color: DesignTokens.textPrimary),
              ),
              const SizedBox(height: DesignTokens.lg),
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: const Color(0xFFDDE8DF),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.menu_book_rounded,
                    color: DesignTokens.primary),
              ),
              const SizedBox(height: DesignTokens.lg),
              const Text('Welcome\nback', style: DesignTokens.headline),
              const SizedBox(height: DesignTokens.sm),
              const Text(
                'Enter your details to access your personal library.',
                style: TextStyle(color: DesignTokens.textMuted, fontSize: 18),
              ),
              const SizedBox(height: DesignTokens.xl),
              InputField(
                label: 'Email',
                controller: emailController,
                hint: 'hello@example.com',
              ),
              const SizedBox(height: DesignTokens.md),
              InputField(
                label: 'Password',
                controller: passwordController,
                obscureText: true,
                hint: '********',
              ),
              const SizedBox(height: DesignTokens.lg),
              PrimaryButton(label: 'Log In', onPressed: () {}),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('New to BookCycle? ',
                      style: TextStyle(color: DesignTokens.textMuted)),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      'Create account',
                      style: TextStyle(
                        color: DesignTokens.primaryDark,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: DesignTokens.md),
            ],
          ),
        ),
      ),
    );
  }
}
