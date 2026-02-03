import 'package:flutter/material.dart';
import '../../theme/design_tokens.dart';
import '../atom/input_field.dart';
import '../atom/primary_button.dart';

class ProfileForm extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController locationController;
  final VoidCallback onSave;

  const ProfileForm({
    super.key,
    required this.nameController,
    required this.locationController,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InputField(label: 'Display name', controller: nameController),
        const SizedBox(height: DesignTokens.md),
        InputField(label: 'Location', controller: locationController),
        const SizedBox(height: DesignTokens.lg),
        PrimaryButton(label: 'Save profile', onPressed: onSave),
      ],
    );
  }
}

