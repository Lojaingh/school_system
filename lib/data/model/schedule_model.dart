class ScheduleSlot {
  final int id;
  final int classId;
  final String? className;
  final int subjectId;
  final String? subjectName;
  final int teacherId;
  final String? teacherUserName;
  final String? teacherName;
  final int? academicYearId;
  final int dayOfWeek;
  final String? dayLabel;
  final int periodNumber;

  ScheduleSlot({
    required this.id,
    required this.classId,
    this.className,
    required this.subjectId,
    this.subjectName,
    required this.teacherId,
    this.teacherUserName,
    this.teacherName,
    this.academicYearId,
    required this.dayOfWeek,
    this.dayLabel,
    required this.periodNumber,
  });

  factory ScheduleSlot.fromJson(Map<String, dynamic> json) {
    int _toInt(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      if (v is String) return int.tryParse(v) ?? 0;
      return 0;
    }

    final classObj = json['class'] as Map<String, dynamic>?;
    final subjectObj = json['subject'] as Map<String, dynamic>?;
    final teacherObj = json['teacher'] as Map<String, dynamic>?;

    return ScheduleSlot(
      id: _toInt(json['id']),
      classId: json['class_id'] != null
          ? _toInt(json['class_id'])
          : _toInt(classObj?['id']),
      className:
          json['class_name']?.toString() ?? classObj?['name']?.toString(),
      subjectId: json['subject_id'] != null
          ? _toInt(json['subject_id'])
          : _toInt(subjectObj?['id']),
      subjectName:
          json['subject_name']?.toString() ?? subjectObj?['name']?.toString(),
      teacherId: json['teacher_id'] != null
          ? _toInt(json['teacher_id'])
          : _toInt(teacherObj?['id']),
      teacherUserName: teacherObj?['user_name']?.toString(),
      academicYearId: json['academic_year_id'] != null
          ? _toInt(json['academic_year_id'])
          : null,
      dayOfWeek: _toInt(json['day_of_week']),
      dayLabel: json['day_label']?.toString(),
      periodNumber: _toInt(json['period_number']),
    );
  }

  ScheduleSlot withTeacherName(String? name) {
    return ScheduleSlot(
      id: id,
      classId: classId,
      className: className,
      subjectId: subjectId,
      subjectName: subjectName,
      teacherId: teacherId,
      teacherUserName: teacherUserName,
      teacherName: name,
      academicYearId: academicYearId,
      dayOfWeek: dayOfWeek,
      dayLabel: dayLabel,
      periodNumber: periodNumber,
    );
  }

  static const List<String> dayNames = [
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
  ];

  String get dayName =>
      dayLabel ??
      ((dayOfWeek >= 0 && dayOfWeek < dayNames.length)
          ? dayNames[dayOfWeek]
          : 'Day $dayOfWeek');

  String get teacherDisplayName =>
      teacherName ?? teacherUserName ?? 'Teacher #$teacherId';

  static List<ScheduleSlot> listFromResponse(dynamic data) {
    List rawList = [];
    if (data is List) {
      rawList = data;
    } else if (data is Map<String, dynamic>) {
      if (data['data'] is List) {
        rawList = data['data'];
      } else if (data['schedules'] is List) {
        rawList = data['schedules'];
      }
    }
    return rawList
        .whereType<Map>()
        .map((e) => ScheduleSlot.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
}

class ClassItem {
  final int id;
  final String name;

  ClassItem({required this.id, required this.name});

  factory ClassItem.fromJson(Map<String, dynamic> json) {
    return ClassItem(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      name: (json['name'] ?? json['class_name'] ?? 'Class #${json['id']}')
          .toString(),
    );
  }

  static List<ClassItem> listFromResponse(dynamic data) {
    List rawList = [];
    if (data is List) {
      rawList = data;
    } else if (data is Map<String, dynamic>) {
      if (data['data'] is List) {
        rawList = data['data'];
      } else if (data['classes'] is List) {
        rawList = data['classes'];
      }
    }
    return rawList
        .whereType<Map>()
        .map((e) => ClassItem.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
}

class SubjectItem {
  final int id;
  final String name;

  SubjectItem({required this.id, required this.name});

  factory SubjectItem.fromJson(Map<String, dynamic> json) {
    return SubjectItem(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      name: (json['name'] ?? 'Subject #${json['id']}').toString(),
    );
  }

  static List<SubjectItem> listFromResponse(dynamic data) {
    List rawList = [];
    if (data is List) {
      rawList = data;
    } else if (data is Map<String, dynamic>) {
      if (data['data'] is List) {
        rawList = data['data'];
      } else if (data['subjects'] is List) {
        rawList = data['subjects'];
      }
    }
    return rawList
        .whereType<Map>()
        .map((e) => SubjectItem.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
}

class StaffMember {
  final int id;
  final String username;
  final String name;
  final bool isTeacher;

  StaffMember({
    required this.id,
    required this.username,
    required this.name,
    required this.isTeacher,
  });

  factory StaffMember.fromJson(Map<String, dynamic> json) {
    final id = json['user_id'] is int
        ? json['user_id']
        : int.tryParse(json['user_id'].toString()) ?? 0;
    final username = json['username']?.toString() ?? '';

    final profile = json['profile'] as Map<String, dynamic>?;
    final f = (profile?['f_name'] ?? '').toString();
    final l = (profile?['l_name'] ?? '').toString();
    final fullName = '$f $l'.trim();

    bool isTeacher = false;
    final roles = json['roles'];
    if (roles is List) {
      isTeacher = roles.any((r) {
        if (r is! Map) return false;
        final title = r['title']?.toString().trim().toLowerCase();
        final roleId = r['role_id']?.toString();
        return title == 'teacher' || roleId == '5';
      });
    } else if (json['role'] is Map) {
      final r = json['role'] as Map;
      final title = r['title']?.toString().trim().toLowerCase();
      final roleId = r['role_id']?.toString();
      isTeacher = title == 'teacher' || roleId == '5';
    }

    return StaffMember(
      id: id,
      username: username,
      name: fullName.isEmpty
          ? (username.isEmpty ? 'Staff #$id' : username)
          : fullName,
      isTeacher: isTeacher,
    );
  }

  static List<StaffMember> listFromResponse(dynamic data) {
    List rawList = [];
    if (data is List) {
      rawList = data;
    } else if (data is Map<String, dynamic>) {
      if (data['data'] is List) {
        rawList = data['data'];
      } else if (data['staff'] is List) {
        rawList = data['staff'];
      }
    }
    return rawList
        .whereType<Map>()
        .map((e) => StaffMember.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
}
