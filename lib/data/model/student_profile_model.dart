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
  });

  factory StudentProfileModel.fromJson(Map<String, dynamic> json) {
    return StudentProfileModel(
      userId: json['user_id'],
      username: json['username'],
      firstName: json['profile']?['first name'] ?? json['f_name'] ?? '',
      lastName: json['profile']?['last name'] ?? json['l_name'] ?? '',
      gender: json['profile']?['Gender'] ?? json['gender'] ?? '',
      dob: json['profile']?['Date of Birth'] ?? json['dob'] ?? '',
      status: json['details']?['status'],
      healthStatus: json['details']?['health_status'],
      classId: json['details']?['class_id'],
    );
  }
}
