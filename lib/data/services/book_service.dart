import 'package:dio/dio.dart';
import '../network/dio_client.dart';

class BookService {
  final Dio _dio = DioClient.dio;

  Future<Response> getBooks() async {
    try {
      print('🔵 GET /books');

      final response = await _dio.get('/books');

      print('🟢 Books status: ${response.statusCode}');
      return response;
    } on DioException catch (e) {
      print('🔴 Error GET /books: ${e.response?.data ?? e.message}');
      rethrow;
    }
  }

  Future<Response> getBook(int id) async {
    try {
      print('🔵 GET /books/$id');

      final response = await _dio.get('/books/$id');

      print('🟢 Book status: ${response.statusCode}');
      return response;
    } on DioException catch (e) {
      print('🔴 Error GET /books/$id: ${e.response?.data ?? e.message}');
      rethrow;
    }
  }

  Future<Response> addBook({
    required String title,
    required String summary,
    required String category,
    required int pages,
  }) async {
    try {
      print('🔵 POST /books');

      final response = await _dio.post(
        '/books',
        data: {
          'title': title,
          'summary': summary,
          'category': category,
          'pages': pages,
        },
      );

      print('🟢 Add book status: ${response.statusCode}');
      return response;
    } on DioException catch (e) {
      print('🔴 Error POST /books: ${e.response?.data ?? e.message}');
      rethrow;
    }
  }

  Future<Response> updateBook({
    required int id,
    String? title,
    String? summary,
    String? category,
    int? pages,
  }) async {
    try {
      print('🔵 PUT /books/$id');

      final Map<String, dynamic> data = {};

      if (title != null) {
        data['title'] = title;
      }

      if (summary != null) {
        data['summary'] = summary;
      }

      if (category != null) {
        data['category'] = category;
      }

      if (pages != null) {
        data['pages'] = pages;
      }

      final response = await _dio.put(
        '/books/$id',
        data: data,
      );

      print('🟢 Update book status: ${response.statusCode}');
      return response;
    } on DioException catch (e) {
      print('🔴 Error PUT /books/$id: ${e.response?.data ?? e.message}');
      rethrow;
    }
  }

  Future<Response> deleteBook(int id) async {
    try {
      print('🔵 DELETE /books/$id');

      final response = await _dio.delete('/books/$id');

      print('🟢 Delete book status: ${response.statusCode}');
      return response;
    } on DioException catch (e) {
      print('🔴 Error DELETE /books/$id: ${e.response?.data ?? e.message}');
      rethrow;
    }
  }

  Future<Response> lendBook(int bookId) async {
    try {
      print('🔵 POST /books/$bookId/lend');

      final response = await _dio.post(
        '/books/$bookId/lend',
      );

      print('🟢 Lend book status: ${response.statusCode}');
      return response;
    } on DioException catch (e) {
      print(
        '🔴 Error POST /books/$bookId/lend: '
        '${e.response?.data ?? e.message}',
      );
      rethrow;
    }
  }

  Future<Response> returnBook(int lendingId) async {
    try {
      print('🔵 PUT /lendings/$lendingId/return');

      final response = await _dio.put(
        '/lendings/$lendingId/return',
      );

      print('🟢 Return book status: ${response.statusCode}');
      return response;
    } on DioException catch (e) {
      print(
        '🔴 Error PUT /lendings/$lendingId/return: '
        '${e.response?.data ?? e.message}',
      );
      rethrow;
    }
  }

  Future<Response> getLendings() async {
    try {
      print('🔵 GET /lendings');

      final response = await _dio.get('/lendings');

      print('🟢 Lendings status: ${response.statusCode}');
      return response;
    } on DioException catch (e) {
      print('🔴 Error GET /lendings: ${e.response?.data ?? e.message}');
      rethrow;
    }
  }

  Future<Response> getMyLendings() async {
    try {
      print('🔵 GET /my/lendings');

      final response = await _dio.get('/my/lendings');

      print('🟢 My lendings status: ${response.statusCode}');
      return response;
    } on DioException catch (e) {
      print(
        '🔴 Error GET /my/lendings: '
        '${e.response?.data ?? e.message}',
      );
      rethrow;
    }
  }
}
