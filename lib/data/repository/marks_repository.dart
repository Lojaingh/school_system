import 'package:school_management/data/model/student_marks_model.dart';
import 'package:school_management/data/model/subject_marks_model.dart';
import 'package:school_management/data/services/marks_service.dart';

class MarksRepository {
  final MarksService _service;

  MarksRepository(
    this._service,
  );

  Future<SubjectMarksResponse> getSubjectMarks({
    required String role,
  }) {
    return _service.getSubjectMarks(
      role: role,
    );
  }

  Future<StudentMarksResponse> saveStudentMarks({
    required int studentId,
    required double participation,
    required double firstQuiz,
    required double midtermExam,
    required double secondQuiz,
    required double finalExam,
  }) {
    return _service.saveStudentMarks(
      studentId: studentId,
      participation: participation,
      firstQuiz: firstQuiz,
      midtermExam: midtermExam,
      secondQuiz: secondQuiz,
      finalExam: finalExam,
    );
  }
}
