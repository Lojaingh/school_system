// lib/data/model/profile_model.dart

class ProfileModel {
  final int userId;
  final String username;
  final Profile profile;
  final List<Role> roles;

  ProfileModel({
    required this.userId,
    required this.username,
    required this.profile,
    required this.roles,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    final rolesData = json['roles'] as List? ?? [];

    return ProfileModel(
      userId: json['user_id'] ?? 0,
      username: json['username'] ?? '',
      profile: Profile.fromJson(json['profile'] ?? {}),
      roles: rolesData.map((r) => Role.fromJson(r)).toList(),
    );
  }
}

class Profile {
  final String firstName;
  final String lastName;
  final String dateOfBirth;
  final String gender;

  Profile({
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
    required this.gender,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      firstName: json['first name'] ?? json['f_name'] ?? '',
      lastName: json['last name'] ?? json['l_name'] ?? '',
      dateOfBirth: json['Date of Birth'] ?? json['dob'] ?? '',
      gender: json['Gender'] ?? json['gender'] ?? '',
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
