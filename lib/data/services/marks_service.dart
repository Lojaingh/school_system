import 'package:dio/dio.dart';

import 'package:school_management/data/model/student_marks_model.dart';
import 'package:school_management/data/model/subject_marks_model.dart';

import '../network/dio_client.dart';

class MarksService {
  Dio get _dio => DioClient.dio;

  Future<SubjectMarksResponse> getSubjectMarks({
    required String role,
  }) async {
    final normalizedRole = role.trim().toLowerCase();

    final endpoint =
        normalizedRole == 'teacher' ? '/teacher/marks' : '/supervisor/marks';

    final response = await _dio.get(endpoint);

    return SubjectMarksResponse.fromJson(
      Map<String, dynamic>.from(response.data),
    );
  }

  Future<StudentMarksResponse> saveStudentMarks({
    required int studentId,
    required double participation,
    required double firstQuiz,
    required double midtermExam,
    required double secondQuiz,
    required double finalExam,
  }) async {
    final response = await _dio.post(
      '/marks/student/$studentId',
      data: {
        'participation': participation,
        'first_quiz': firstQuiz,
        'midterm_exam': midtermExam,
        'second_quiz': secondQuiz,
        'final_exam': finalExam,
      },
    );

    return StudentMarksResponse.fromJson(
      Map<String, dynamic>.from(response.data),
    );
  }
}
