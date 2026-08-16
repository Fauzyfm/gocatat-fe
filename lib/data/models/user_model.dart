class UserProfile {
  final int userId;
  final String email;
  final String role;

  UserProfile({
    required this.userId,
    required this.email,
    required this.role,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userId: json['user_id'] as int,
      email: json['email'] as String,
      role: json['role'] as String,
    );
  }
}

class RegisterResponse {
  final int id;
  final String username;
  final String email;
  final String role;
  final String createdAt;
  final String updateAt;

  RegisterResponse({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
    required this.createdAt,
    required this.updateAt,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      id: json['id'] as int,
      username: json['username'] as String,
      email: json['email'] as String,
      role: json['role'] ?? 'user',
      createdAt: json['createdAt'] ?? '',
      updateAt: json['updateAt'] ?? '',
    );
  }
}
