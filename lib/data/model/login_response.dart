// lib/data/model/login_response.dart

class LoginResponse {
  final String token;
  final String message;
  final List<Role> roles;
  final int userId;

  LoginResponse({
    required this.token,
    required this.message,
    required this.roles,
    required this.userId,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    final user = data['user'] ?? {};
    final rolesData = user['roles'] as List? ?? [];

    return LoginResponse(
      token: data['token'] ?? '',
      message: json['message'] ?? '',
      userId: user['user_id'] ?? user['id'] ?? 0,
      roles: rolesData.map((r) => Role.fromJson(r)).toList(),
    );
  }
}

class Role {
  final int roleId;
  final String title;

  Role({required this.roleId, required this.title});

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      roleId: json['role_id'] ?? 0,
      title: json['title'] ?? '',
    );
  }
}
