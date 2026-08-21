class SubjectMarksResponse {
  final SubjectMarksData data;
  final String message;

  const SubjectMarksResponse({
    required this.data,
    required this.message,
  });

  factory SubjectMarksResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    return SubjectMarksResponse(
      data: SubjectMarksData.fromJson(
        Map<String, dynamic>.from(
          json['data'] ?? {},
        ),
      ),
      message: json['message']?.toString() ?? '',
    );
  }
}

class SubjectMarksData {
  final int subjectId;
  final String? subjectName;

  // الشكل القديم للأستاذ
  final List<StudentMark> students;

  // الشكل الجديد للمدير والموجه
  final List<MarksClass> classes;

  const SubjectMarksData({
    required this.subjectId,
    required this.subjectName,
    required this.students,
    required this.classes,
  });

  bool get isGrouped => classes.isNotEmpty;

  factory SubjectMarksData.fromJson(
    Map<String, dynamic> json,
  ) {
    // =========================================================
    // الشكل الجديد:
    // {
    //   classes: [
    //     {
    //       class_id,
    //       class_name,
    //       students: [...]
    //     }
    //   ]
    // }
    // =========================================================

    final classesJson = json['classes'];

    if (classesJson is List) {
      return SubjectMarksData(
        subjectId: 0,
        subjectName: null,
        students: const [],
        classes: classesJson
            .whereType<Map>()
            .map(
              (item) => MarksClass.fromJson(
                Map<String, dynamic>.from(item),
              ),
            )
            .toList(),
      );
    }

    // =========================================================
    // الشكل القديم للأستاذ:
    // {
    //   subject_id,
    //   subject_name,
    //   students: [...]
    // }
    // =========================================================

    final studentsJson = json['students'] as List? ?? [];

    return SubjectMarksData(
      subjectId: _toInt(json['subject_id']),
      subjectName: json['subject_name']?.toString(),
      students: studentsJson
          .whereType<Map>()
          .map(
            (student) => StudentMark.fromLegacyJson(
              Map<String, dynamic>.from(student),
            ),
          )
          .toList(),
      classes: const [],
    );
  }

  // كل المواد الموجودة ضمن كل الصفوف
  List<SubjectInfo> get availableSubjects {
    final Map<int, SubjectInfo> unique = {};

    for (final schoolClass in classes) {
      for (final student in schoolClass.students) {
        for (final subject in student.subjects) {
          unique[subject.subjectId] = SubjectInfo(
            id: subject.subjectId,
            name: subject.name,
          );
        }
      }
    }

    final result = unique.values.toList();

    result.sort(
      (a, b) => a.name.compareTo(b.name),
    );

    return result;
  }

  // الطلاب حسب الصف + المادة
  List<StudentMark> studentsForSubject({
    required int subjectId,
    int? classId,
  }) {
    final List<StudentMark> result = [];

    for (final schoolClass in classes) {
      if (classId != null && schoolClass.classId != classId) {
        continue;
      }

      for (final student in schoolClass.students) {
        final subject = student.subjects.cast<StudentSubjectMark?>().firstWhere(
              (s) => s?.subjectId == subjectId,
              orElse: () => null,
            );

        if (subject == null) {
          continue;
        }

        result.add(
          StudentMark.fromGroupedStudent(
            student: student,
            subject: subject,
          ),
        );
      }
    }

    return result;
  }

  // جميع الصفوف
  List<MarksClass> get availableClasses {
    return List<MarksClass>.from(classes)
      ..sort(
        (a, b) => a.className.compareTo(b.className),
      );
  }
}

class MarksClass {
  final int classId;
  final String className;
  final List<MarksGroupedStudent> students;

  const MarksClass({
    required this.classId,
    required this.className,
    required this.students,
  });

  factory MarksClass.fromJson(
    Map<String, dynamic> json,
  ) {
    final studentsJson = json['students'] as List? ?? [];

    return MarksClass(
      classId: _toInt(json['class_id']),
      className: json['class_name']?.toString() ?? '',
      students: studentsJson
          .whereType<Map>()
          .map(
            (student) => MarksGroupedStudent.fromJson(
              Map<String, dynamic>.from(student),
            ),
          )
          .toList(),
    );
  }
}

class MarksGroupedStudent {
  final int studentId;
  final String studentName;
  final int classId;
  final String? className;
  final List<StudentSubjectMark> subjects;
  final double? generalAverage;
  final bool isComplete;

  const MarksGroupedStudent({
    required this.studentId,
    required this.studentName,
    required this.classId,
    required this.className,
    required this.subjects,
    required this.generalAverage,
    required this.isComplete,
  });

  factory MarksGroupedStudent.fromJson(
    Map<String, dynamic> json,
  ) {
    final subjectsJson = json['subjects'] as List? ?? [];

    return MarksGroupedStudent(
      studentId: _toInt(json['student_id']),
      studentName: json['student_name']?.toString() ?? '',
      classId: _toInt(json['class_id']),
      className: json['class_name']?.toString(),
      subjects: subjectsJson
          .whereType<Map>()
          .map(
            (subject) => StudentSubjectMark.fromJson(
              Map<String, dynamic>.from(subject),
            ),
          )
          .toList(),
      generalAverage: _toDouble(json['general_average']),
      isComplete: json['is_complete'] == true,
    );
  }
}

class StudentSubjectMark {
  final int subjectId;
  final String name;
  final double? participation;
  final double? firstQuiz;
  final double? midtermExam;
  final double? secondQuiz;
  final double? finalExam;
  final double? total;

  const StudentSubjectMark({
    required this.subjectId,
    required this.name,
    this.participation,
    this.firstQuiz,
    this.midtermExam,
    this.secondQuiz,
    this.finalExam,
    this.total,
  });

  factory StudentSubjectMark.fromJson(
    Map<String, dynamic> json,
  ) {
    return StudentSubjectMark(
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

class SubjectInfo {
  final int id;
  final String name;

  const SubjectInfo({
    required this.id,
    required this.name,
  });
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

  final int? subjectId;
  final String? subjectName;

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
    this.subjectId,
    this.subjectName,
  });

  factory StudentMark.fromLegacyJson(
    Map<String, dynamic> json,
  ) {
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
      subjectId: _toInt(json['subject_id']),
      subjectName: json['subject_name']?.toString(),
    );
  }

  factory StudentMark.fromGroupedStudent({
    required MarksGroupedStudent student,
    required StudentSubjectMark subject,
  }) {
    return StudentMark(
      studentId: student.studentId,
      studentName: student.studentName,
      className: student.className,
      participation: subject.participation,
      firstQuiz: subject.firstQuiz,
      midtermExam: subject.midtermExam,
      secondQuiz: subject.secondQuiz,
      finalExam: subject.finalExam,
      total: subject.total,
      subjectId: subject.subjectId,
      subjectName: subject.name,
    );
  }

  bool get hasMarks {
    return participation != null ||
        firstQuiz != null ||
        midtermExam != null ||
        secondQuiz != null ||
        finalExam != null;
  }
}

int _toInt(dynamic value) {
  if (value is int) {
    return value;
  }

  return int.tryParse(
        value?.toString() ?? '',
      ) ??
      0;
}

double? _toDouble(dynamic value) {
  if (value == null) {
    return null;
  }

  if (value is num) {
    return value.toDouble();
  }

  return double.tryParse(
    value.toString(),
  );
}
