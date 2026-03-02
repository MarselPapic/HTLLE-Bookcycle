import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../shared/providers.dart';
import '../theme/design_tokens.dart';
import '../widgets/widgets.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _emailController =
      TextEditingController(text: 'testuser@bookcycle.local');
  final TextEditingController _passwordController =
      TextEditingController(text: 'TestUser123!');

  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignTokens.backgroundWarm,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(DesignTokens.lg),
          child: ListView(
            children: [
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
                'Sign in with your Bookcycle account.',
                style: TextStyle(color: DesignTokens.textMuted, fontSize: 18),
              ),
              const SizedBox(height: DesignTokens.xl),
              InputField(
                label: 'Email',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                hint: 'your@email.com',
              ),
              const SizedBox(height: DesignTokens.md),
              InputField(
                label: 'Password',
                controller: _passwordController,
                obscureText: true,
                hint: '********',
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () =>
                      Navigator.of(context).pushNamed('/password-reset'),
                  child: const Text('Forgot password?'),
                ),
              ),
              const SizedBox(height: DesignTokens.sm),
              PrimaryButton(
                label: 'Log In',
                isLoading: _isLoading,
                onPressed: _isLoading ? null : _submitLogin,
              ),
              const SizedBox(height: DesignTokens.xl),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('New to Bookcycle? ',
                      style: TextStyle(color: DesignTokens.textMuted)),
                  TextButton(
                    onPressed: () =>
                        Navigator.of(context).pushNamed('/create-account'),
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

  Future<void> _submitLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email and password are required.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ref
          .read(userRepositoryProvider)
          .login(email: email, password: password);
      ref.invalidate(currentUserProvider);
      ref.invalidate(userProfileControllerProvider);
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
