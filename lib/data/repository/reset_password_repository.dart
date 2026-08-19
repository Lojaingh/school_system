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

      throw Exception(
        e.response?.data?.toString() ?? e.message ?? 'Failed to reset password',
      );
    }
  }
}
