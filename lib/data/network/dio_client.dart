import 'package:dio/dio.dart';
import 'package:school_management/utils/shared_prefs_helper.dart';

class DioClient {
  static final Dio dio = Dio(
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
  static Future<void> init() async {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await SharedPrefsHelper.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          print('🔵 Request: ${options.method} ${options.path}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          print(
              '🟢 Response: ${response.statusCode} ${response.requestOptions.path}');
          return handler.next(response);
        },
        onError: (error, handler) async {
          print('🔴 Error: ${error.message}');
          if (error.response != null) {
            print('🔴 Status: ${error.response?.statusCode}');
            print('🔴 Data: ${error.response?.data}');

            if (error.response?.statusCode == 401) {
              await SharedPrefsHelper.clearToken();
            }
          }
          return handler.next(error);
        },
      ),
    );
  }
}
