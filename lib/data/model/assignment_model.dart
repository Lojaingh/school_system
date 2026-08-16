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
  final int subjectId;
  final int academicId;
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
    // استخراج اسم المادة من الكائن الداخلي
    String subjectName = '';
    if (json['subject'] != null && json['subject'] is Map<String, dynamic>) {
      subjectName = json['subject']['name'] ?? '';
    }

    return Assignment(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      dueDate: json['due_date'] ?? '',
      hasFile: json['has_file'] ?? false,
      fileUrl: json['file_url'],
      fileName: json['file_name'],
      daysRemaining: (json['days_remaining'] ?? 0).toDouble(),
      isOverdue: json['is_overdue'] ?? false,
      subjectId: int.parse(json['subject_id'].toString()),
      academicId: int.parse(json['academic_id'].toString()),
      subjectName: subjectName,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
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
      'subject_id': subjectId,
      'academic_id': academicId,
      'subject_name': subjectName,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
