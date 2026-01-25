import 'package:flutter/material.dart';
import 'features/identity/data/user_repository.dart';
import 'features/identity/domain/user.dart';
import 'features/identity/presentation/home_page.dart';
import 'features/identity/presentation/login_page.dart';

// Configure mock vs. real API via build flavor
const bool useMockData =
    bool.fromEnvironment('BOOKCYCLE_MOCK_MODE', defaultValue: true);

void main() {
  // Initialize repository based on build flavor
  final userRepository = useMockData
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
      // ignore: avoid_print
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
              appBar: AppBar(title: const Text('Bookcycle')),
              body: const Center(child: CircularProgressIndicator()),
            )
          : _currentUser != null
              ? HomePage(
                  user: _currentUser!,
                  userRepository: widget.userRepository,
                  useMockData: useMockData,
                )
              : LoginPage(userRepository: widget.userRepository),
    );
  }
}
