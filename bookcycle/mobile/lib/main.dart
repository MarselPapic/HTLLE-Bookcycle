import 'package:flutter/material.dart';
import 'shared/repositories/user_repository.dart';
import 'shared/models/user_model.dart';

// Configure mock vs. real API via build flavor
const bool USE_MOCK_DATA = bool.fromEnvironment('BOOKCYCLE_MOCK_MODE', defaultValue: true);

void main() {
  // Initialize repository based on build flavor
  final userRepository = USE_MOCK_DATA
      ? MockUserRepository()
      : ApiUserRepository(baseUrl: 'http://localhost:8080/api/v1');

  runApp(BookcycleApp(userRepository: userRepository));
}

class BookcycleApp extends StatefulWidget {
  final UserRepository userRepository;

  const BookcycleApp({Key? key, required this.userRepository}) : super(key: key);

  @override
  State<BookcycleApp> createState() => _BookcycleAppState();
}

class _BookcycleAppState extends State<BookcycleApp> {
  late User? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    setState(() => _isLoading = true);
    try {
      final user = await widget.userRepository.getCurrentUser();
      setState(() {
        _currentUser = user;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      print('Error loading user: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bookcycle',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: _isLoading
          ? Scaffold(
              appBar: AppBar(title: Text('Bookcycle')),
              body: Center(child: CircularProgressIndicator()),
            )
          : _currentUser != null
              ? HomePage(user: _currentUser!, userRepository: widget.userRepository)
              : LoginPage(userRepository: widget.userRepository),
    );
  }
}

class HomePage extends StatelessWidget {
  final User user;
  final UserRepository userRepository;

  const HomePage({
    Key? key,
    required this.user,
    required this.userRepository,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bookcycle – ${USE_MOCK_DATA ? '(Mock Mode)' : '(Live)'}'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await userRepository.logout();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Logged out')),
                );
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Welcome, ${user.displayName}!', style: Theme.of(context).textTheme.headlineSmall),
            SizedBox(height: 24),
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Profile Information', style: Theme.of(context).textTheme.titleMedium),
                    SizedBox(height: 16),
                    ListTile(
                      title: Text('Email'),
                      subtitle: Text(user.email),
                    ),
                    ListTile(
                      title: Text('Display Name'),
                      subtitle: Text(user.displayName),
                    ),
                    if (user.location != null)
                      ListTile(
                        title: Text('Location'),
                        subtitle: Text(user.location!),
                      ),
                    ListTile(
                      title: Text('Roles'),
                      subtitle: Text(user.roles.join(', ')),
                    ),
                    ListTile(
                      title: Text('Member Since'),
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

class LoginPage extends StatelessWidget {
  final UserRepository userRepository;

  const LoginPage({Key? key, required this.userRepository}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Bookcycle – Login')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Please Log In', style: Theme.of(context).textTheme.headlineSmall),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Login would redirect to Keycloak')),
                );
              },
              child: Text('Login with Keycloak'),
            ),
          ],
        ),
      ),
    );
  }
}
