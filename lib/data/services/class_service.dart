// lib/data/services/class_service.dart

import 'package:dio/dio.dart';
import '../network/dio_client.dart';

class ClassService {
  final Dio _dio = DioClient.dio;

  // ── جلب جميع الصفوف ──
  Future<Response> getClasses() async {
    try {
      print('🔵 Fetching classes from: /class/all');
      final response = await _dio.get('/class/all');
      print('🟢 Classes response status: ${response.statusCode}');
      return response;
    } catch (e) {
      print('🔴 Error in getClasses: $e');
      rethrow;
    }
  }

  // ── جلب الصفوف حسب السنة ──
  Future<Response> getClassesByGrade(int year) async {
    try {
      print('🔵 Fetching classes by grade: $year');
      final response = await _dio.get(
        '/class/grade',
        queryParameters: {
          'year': year,
        },
      );
      print('🟢 Classes by grade response status: ${response.statusCode}');
      return response;
    } catch (e) {
      print('🔴 Error in getClassesByGrade: $e');
      rethrow;
    }
  }

  // ── ✅ جلب طلاب شعبة معينة (API جديد) ──
  Future<Response> getClassStudents(int classId) async {
    try {
      print('🔵 Fetching students for class: $classId');
      final response = await _dio.get(
        '/class',
        queryParameters: {'class_id': classId},
      );
      print('🟢 Class students response status: ${response.statusCode}');
      print('📦 Class students data: ${response.data}');
      return response;
    } catch (e) {
      print('🔴 Error in getClassStudents: $e');
      rethrow;
    }
  }

  // ── جلب الطلاب حسب السنة ──
  Future<Response> getStudentsByGrade(int year) async {
    try {
      print('🔵 Fetching students by grade: $year');
      final response = await _dio.get(
        '/student/grade',
        queryParameters: {
          'year': year,
        },
      );
      print('🟢 Students by grade response status: ${response.statusCode}');
      print('📦 Students response data: ${response.data}');
      return response;
    } catch (e) {
      print('🔴 Error in getStudentsByGrade: $e');
      rethrow;
    }
  }

  Future<Response> getStudentsByClass(int classId) async {
    try {
      print('🔵 Fetching students for class: $classId');
      final response = await _dio.get(
        '/students/all',
        queryParameters: {
          'class_id': classId,
        },
      );
      return response;
    } catch (e) {
      print('🔴 Error in getStudentsByClass: $e');
      rethrow;
    }
  }

  // ── إضافة صف جديد ──
  Future<Response> addClass({
    required int year,
    required int number,
    int? supervisorId,
  }) async {
    try {
      print('🔵 Adding class: year=$year, number=$number');
      final response = await _dio.post(
        '/add/class',
        data: {
          'year': year,
          'number': number,
          if (supervisorId != null) 'supervisor_id': supervisorId,
        },
      );
      print('🟢 Add class response status: ${response.statusCode}');
      return response;
    } catch (e) {
      print('🔴 Error in addClass: $e');
      rethrow;
    }
  }

  // ── حذف صف ──
  Future<Response> deleteClass(int id) async {
    try {
      print('🔵 Deleting class: $id');
      final response = await _dio.delete('/class/$id');
      print('🟢 Delete class response status: ${response.statusCode}');
      return response;
    } catch (e) {
      print('🔴 Error in deleteClass: $e');
      rethrow;
    }
  }

  // ── نقل طالب ──
  Future<Response> moveStudent({
    required int userId,
    required int classId,
  }) async {
    try {
      print('🔵 Moving student: user=$userId to class=$classId');
      final response = await _dio.post(
        '/student/move',
        data: {
          'user_id': userId,
          'class_id': classId,
        },
      );
      print('🟢 Move student response status: ${response.statusCode}');
      return response;
    } catch (e) {
      print('🔴 Error in moveStudent: $e');
      rethrow;
    }
  }

  // ── توزيع الطلاب ──
  Future<Response> distributeStudents(int capacity) async {
    try {
      print('🔵 Distributing students with capacity: $capacity');
      final response = await _dio.post(
        '/students/distribute',
        data: {
          'capacity': capacity,
        },
      );
      print('🟢 Distribute students response status: ${response.statusCode}');
      return response;
    } catch (e) {
      print('🔴 Error in distributeStudents: $e');
      rethrow;
    }
  }

  // ── جلب كل الطلاب ──
  Future<Response> getAllStudents() async {
    try {
      print('🔵 Fetching all students from: /students/all');
      final response = await _dio.get('/students/all');
      print('🟢 All students response status: ${response.statusCode}');
      return response;
    } catch (e) {
      print('🔴 Error in getAllStudents: $e');
      rethrow;
    }
  }

  // ── جلب تفاصيل طالب واحد ──
  Future<Response> getStudentById(int id) async {
    try {
      final response = await _dio.get('/student/$id');
      return response;
    } catch (e) {
      print('🔴 Error in getStudentById($id): $e');
      rethrow;
    }
  }
}
