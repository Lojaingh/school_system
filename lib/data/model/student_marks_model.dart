class StudentMarksResponse {
  final StudentMarksData data;
  final String message;

  const StudentMarksResponse({
    required this.data,
    required this.message,
  });

  factory StudentMarksResponse.fromJson(Map<String, dynamic> json) {
    return StudentMarksResponse(
      data: StudentMarksData.fromJson(
        Map<String, dynamic>.from(json['data'] ?? {}),
      ),
      message: json['message']?.toString() ?? '',
    );
  }
}

class StudentMarksData {
  final int studentId;
  final String studentName;
  final int? classId;
  final String? className;
  final List<SubjectMark> subjects;
  final double? generalAverage;
  final bool isComplete;

  const StudentMarksData({
    required this.studentId,
    required this.studentName,
    required this.classId,
    required this.className,
    required this.subjects,
    required this.generalAverage,
    required this.isComplete,
  });

  factory StudentMarksData.fromJson(Map<String, dynamic> json) {
    final subjectsJson = json['subjects'] as List? ?? [];

    return StudentMarksData(
      studentId: _toInt(json['student_id']),
      studentName: json['student_name']?.toString() ?? '',
      classId: _toNullableInt(json['class_id']),
      className: json['class_name']?.toString(),
      subjects: subjectsJson
          .whereType<Map>()
          .map(
            (subject) => SubjectMark.fromJson(
              Map<String, dynamic>.from(subject),
            ),
          )
          .toList(),
      generalAverage: _toDouble(json['general_average']),
      isComplete: json['is_complete'] == true,
    );
  }
}

class SubjectMark {
  final int subjectId;
  final String name;

  final double? participation;
  final double? firstQuiz;
  final double? midtermExam;
  final double? secondQuiz;
  final double? finalExam;
  final double? total;

  const SubjectMark({
    required this.subjectId,
    required this.name,
    this.participation,
    this.firstQuiz,
    this.midtermExam,
    this.secondQuiz,
    this.finalExam,
    this.total,
  });

  factory SubjectMark.fromJson(Map<String, dynamic> json) {
    return SubjectMark(
      subjectId: _toInt(json['subject_id']),
      name: json['name']?.toString() ?? '',
      participation: _toDouble(json['participation']),
      firstQuiz: _toDouble(json['first_quiz']),
      midtermExam: _toDouble(json['midterm_exam']),
      secondQuiz: _toDouble(json['second_quiz']),
      finalExam: _toDouble(json['final_exam']),
      total: _toDouble(json['total']),
    );
  }
}

int _toInt(dynamic value) {
  if (value is int) return value;

  return int.tryParse(
        value?.toString() ?? '',
      ) ??
      0;
}

int? _toNullableInt(dynamic value) {
  if (value == null) return null;

  return _toInt(value);
}

double? _toDouble(dynamic value) {
  if (value == null) return null;

  if (value is num) {
    return value.toDouble();
  }

  return double.tryParse(value.toString());
}
