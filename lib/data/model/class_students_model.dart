import 'package:school_management/data/model/student_profile_model.dart';

class ClassStudentsResponse {
  final List<ClassStudent> students;
  final ClassInfo classInfo;

  ClassStudentsResponse({
    required this.students,
    required this.classInfo,
  });

  factory ClassStudentsResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as List? ?? [];
    final students = data.map((e) => ClassStudent.fromJson(e)).toList();

    return ClassStudentsResponse(
      students: students,
      classInfo: ClassInfo.fromJson(json['meta']?['class_info'] ?? {}),
    );
  }
}

class ClassStudent {
  final StudentProfileModel profile;
  String status;
  String? time;

  ClassStudent({
    required this.profile,
    this.status = 'Present',
    this.time,
  });

  factory ClassStudent.fromJson(Map<String, dynamic> json) {
    return ClassStudent(
      profile: StudentProfileModel.fromJson(json),
    );
  }

  int get userId => profile.userId ?? 0;
  String get username => profile.username ?? '';
  String get firstName => profile.firstName;
  String get lastName => profile.lastName;
  String get dob => profile.dob;
  String get gender => profile.gender;
  String get fullName => '$firstName $lastName'.trim();
}

class ClassInfo {
  final int classId;
  final int year;
  final int number;

  ClassInfo({
    required this.classId,
    required this.year,
    required this.number,
  });

  factory ClassInfo.fromJson(Map<String, dynamic> json) {
    final schoolClass = json['school_class'] ?? {};
    return ClassInfo(
      classId: schoolClass['id'] ?? 0,
      year: schoolClass['year'] ?? 0,
      number: schoolClass['number'] ?? 0,
    );
  }

  String get displayName => 'Grade $year - Section $number';
}
