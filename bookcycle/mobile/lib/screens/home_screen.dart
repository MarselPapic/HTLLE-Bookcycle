import 'package:flutter/material.dart';
import '../screens/search_screen.dart';
import '../screens/create_listing_screen.dart';
import '../screens/chat_screen.dart';
import '../screens/profile_screen.dart';
import '../theme/design_tokens.dart';
import '../widgets/templates/app_scaffold.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  static const List<Widget> _screens = [
    SearchScreen(),
    _MyBooksPlaceholder(),
    CreateListingScreen(),
    ChatScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'BookCycle',
      showAppBar: false,
      bodyPadding: EdgeInsets.zero,
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: DesignTokens.surface,
        selectedItemColor: DesignTokens.primary,
        unselectedItemColor: DesignTokens.textMuted,
        showUnselectedLabels: true,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: [
          const BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded), label: 'Home'),
          const BottomNavigationBarItem(
              icon: Icon(Icons.menu_book_rounded), label: 'Meine Buecher'),
          BottomNavigationBarItem(
            icon: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: DesignTokens.primary,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 22),
            ),
            label: 'Inserieren',
          ),
          const BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline_rounded),
              label: 'Nachrichten'),
          const BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded), label: 'Profil'),
        ],
      ),
    );
  }
}

class _MyBooksPlaceholder extends StatelessWidget {
  const _MyBooksPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Meine Buecher kommen als naechster Schritt.',
        style: TextStyle(color: DesignTokens.textMuted),
      ),
    );
  }
}
