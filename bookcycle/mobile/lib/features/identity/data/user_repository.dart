// lib/features/identity/data/user_repository.dart

import 'dart:convert';

import 'package:http/http.dart' as http;

import '../domain/user.dart';

/// Repository Pattern for User Management
abstract class UserRepository {
  Future<User?> getCurrentUser();
  Future<User> login({required String email, required String password});
  Future<User> register({
    required String email,
    required String password,
    required String displayName,
  });
  Future<void> requestPasswordReset({required String email});
  Future<void> loginAsDemoUser({String? userId});
  Future<void> updateProfile(User user);
  Future<List<User>> searchUsers(String query);
  Future<void> logout();
}

/// Mock Implementation (for offline development)
class MockUserRepository implements UserRepository {
  final Map<String, User> _users = {
    'user-001': User(
      id: 'user-001',
      email: 'demo@bookcycle.local',
      displayName: 'Demo User',
      location: 'Vienna, Austria',
      roles: ['MEMBER'],
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    ),
    'user-002': User(
      id: 'user-002',
      email: 'moderator@bookcycle.local',
      displayName: 'Moderator',
      location: 'Vienna, Austria',
      roles: ['MODERATOR', 'MEMBER'],
      createdAt: DateTime.now().subtract(const Duration(days: 60)),
    ),
    'user-003': User(
      id: 'user-003',
      email: 'testuser@bookcycle.local',
      displayName: 'Test User',
      location: 'Graz, Austria',
      roles: ['MEMBER'],
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
  };

  final Map<String, String> _passwordByEmail = {
    'demo@bookcycle.local': 'DemoUser123!',
    'moderator@bookcycle.local': 'Moderator123!',
    'testuser@bookcycle.local': 'TestUser123!',
  };

  bool _isLoggedIn = false;
  User? _currentUser;

  @override
  Future<User?> getCurrentUser() async {
    await Future.delayed(const Duration(milliseconds: 250));
    return _isLoggedIn ? _currentUser : null;
  }

  @override
  Future<User> login({required String email, required String password}) async {
    await Future.delayed(const Duration(milliseconds: 350));

    final normalizedEmail = email.trim().toLowerCase();
    final expectedPassword = _passwordByEmail[normalizedEmail];
    if (expectedPassword == null || expectedPassword != password) {
      throw Exception('Invalid email or password.');
    }

    final user = _users.values.firstWhere(
      (candidate) => candidate.email.toLowerCase() == normalizedEmail,
    );

    _isLoggedIn = true;
    _currentUser = user;
    return user;
  }

  @override
  Future<User> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));

    final normalizedEmail = email.trim().toLowerCase();
    final emailInUse = _users.values
        .any((candidate) => candidate.email.toLowerCase() == normalizedEmail);
    if (emailInUse) {
      throw Exception('A user with this email already exists.');
    }

    final newId = 'user-${(_users.length + 1).toString().padLeft(3, '0')}';
    final newUser = User(
      id: newId,
      email: normalizedEmail,
      displayName: displayName.trim(),
      location: null,
      roles: const ['MEMBER'],
      createdAt: DateTime.now(),
      active: true,
    );

    _users[newId] = newUser;
    _passwordByEmail[normalizedEmail] = password;
    _isLoggedIn = true;
    _currentUser = newUser;

    return newUser;
  }

  @override
  Future<void> requestPasswordReset({required String email}) async {
    await Future.delayed(const Duration(milliseconds: 350));
    // Keep response generic for account enumeration protection.
  }

  @override
  Future<void> loginAsDemoUser({String? userId}) async {
    await Future.delayed(const Duration(milliseconds: 250));
    _isLoggedIn = true;
    if (userId != null && _users.containsKey(userId)) {
      _currentUser = _users[userId]!;
      return;
    }
    _currentUser = _users['user-003'];
  }

  @override
  Future<void> updateProfile(User user) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _users[user.id] = user;
    _currentUser = user;
  }

  @override
  Future<List<User>> searchUsers(String query) async {
    await Future.delayed(const Duration(milliseconds: 350));
    return _users.values
        .where((u) => u.displayName.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 250));
    _isLoggedIn = false;
    _currentUser = null;
  }
}

/// Real API Implementation
class ApiUserRepository implements UserRepository {
  final String baseUrl;
  final String keycloakBaseUrl;
  final String realm;
  final String clientId;

  String? _accessToken;

  ApiUserRepository({
    required this.baseUrl,
    this.keycloakBaseUrl = 'http://localhost:8180',
    this.realm = 'bookcycle-mobile',
    this.clientId = 'bookcycle-mobile',
  });

  Uri buildRegistrationUri({String redirectUri = 'http://localhost:3000/'}) {
    return Uri.parse(
      '$keycloakBaseUrl/realms/$realm/protocol/openid-connect/auth',
    ).replace(
      queryParameters: {
        'client_id': clientId,
        'redirect_uri': redirectUri,
        'response_type': 'code',
        'scope': 'openid profile email',
        'kc_action': 'register',
      },
    );
  }

  @override
  Future<User> login({required String email, required String password}) async {
    final tokenUri = Uri.parse(
      '$keycloakBaseUrl/realms/$realm/protocol/openid-connect/token',
    );

    final tokenResponse = await http.post(
      tokenUri,
      headers: const {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'grant_type': 'password',
        'client_id': clientId,
        'username': email.trim(),
        'password': password,
        'scope': 'openid profile email',
      },
    );

    if (tokenResponse.statusCode != 200) {
      throw Exception(_extractErrorMessage(tokenResponse));
    }

    final body = jsonDecode(tokenResponse.body) as Map<String, dynamic>;
    final token = body['access_token']?.toString();
    if (token == null || token.isEmpty) {
      throw Exception('Keycloak did not return an access token.');
    }

    _accessToken = token;
    return _fetchCurrentUser();
  }

  @override
  Future<User> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final registerUri = Uri.parse('$baseUrl/auth/register');

    final response = await http.post(
      registerUri,
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email.trim(),
        'password': password,
        'displayName': displayName.trim(),
      }),
    );

    if (response.statusCode != 201) {
      throw Exception(_extractErrorMessage(response));
    }

    return login(email: email, password: password);
  }

  @override
  Future<void> requestPasswordReset({required String email}) async {
    final resetUri = Uri.parse('$baseUrl/auth/password-reset');

    final response = await http.post(
      resetUri,
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email.trim()}),
    );

    if (response.statusCode != 202) {
      throw Exception(_extractErrorMessage(response));
    }
  }

  @override
  Future<User?> getCurrentUser() async {
    if (_accessToken == null || _accessToken!.isEmpty) {
      return null;
    }

    try {
      return await _fetchCurrentUser();
    } catch (_) {
      _accessToken = null;
      return null;
    }
  }

  @override
  Future<void> loginAsDemoUser({String? userId}) {
    throw UnimplementedError('Use login(email, password) in API mode');
  }

  @override
  Future<void> updateProfile(User user) async {
    final token = _requireAccessToken();
    final uri = Uri.parse('$baseUrl/users/me');

    final response = await http.put(
      uri,
      headers: _authHeaders(token),
      body: jsonEncode({
        'displayName': user.displayName,
        'location': user.location,
        'avatarUrl': user.avatarUrl,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(_extractErrorMessage(response));
    }
  }

  @override
  Future<List<User>> searchUsers(String query) async {
    throw UnimplementedError('Not yet implemented for API mode');
  }

  @override
  Future<void> logout() async {
    final token = _accessToken;
    _accessToken = null;

    if (token == null || token.isEmpty) {
      return;
    }

    final uri = Uri.parse('$baseUrl/auth/logout');
    await http.post(uri, headers: _authHeaders(token));
  }

  Future<User> _fetchCurrentUser() async {
    final token = _requireAccessToken();
    final uri = Uri.parse('$baseUrl/users/me');

    final response = await http.get(uri, headers: _authHeaders(token));
    if (response.statusCode != 200) {
      throw Exception(_extractErrorMessage(response));
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return _mapUser(body);
  }

  User _mapUser(Map<String, dynamic> body) {
    return User(
      id: body['id']?.toString() ?? '',
      email: body['email']?.toString() ?? '',
      displayName: body['displayName']?.toString() ?? '',
      location: body['location']?.toString(),
      roles: (body['roles'] as List<dynamic>? ?? const [])
          .map((item) => item.toString())
          .toList(),
      createdAt: DateTime.tryParse(body['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(body['updatedAt']?.toString() ?? ''),
      avatarUrl: body['avatarUrl']?.toString(),
      active: body['active'] as bool? ?? true,
    );
  }

  String _requireAccessToken() {
    final token = _accessToken;
    if (token == null || token.isEmpty) {
      throw Exception('Not authenticated. Please log in.');
    }
    return token;
  }

  Map<String, String> _authHeaders(String accessToken) {
    return {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    };
  }

  String _extractErrorMessage(http.Response response) {
    try {
      final body = jsonDecode(response.body);
      if (body is Map<String, dynamic>) {
        final message = body['message']?.toString();
        final errorDescription = body['error_description']?.toString();
        final error = body['error']?.toString();

        if (message != null && message.isNotEmpty) {
          return message;
        }
        if (errorDescription != null && errorDescription.isNotEmpty) {
          return errorDescription;
        }
        if (error != null && error.isNotEmpty) {
          return error;
        }
      }
    } catch (_) {
      // Ignore parse errors and use fallback below.
    }

    return 'Request failed with status ${response.statusCode}.';
  }
}
