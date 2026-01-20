// lib/shared/models/user_model.dart

/// User Model
/// 
/// Represents a user in Bookcycle system.
/// Used in both API responses and mock data.
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

  /// Create a copy with modifications
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

  /// Check if user has specific role
  bool hasRole(String role) => roles.contains(role);

  bool get isAdmin => hasRole('ADMIN');
  bool get isModerator => hasRole('MODERATOR');
  bool get isMember => hasRole('MEMBER');

  /// Convert JSON to User (from API response)
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String,
      location: json['location'] as String?,
      roles: List<String>.from(json['roles'] as List? ?? []),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : null,
      avatarUrl: json['avatarUrl'] as String?,
      active: json['active'] as bool? ?? true,
    );
  }

  /// Convert User to JSON (for API requests)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'location': location,
      'roles': roles,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'avatarUrl': avatarUrl,
      'active': active,
    };
  }

  @override
  String toString() => 'User(id: $id, email: $email, displayName: $displayName)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          email == other.email;

  @override
  int get hashCode => id.hashCode ^ email.hashCode;
}
