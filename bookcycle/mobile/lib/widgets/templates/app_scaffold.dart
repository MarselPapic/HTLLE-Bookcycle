import 'package:flutter/material.dart';
import '../../theme/design_tokens.dart';

class AppScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final Widget? floatingActionButton;
  final BottomNavigationBar? bottomNavigationBar;
  final bool showAppBar;
  final EdgeInsetsGeometry bodyPadding;

  const AppScaffold({
    super.key,
    required this.title,
    required this.body,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.showAppBar = true,
    this.bodyPadding = const EdgeInsets.all(DesignTokens.md),
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignTokens.background,
      appBar: showAppBar ? AppBar(title: Text(title)) : null,
      body: Padding(padding: bodyPadding, child: body),
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}
