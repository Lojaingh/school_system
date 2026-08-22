import 'package:dio/dio.dart';

import '../services/reset_password_service.dart';

class ResetPasswordRepository {
  final ResetPasswordService service;

  ResetPasswordRepository(this.service);

  Future<String> resetPassword({
    required int userId,
    required String newPassword,
    required String confirmation,
  }) async {
    try {
      final response = await service.resetPassword(
        userId: userId,
        newPassword: newPassword,
        confirmation: confirmation,
      );

      print('RESET PASSWORD STATUS: ${response.statusCode}');
      print('RESET PASSWORD DATA: ${response.data}');

      return response.data['message'] ?? 'Password updated successfully';
    } on DioException catch (e) {
      print('RESET PASSWORD ERROR: ${e.response?.data}');

      final data = e.response?.data;

      if (data is Map) {
        // Laravel validation errors
        if (data['errors'] != null && data['errors'] is Map) {
          final errors = data['errors'] as Map;

          final firstError = errors.values.first;

          if (firstError is List && firstError.isNotEmpty) {
            throw Exception(firstError.first.toString());
          }
        }

        // Laravel message
        if (data['message'] != null) {
          throw Exception(
            data['message'].toString(),
          );
        }
      }

      throw Exception(
        e.message ?? 'Failed to reset password',
      );
    }
  }
}
