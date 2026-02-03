import 'package:flutter/material.dart';
import '../screens/search_screen.dart';
import '../screens/create_listing_screen.dart';
import '../screens/chat_screen.dart';
import '../screens/profile_screen.dart';
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
    CreateListingScreen(),
    ChatScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: _titles[_currentIndex],
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.add_box), label: 'Sell'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble), label: 'Chat'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

const List<String> _titles = [
  'Search Listings',
  'Create Listing',
  'Chat',
  'Profile',
];
