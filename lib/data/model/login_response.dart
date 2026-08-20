class LoginResponse {
  final String token;
  final String message;
  final List<Role> roles;

  const LoginResponse({
    required this.token,
    required this.message,
    required this.roles,
  });

  factory LoginResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    final data = Map<String, dynamic>.from(
      json['data'] ?? {},
    );

    final rolesData = data['role'] as List? ?? [];

    return LoginResponse(
      token: data['token']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      roles: rolesData
          .whereType<Map>()
          .map(
            (role) => Role.fromJson(
              Map<String, dynamic>.from(role),
            ),
          )
          .toList(),
    );
  }

  String? get roleTitle {
    if (roles.isEmpty) {
      return null;
    }

    return roles.first.title;
  }

  int? get roleId {
    if (roles.isEmpty) {
      return null;
    }

    return roles.first.roleId;
  }
}

class Role {
  final int roleId;
  final String title;
  final String? startedAt;
  final String? finishedAt;

  const Role({
    required this.roleId,
    required this.title,
    this.startedAt,
    this.finishedAt,
  });

  factory Role.fromJson(
    Map<String, dynamic> json,
  ) {
    return Role(
      roleId: _toInt(json['role_id']),
      title: json['title']?.toString() ?? '',
      startedAt: json['started_at']?.toString(),
      finishedAt: json['finished_at']?.toString(),
    );
  }
}

int _toInt(dynamic value) {
  if (value is int) {
    return value;
  }

  return int.tryParse(
        value?.toString() ?? '',
      ) ??
      0;
}
