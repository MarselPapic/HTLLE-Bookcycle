import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/identity/data/user_repository.dart';
import '../shared/external_navigation.dart';
import '../shared/providers.dart';
import '../theme/design_tokens.dart';
import '../widgets/widgets.dart';

class CreateAccountScreen extends ConsumerStatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  ConsumerState<CreateAccountScreen> createState() =>
      _CreateAccountScreenState();
}

class _CreateAccountScreenState extends ConsumerState<CreateAccountScreen> {
  final TextEditingController _displayNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _displayNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repository = ref.read(userRepositoryProvider);
    final apiRepository = repository is ApiUserRepository ? repository : null;

    return AppScaffold(
      title: 'Create Account',
      body: SingleChildScrollView(
        child: apiRepository != null
            ? _buildApiRegistrationBody(apiRepository)
            : _buildMockRegistrationBody(),
      ),
    );
  }

  Widget _buildApiRegistrationBody(ApiUserRepository repository) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Create your account', style: DesignTokens.headline),
        const SizedBox(height: DesignTokens.sm),
        const Text(
          'Registration is handled by Keycloak. You will be redirected to create your account and verify your email via Mailpit.',
          style: TextStyle(color: DesignTokens.textMuted, fontSize: 18),
        ),
        const SizedBox(height: DesignTokens.lg),
        PrimaryButton(
          label: 'Continue with Keycloak',
          isLoading: _isLoading,
          onPressed: _isLoading ? null : () => _redirectToKeycloak(repository),
        ),
        const SizedBox(height: DesignTokens.sm),
        TextButton(
          onPressed: _isLoading ? null : _openMailpit,
          child: const Text('Open Mailpit (Email Verification)'),
        ),
      ],
    );
  }

  Widget _buildMockRegistrationBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Create your account', style: DesignTokens.headline),
        const SizedBox(height: DesignTokens.sm),
        const Text(
          'Join Bookcycle and start trading textbooks.',
          style: TextStyle(color: DesignTokens.textMuted, fontSize: 18),
        ),
        const SizedBox(height: DesignTokens.xl),
        InputField(
          label: 'Display Name',
          controller: _displayNameController,
          hint: 'Jane Doe',
        ),
        const SizedBox(height: DesignTokens.md),
        InputField(
          label: 'Email',
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          hint: 'jane@example.com',
        ),
        const SizedBox(height: DesignTokens.md),
        InputField(
          label: 'Password',
          controller: _passwordController,
          obscureText: true,
          hint: '********',
        ),
        const SizedBox(height: DesignTokens.xs),
        const Text(
          'Use at least 8 characters.',
          style: TextStyle(color: DesignTokens.textMuted, fontSize: 14),
        ),
        const SizedBox(height: DesignTokens.md),
        InputField(
          label: 'Confirm Password',
          controller: _confirmPasswordController,
          obscureText: true,
          hint: '********',
        ),
        const SizedBox(height: DesignTokens.lg),
        PrimaryButton(
          label: 'Create Account',
          isLoading: _isLoading,
          onPressed: _isLoading ? null : _submit,
        ),
      ],
    );
  }

  Future<void> _redirectToKeycloak(ApiUserRepository repository) async {
    setState(() => _isLoading = true);
    try {
      final redirectUri = '${Uri.base.origin}/';
      final registrationUri =
          repository.buildRegistrationUri(redirectUri: redirectUri);
      final opened = openExternalUrl(registrationUri.toString(), sameTab: true);
      if (!opened) {
        _showMessage(
          'Could not open Keycloak automatically. Open this URL manually: $registrationUri',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _openMailpit() {
    const mailpitUrl = 'http://localhost:8025';
    final opened = openExternalUrl(mailpitUrl);
    if (!opened) {
      _showMessage('Open Mailpit manually: $mailpitUrl');
    }
  }

  Future<void> _submit() async {
    final displayName = _displayNameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (displayName.isEmpty || email.isEmpty || password.isEmpty) {
      _showMessage('Display name, email and password are required.');
      return;
    }
    if (password.length < 8) {
      _showMessage('Password must contain at least 8 characters.');
      return;
    }
    if (password != confirmPassword) {
      _showMessage('Passwords do not match.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ref.read(userRepositoryProvider).register(
            email: email,
            password: password,
            displayName: displayName,
          );
      ref.invalidate(currentUserProvider);
      ref.invalidate(userProfileControllerProvider);

      if (!mounted) {
        return;
      }
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (error) {
      final message = error.toString().replaceFirst('Exception: ', '');
      _showMessage('Registration failed: $message');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}
