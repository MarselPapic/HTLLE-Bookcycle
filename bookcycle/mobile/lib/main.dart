import 'package:flutter/material.dart';

void main() {
  runApp(const BookcycleApp());
}

class BookcycleApp extends StatelessWidget {
  const BookcycleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bookcycle',
      home: Scaffold(
        appBar: AppBar(title: const Text('Bookcycle')),
        body: const Center(child: Text('Welcome to Bookcycle – Bücher tauschen & verkaufen')),
      ),
    );
  }
}
