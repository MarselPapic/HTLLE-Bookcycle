// lib/features/identity/domain/user.dart

class User {
  final String id;
  final String email;
  final String displayName;
  final String? location;
  final List<String> roles;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? avatarUrl;
  final bool active;

  User({
    required this.id,
    required this.email,
    required this.displayName,
    this.location,
    required this.roles,
    required this.createdAt,
    this.updatedAt,
    this.avatarUrl,
    this.active = true,
  });

  User copyWith({
    String? id,
    String? email,
    String? displayName,
    String? location,
    List<String>? roles,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? avatarUrl,
    bool? active,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      location: location ?? this.location,
      roles: roles ?? this.roles,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      active: active ?? this.active,
    );
  }

  bool hasRole(String role) => roles.contains(role);

  bool get isAdmin => hasRole('ADMIN');
  bool get isModerator => hasRole('MODERATOR');
  bool get isMember => hasRole('MEMBER');

  @override
  String toString() => 'User(id: $id, email: $email, displayName: $displayName)';
}
