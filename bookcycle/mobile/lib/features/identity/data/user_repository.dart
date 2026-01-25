// lib/features/identity/data/user_repository.dart

import '../domain/user.dart';

/// Repository Pattern for User Management
///
/// Decouples business logic from data sources.
/// Supports both real API and mock data for offline development.
abstract class UserRepository {
  Future<User?> getCurrentUser();
  Future<void> updateProfile(User user);
  Future<List<User>> searchUsers(String query);
  Future<void> logout();
}

/// Mock Implementation (for offline development)
class MockUserRepository implements UserRepository {
  // In-memory data store
  final Map<String, User> _users = {
    'user-001': User(
      id: 'user-001',
      email: 'demo@bookcycle.local',
      displayName: 'Demo User',
      location: 'Vienna, Austria',
      roles: ['MEMBER'],
      createdAt: DateTime.now().subtract(Duration(days: 30)),
    ),
    'user-002': User(
      id: 'user-002',
      email: 'moderator@bookcycle.local',
      displayName: 'Moderator',
      location: 'Vienna, Austria',
      roles: ['MODERATOR', 'MEMBER'],
      createdAt: DateTime.now().subtract(Duration(days: 60)),
    ),
  };

  late User _currentUser = _users['user-001']!;

  @override
  Future<User?> getCurrentUser() async {
    await Future.delayed(Duration(milliseconds: 500)); // Simulate network delay
    return _currentUser;
  }

  @override
  Future<void> updateProfile(User user) async {
    await Future.delayed(Duration(milliseconds: 300));
    _users[user.id] = user;
    _currentUser = user;
  }

  @override
  Future<List<User>> searchUsers(String query) async {
    await Future.delayed(Duration(milliseconds: 500));
    return _users.values
        .where((u) => u.displayName.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  @override
  Future<void> logout() async {
    await Future.delayed(Duration(milliseconds: 300));
    // Reset to default state
  }
}

/// Real API Implementation (production)
class ApiUserRepository implements UserRepository {
  final String baseUrl;

  ApiUserRepository({required this.baseUrl});

  @override
  Future<User?> getCurrentUser() async {
    // Implementation using HTTP client to call /api/v1/users/me
    throw UnimplementedError('Use real HTTP client implementation');
  }

  @override
  Future<void> updateProfile(User user) async {
    // Implementation using HTTP client to call PUT /api/v1/users/me
    throw UnimplementedError('Use real HTTP client implementation');
  }

  @override
  Future<List<User>> searchUsers(String query) async {
    // Future endpoint
    throw UnimplementedError('Not yet implemented');
  }

  @override
  Future<void> logout() async {
    // Implementation using HTTP client to call POST /api/v1/auth/logout
    throw UnimplementedError('Use real HTTP client implementation');
  }
}
