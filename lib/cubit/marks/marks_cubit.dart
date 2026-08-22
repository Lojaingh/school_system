import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:school_management/data/repository/marks_repository.dart';
import 'package:school_management/utils/shared_prefs_helper.dart';

import 'marks_state.dart';

class MarksCubit extends Cubit<MarksState> {
  final MarksRepository _repository;

  MarksCubit(this._repository) : super(const MarksInitial());

  // ============================================================
  // GET MARKS
  // ============================================================

  Future<void> getSubjectMarks() async {
    emit(const MarksLoading());

    try {
      final role =
          (await SharedPrefsHelper.getRole())?.trim().toLowerCase() ?? '';

      if (role.isEmpty) {
        emit(
          const MarksError(
            message: 'User role not found. Please login again.',
            statusCode: 401,
          ),
        );
        return;
      }

      print('🔵 MARKS CUBIT ROLE: $role');

      final response = await _repository.getSubjectMarks(
        role: role,
      );

      emit(
        MarksLoaded(
          data: response.data,
        ),
      );
    } catch (error) {
      print('❌ GET MARKS ERROR: $error');

      final errorInfo = _extractError(error);

      if (errorInfo.statusCode == 401) {
        await _clearSession();
      }

      emit(
        MarksError(
          message: errorInfo.message,
          statusCode: errorInfo.statusCode,
        ),
      );
    }
  }

  // ============================================================
  // SAVE STUDENT MARKS
  // ============================================================

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

      print('✅ MARKS SAVED SUCCESSFULLY');

      emit(
        MarksSaved(
          response: response,
        ),
      );
    } catch (error) {
      print('❌ SAVE MARKS ERROR: $error');

      final errorInfo = _extractError(error);

      if (errorInfo.statusCode == 401) {
        await _clearSession();
      }

      emit(
        MarksError(
          message: errorInfo.message,
          statusCode: errorInfo.statusCode,
        ),
      );
    }
  }

  // ============================================================
  // RELOAD AFTER SAVE
  // ============================================================

  Future<void> _reloadMarksAfterSave() async {
    try {
      final role =
          (await SharedPrefsHelper.getRole())?.trim().toLowerCase() ?? '';

      if (role.isEmpty) {
        return;
      }

      final response = await _repository.getSubjectMarks(
        role: role,
      );

      emit(
        MarksLoaded(
          data: response.data,
        ),
      );
    } catch (error) {
      print('⚠️ MARKS RELOAD ERROR: $error');

      // هون ما منحوّل النجاح لخطأ.
      // الحفظ أصلاً نجح، بس إعادة التحميل فشلت.
    }
  }

  // ============================================================
  // ERROR HANDLING
  // ============================================================

  _MarksErrorInfo _extractError(Object error) {
    if (error is DioException) {
      final statusCode = error.response?.statusCode;
      final data = error.response?.data;

      print('❌ Dio Status Code: $statusCode');
      print('❌ Dio Response: $data');

      // Laravel غالباً بيرجع message
      if (data is Map && data['message'] != null) {
        return _MarksErrorInfo(
          statusCode: statusCode,
          message: data['message'].toString(),
        );
      }

      // Validation errors 422
      if (statusCode == 422) {
        if (data is Map && data['errors'] is Map) {
          final errors = data['errors'] as Map;

          final firstError = errors.values.first;

          if (firstError is List && firstError.isNotEmpty) {
            return _MarksErrorInfo(
              statusCode: statusCode,
              message: firstError.first.toString(),
            );
          }
        }

        return const _MarksErrorInfo(
          statusCode: 422,
          message: 'Please check the entered data and try again.',
        );
      }

      switch (statusCode) {
        case 400:
          return const _MarksErrorInfo(
            statusCode: 400,
            message: 'Invalid request.',
          );

        case 401:
          return const _MarksErrorInfo(
            statusCode: 401,
            message: 'Your session has expired. Please login again.',
          );

        case 403:
          return const _MarksErrorInfo(
            statusCode: 403,
            message: 'You do not have permission to perform this action.',
          );

        case 404:
          return const _MarksErrorInfo(
            statusCode: 404,
            message: 'The requested data was not found.',
          );

        case 405:
          return const _MarksErrorInfo(
            statusCode: 405,
            message: 'This action is not allowed.',
          );

        case 409:
          return const _MarksErrorInfo(
            statusCode: 409,
            message: 'This request conflicts with existing data.',
          );

        case 500:
          return const _MarksErrorInfo(
            statusCode: 500,
            message: 'Server error. Please try again later.',
          );

        default:
          return const _MarksErrorInfo(
            message: 'Something went wrong. Please try again.',
          );
      }
    }

    print('❌ UNKNOWN ERROR: $error');

    return const _MarksErrorInfo(
      message: 'Something went wrong. Please try again.',
    );
  }

  // ============================================================
  // CLEAR SESSION
  // ============================================================

  Future<void> _clearSession() async {
    await SharedPrefsHelper.clearToken();
    await SharedPrefsHelper.clearRole();
    await SharedPrefsHelper.clearUserId();
  }
}

// ============================================================
// ERROR MODEL
// ============================================================

class _MarksErrorInfo {
  final int? statusCode;
  final String message;

  const _MarksErrorInfo({
    this.statusCode,
    required this.message,
  });
}
