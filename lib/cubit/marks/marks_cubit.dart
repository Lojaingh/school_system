import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:school_management/data/repository/marks_repository.dart';
import 'package:school_management/utils/shared_prefs_helper.dart';

import 'marks_state.dart';

class MarksCubit extends Cubit<MarksState> {
  final MarksRepository _repository;

  MarksCubit(this._repository) : super(const MarksInitial());

  Future<void> getSubjectMarks() async {
    emit(const MarksLoading());

    try {
      final role =
          (await SharedPrefsHelper.getRole())?.trim().toLowerCase() ?? '';

      final response = await _repository.getSubjectMarks(
        role: role,
      );

      emit(
        MarksLoaded(
          data: response.data,
        ),
      );
    } catch (error) {
      emit(
        MarksError(
          message: _extractErrorMessage(error),
        ),
      );
    }
  }

  Future<void> saveStudentMarks({
    required int studentId,
    required int subjectId,
    required double participation,
    required double firstQuiz,
    required double midtermExam,
    required double secondQuiz,
    required double finalExam,
  }) async {
    emit(const MarksSaving());

    try {
      final response = await _repository.saveStudentMarks(
        studentId: studentId,
        subjectId: subjectId,
        participation: participation,
        firstQuiz: firstQuiz,
        midtermExam: midtermExam,
        secondQuiz: secondQuiz,
        finalExam: finalExam,
      );

      emit(
        MarksSaved(
          response: response,
        ),
      );

      // إعادة تحميل البيانات بعد الحفظ
      await getSubjectMarks();
    } catch (error) {
      emit(
        MarksError(
          message: _extractErrorMessage(error),
        ),
      );
    }
  }

  String _extractErrorMessage(Object error) {
    if (error is DioException) {
      final data = error.response?.data;

      if (data is Map && data['message'] != null) {
        return data['message'].toString();
      }

      if (error.message != null && error.message!.isNotEmpty) {
        return error.message!;
      }

      return 'Something went wrong. Please try again.';
    }

    return error.toString();
  }
}
