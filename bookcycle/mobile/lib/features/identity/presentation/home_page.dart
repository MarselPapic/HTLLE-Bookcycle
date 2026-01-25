import 'package:flutter/material.dart';
import '../data/user_repository.dart';
import '../domain/user.dart';

class HomePage extends StatelessWidget {
  final User user;
  final UserRepository userRepository;
  final bool useMockData;

  const HomePage({
    Key? key,
    required this.user,
    required this.userRepository,
    required this.useMockData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bookcycle - ${useMockData ? '(Mock Mode)' : '(Live)'}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await userRepository.logout();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Logged out')),
                );
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Welcome, ${user.displayName}!'
                , style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Profile Information',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 16),
                    ListTile(
                      title: const Text('Email'),
                      subtitle: Text(user.email),
                    ),
                    ListTile(
                      title: const Text('Display Name'),
                      subtitle: Text(user.displayName),
                    ),
                    if (user.location != null)
                      ListTile(
                        title: const Text('Location'),
                        subtitle: Text(user.location!),
                      ),
                    ListTile(
                      title: const Text('Roles'),
                      subtitle: Text(user.roles.join(', ')),
                    ),
                    ListTile(
                      title: const Text('Member Since'),
                      subtitle: Text(user.createdAt.toString().split('.')[0]),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
