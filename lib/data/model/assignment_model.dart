// lib/data/model/assignment_model.dart

class Assignment {
  final int id;
  final String title;
  final String body;
  final String dueDate;

  final bool hasFile;
  final String? fileUrl;
  final String? fileName;

  final double daysRemaining;
  final bool isOverdue;

  // رقم المادة
  final int subjectId;

  // السنة الدراسية - تأتي من Backend
  final int academicId;

  // اسم المادة
  final String subjectName;

  final String createdAt;
  final String updatedAt;

  Assignment({
    required this.id,
    required this.title,
    required this.body,
    required this.dueDate,
    required this.hasFile,
    this.fileUrl,
    this.fileName,
    required this.daysRemaining,
    required this.isOverdue,
    required this.subjectId,
    required this.academicId,
    required this.subjectName,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Assignment.fromJson(Map<String, dynamic> json) {
    int subjectId = _parseInt(json['subject_id']);

    String subjectName = '';

    // إذا الـ API رجع subject كـ object
    if (json['subject'] is Map) {
      final subject = json['subject'] as Map;

      subjectName = subject['name']?.toString() ?? '';

      // احتياطاً إذا subject_id غير موجود
      if (subjectId == 0 && subject['id'] != null) {
        subjectId = _parseInt(subject['id']);
      }
    }

    // إذا الـ API رجع subject_name بشكل مباشر
    if (subjectName.isEmpty && json['subject_name'] != null) {
      subjectName = json['subject_name'].toString();
    }

    return Assignment(
      id: _parseInt(json['id']),
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      dueDate: json['due_date']?.toString() ?? '',

      hasFile: _parseBool(json['has_file']),

      fileUrl: json['file_url']?.toString(),
      fileName: json['file_name']?.toString(),

      daysRemaining: _parseDouble(
        json['days_remaining'],
      ),

      isOverdue: _parseBool(
        json['is_overdue'],
      ),

      subjectId: subjectId,

      // تأتي من Backend
      academicId: _parseInt(
        json['academic_id'],
      ),

      subjectName: subjectName,

      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'due_date': dueDate,

      'has_file': hasFile,
      'file_url': fileUrl,
      'file_name': fileName,

      'days_remaining': daysRemaining,
      'is_overdue': isOverdue,

      // رقم المادة
      'subject_id': subjectId,

      // قراءة فقط من Backend
      'academic_id': academicId,

      'subject_name': subjectName,

      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;

    if (value is int) {
      return value;
    }

    return int.tryParse(
          value.toString(),
        ) ??
        0;
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0;

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
          value.toString(),
        ) ??
        0;
  }

  static bool _parseBool(dynamic value) {
    if (value is bool) {
      return value;
    }

    if (value is int) {
      return value == 1;
    }

    if (value is String) {
      return value.toLowerCase() == 'true' || value == '1';
    }

    return false;
  }
}
