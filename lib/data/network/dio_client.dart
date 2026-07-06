import 'package:dio/dio.dart';
import 'package:school_management/utils/shared_prefs_helper.dart';

class DioClient {
  static late Dio dio;

  static Future<void> init() async {
    dio = Dio(
      BaseOptions(
        baseUrl: 'http://127.0.0.1:8000/api/v1',
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await SharedPrefsHelper.getToken();

          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          handler.next(options);
        },
        onError: (error, handler) {
          if (error.response?.statusCode == 401) {
            SharedPrefsHelper.clearToken();
          }

          handler.next(error);
        },
      ),
    );
  }
}
