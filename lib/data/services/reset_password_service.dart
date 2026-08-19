import 'package:dio/dio.dart';
import '../network/dio_client.dart';

class ResetPasswordService {
  final Dio dio = DioClient.dio;

  Future<Response> resetPassword({
    required int userId,
    required String newPassword,
    required String confirmation,
  }) async {
    return await dio.patch(
      '/update/$userId/password',
      data: {
        'new_password': newPassword,
        'new_password_confirmation': confirmation,
      },
    );
  }
}
