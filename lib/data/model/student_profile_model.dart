class StudentProfileModel {
  final int? userId;
  final String? username;
  final String firstName;
  final String lastName;
  final String gender;
  final String dob;
  final String? status;
  final String? healthStatus;
  final int? classId;
  final int? grade;

  StudentProfileModel({
    this.userId,
    this.username,
    required this.firstName,
    required this.lastName,
    required this.gender,
    required this.dob,
    this.status,
    this.healthStatus,
    this.classId,
    this.grade,
  });

  factory StudentProfileModel.fromJson(Map<String, dynamic> json) {
    final profile = json['profile'] ?? {};

    String firstName = '';
    String lastName = '';
    String gender = '';
    String dob = '';

    if (profile.isNotEmpty) {
      firstName =
          profile['name'] ?? profile['first name'] ?? profile['f_name'] ?? '';

      lastName = profile['l_name'] ?? profile['last name'] ?? '';

      gender = profile['gender'] ?? profile['Gender'] ?? '';

      dob = profile['dob'] ?? profile['Date of Birth'] ?? '';
    }

    if (firstName.isEmpty) {
      firstName = json['f_name'] ?? json['first name'] ?? '';
    }

    if (lastName.isEmpty) {
      lastName = json['l_name'] ?? json['last name'] ?? '';
    }

    if (gender.isEmpty) {
      gender = json['gender'] ?? json['Gender'] ?? '';
    }

    if (dob.isEmpty) {
      dob = json['dob'] ?? json['Date of Birth'] ?? '';
    }

    int? classId;

    if (json['details'] != null) {
      classId = json['details']['class_id'];
    }

    if (classId == null && json['enrollments'] != null) {
      final enrollments = json['enrollments'] as List? ?? [];

      if (enrollments.isNotEmpty) {
        final schoolClass = enrollments.first['school_class'] ?? {};

        classId = schoolClass['id'];
      }
    }

    return StudentProfileModel(
      userId: json['user_id'] ?? json['id'],
      username: json['username'],
      firstName: firstName,
      lastName: lastName,
      gender: gender,
      dob: dob,
      status: json['details']?['status'] ?? json['status'],
      healthStatus: json['details']?['health_status'] ?? json['health_status'],
      classId: classId,
      grade: json['grade'],
    );
  }

  String get fullName => '$firstName $lastName'.trim();
}
