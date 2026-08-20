class SubjectMarksResponse {
  final SubjectMarksData data;
  final String message;

  const SubjectMarksResponse({
    required this.data,
    required this.message,
  });

  factory SubjectMarksResponse.fromJson(Map<String, dynamic> json) {
    return SubjectMarksResponse(
      data: SubjectMarksData.fromJson(
        Map<String, dynamic>.from(json['data'] ?? {}),
      ),
      message: json['message']?.toString() ?? '',
    );
  }
}

class SubjectMarksData {
  final int subjectId;
  final String? subjectName;
  final List<StudentMark> students;

  const SubjectMarksData({
    required this.subjectId,
    required this.subjectName,
    required this.students,
  });

  factory SubjectMarksData.fromJson(Map<String, dynamic> json) {
    final studentsJson = json['students'] as List? ?? [];

    return SubjectMarksData(
      subjectId: _toInt(json['subject_id']),
      subjectName: json['subject_name']?.toString(),
      students: studentsJson
          .whereType<Map>()
          .map(
            (student) => StudentMark.fromJson(
              Map<String, dynamic>.from(student),
            ),
          )
          .toList(),
    );
  }
}

class StudentMark {
  final int studentId;
  final String studentName;
  final String? className;

  final double? participation;
  final double? firstQuiz;
  final double? midtermExam;
  final double? secondQuiz;
  final double? finalExam;
  final double? total;

  const StudentMark({
    required this.studentId,
    required this.studentName,
    required this.className,
    this.participation,
    this.firstQuiz,
    this.midtermExam,
    this.secondQuiz,
    this.finalExam,
    this.total,
  });

  bool get hasMarks {
    return participation != null ||
        firstQuiz != null ||
        midtermExam != null ||
        secondQuiz != null ||
        finalExam != null;
  }

  factory StudentMark.fromJson(Map<String, dynamic> json) {
    return StudentMark(
      studentId: _toInt(json['student_id']),
      studentName: json['student_name']?.toString() ?? '',
      className: json['class_name']?.toString(),
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

double? _toDouble(dynamic value) {
  if (value == null) return null;

  if (value is num) {
    return value.toDouble();
  }

  return double.tryParse(value.toString());
}
