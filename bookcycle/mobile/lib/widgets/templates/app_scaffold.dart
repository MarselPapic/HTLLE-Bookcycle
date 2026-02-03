import 'package:flutter/material.dart';
import '../../theme/design_tokens.dart';

class AppScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final Widget? floatingActionButton;
  final BottomNavigationBar? bottomNavigationBar;

  const AppScaffold({
    super.key,
    required this.title,
    required this.body,
    this.floatingActionButton,
    this.bottomNavigationBar,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignTokens.background,
      appBar: AppBar(
        title: Text(title),
        backgroundColor: DesignTokens.background,
        foregroundColor: DesignTokens.textPrimary,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(DesignTokens.md),
        child: body,
      ),
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}
