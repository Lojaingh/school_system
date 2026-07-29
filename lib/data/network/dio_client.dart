import 'package:dio/dio.dart';
import 'package:school_management/utils/shared_prefs_helper.dart';

class DioClient {
  // تعريف الـ Dio كـ static ليكون متاحاً في جميع أنحاء التطبيق
  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: 'http://127.0.0.1:8000/api/v1',
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        // تم إزالة التوكن الثابت من هنا
      },
    ),
  );

  // دالة التهيئة (تضيف الـ interceptors)
  static Future<void> init() async {
    dio.interceptors.add(
      InterceptorsWrapper(
        // 1. عند إرسال الطلب (نضيف التوكن هنا تلقائياً)
        onRequest: (options, handler) async {
          final token = await SharedPrefsHelper.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          print('🔵 Request: ${options.method} ${options.path}');
          return handler.next(options);
        },

        // 2. عند استلام الرد
        onResponse: (response, handler) {
          print(
              '🟢 Response: ${response.statusCode} ${response.requestOptions.path}');
          return handler.next(response);
        },

        // 3. عند حدوث خطأ
        onError: (error, handler) async {
          print('🔴 Error: ${error.message}');
          if (error.response != null) {
            print('🔴 Status: ${error.response?.statusCode}');
            print('🔴 Data: ${error.response?.data}');

            // إذا كان الخطأ 401 (غير مصرح)، نقوم بمسح التوكن
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
