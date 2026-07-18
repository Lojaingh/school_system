class StaffProfileModel {
  final int? userId;
  final String? username;

  final String firstName;
  final String lastName;
  final String gender;
  final String dob;

  final String? role;
  final int? roleId;

  final String? startedAt;
  final String? finishedAt;

  final String? hireDate;
  final String? employment;
  final double? salary;
  final String? contact;

  StaffProfileModel({
    this.userId,
    this.username,
    required this.firstName,
    required this.lastName,
    required this.gender,
    required this.dob,
    this.role,
    this.roleId,
    this.startedAt,
    this.finishedAt,
    this.hireDate,
    this.employment,
    this.salary,
    this.contact,
  });

  factory StaffProfileModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final roles = json["roles"] ?? [];

    return StaffProfileModel(
      userId: json["user_id"],
      username: json["username"],
      firstName: json["profile"]?["first name"] ?? "",
      lastName: json["profile"]?["last name"] ?? "",
      gender: json["profile"]?["Gender"] ?? "",
      dob: json["profile"]?["Date of Birth"] ?? "",
      role: roles.isNotEmpty ? roles[0]["title"] : null,
      roleId: roles.isNotEmpty ? roles[0]["role_id"] : null,
      startedAt: roles.isNotEmpty ? roles[0]["started_at"] : null,
      finishedAt: roles.isNotEmpty ? roles[0]["finished_at"] : null,
    );
  }

  factory StaffProfileModel.fromProfileJson(
    Map<String, dynamic> json,
  ) {
    final details = json["details"] ?? {};
    final roles = details["roles"] ?? [];

    return StaffProfileModel(
      userId: json["user_id"],
      username: json["username"],
      firstName: json["profile"]?["first name"] ?? "",
      lastName: json["profile"]?["last name"] ?? "",
      gender: json["profile"]?["Gender"] ?? "",
      dob: json["profile"]?["Date of Birth"] ?? "",
      role: roles.isNotEmpty ? roles[0]["title"] : null,
      roleId: roles.isNotEmpty ? roles[0]["role_id"] : null,
      startedAt: roles.isNotEmpty ? roles[0]["started_at"] : null,
      finishedAt: roles.isNotEmpty ? roles[0]["finished_at"] : null,
      hireDate: details["hire_date"],
      employment: details["employment"],
      salary: details["salary"] != null
          ? double.tryParse(details["salary"].toString())
          : null,
      contact: details["contact"],
    );
  }
}
