import 'package:dio/dio.dart';

import '../network/dio_client.dart';

class ClassService {
  final Dio _dio = DioClient.dio;

  // ============================================================
  // GET ALL CLASSES
  // ============================================================

  Future<Response> getClasses() async {
    try {
      print('🔵 Fetching classes from: /class/all');

      final response = await _dio.get('/class/all');

      print(
        '🟢 Classes response status: ${response.statusCode}',
      );
      print('📦 Classes data: ${response.data}');

      return response;
    } catch (e) {
      print('🔴 Error in getClasses: $e');
      rethrow;
    }
  }

  // ============================================================
  // GET CLASSES BY GRADE
  // ============================================================

  Future<Response> getClassesByGrade(int year) async {
    try {
      print('🔵 Fetching classes by grade: $year');

      final response = await _dio.get(
        '/class/grade',
        queryParameters: {
          'year': year,
        },
      );

      print(
        '🟢 Classes by grade response status: '
        '${response.statusCode}',
      );

      print('📦 Classes by grade data: ${response.data}');

      return response;
    } catch (e) {
      print('🔴 Error in getClassesByGrade: $e');
      rethrow;
    }
  }

  // ============================================================
  // GET STUDENTS OF CLASS
  // ============================================================

  Future<Response> getClassStudents(int classId) async {
    try {
      print(
        '🔵 Fetching students for class: $classId',
      );

      final response = await _dio.get(
        '/class',
        queryParameters: {
          'class_id': classId,
        },
      );

      print(
        '🟢 Class students response status: '
        '${response.statusCode}',
      );

      print(
        '📦 Class students data: ${response.data}',
      );

      return response;
    } catch (e) {
      print('🔴 Error in getClassStudents: $e');
      rethrow;
    }
  }

  // ============================================================
  // GET STUDENTS BY GRADE
  // ============================================================

  Future<Response> getStudentsByGrade(int year) async {
    try {
      print(
        '🔵 Fetching students by grade: $year',
      );

      final response = await _dio.get(
        '/student/grade',
        queryParameters: {
          'year': year,
        },
      );

      print(
        '🟢 Students by grade response status: '
        '${response.statusCode}',
      );

      print(
        '📦 Students response data: ${response.data}',
      );

      return response;
    } catch (e) {
      print('🔴 Error in getStudentsByGrade: $e');
      rethrow;
    }
  }

  // ============================================================
  // GET STUDENTS BY CLASS
  // ============================================================

  Future<Response> getStudentsByClass(int classId) async {
    try {
      print(
        '🔵 Fetching students for class: $classId',
      );

      final response = await _dio.get(
        '/students/all',
        queryParameters: {
          'class_id': classId,
        },
      );

      print(
        '🟢 Students by class response status: '
        '${response.statusCode}',
      );

      print(
        '📦 Students by class data: ${response.data}',
      );

      return response;
    } catch (e) {
      print('🔴 Error in getStudentsByClass: $e');
      rethrow;
    }
  }

  // ============================================================
  // ADD CLASS
  // ============================================================

  Future<Response> addClass({
    required int year,
    required int number,
    int? supervisorId,
  }) async {
    try {
      print(
        '🔵 Adding class: '
        'year=$year, '
        'number=$number, '
        'supervisorId=$supervisorId',
      );

      final response = await _dio.post(
        '/add/class',
        data: {
          'year': year,
          'number': number,
          if (supervisorId != null) 'supervisor_id': supervisorId,
        },
      );

      print(
        '🟢 Add class response status: '
        '${response.statusCode}',
      );

      print(
        '📦 Add class response: '
        '${response.data}',
      );

      return response;
    } catch (e) {
      print('🔴 Error in addClass: $e');
      rethrow;
    }
  }

  // ============================================================
  // DELETE CLASS
  // ============================================================

  Future<Response> deleteClass(int id) async {
    try {
      print('🔵 Deleting class: $id');

      final response = await _dio.delete(
        '/class/$id',
      );

      print(
        '🟢 Delete class response status: '
        '${response.statusCode}',
      );

      print(
        '📦 Delete class response: '
        '${response.data}',
      );

      return response;
    } catch (e) {
      print('🔴 Error in deleteClass: $e');
      rethrow;
    }
  }

  // ============================================================
  // MOVE STUDENT
  // ============================================================

  Future<Response> moveStudent({
    required int userId,
    required int classId,
  }) async {
    try {
      print(
        '🔵 Moving student: '
        'user=$userId to class=$classId',
      );

      final response = await _dio.post(
        '/student/move',
        data: {
          'user_id': userId,
          'class_id': classId,
        },
      );

      print(
        '🟢 Move student response status: '
        '${response.statusCode}',
      );

      print(
        '📦 Move student response: '
        '${response.data}',
      );

      return response;
    } catch (e) {
      print('🔴 Error in moveStudent: $e');
      rethrow;
    }
  }

  // ============================================================
  // DISTRIBUTE STUDENTS
  // ============================================================

  Future<Response> distributeStudents(int capacity) async {
    try {
      print(
        '🔵 Distributing students '
        'with capacity: $capacity',
      );

      final response = await _dio.post(
        '/students/distribute',
        data: {
          'capacity': capacity,
        },
      );

      print(
        '🟢 Distribute students response status: '
        '${response.statusCode}',
      );

      print(
        '📦 Distribute students response: '
        '${response.data}',
      );

      return response;
    } catch (e) {
      print('🔴 Error in distributeStudents: $e');
      rethrow;
    }
  }

  // ============================================================
  // GET SUPERVISORS
  // ============================================================

  Future<Response> getSupervisors() async {
    try {
      print(
        '🔵 Fetching supervisors from /staff/all',
      );

      final response = await _dio.get(
        '/staff/all',
        queryParameters: {
          'role_id': 3,
        },
      );

      print(
        '🟢 Supervisors response status: '
        '${response.statusCode}',
      );

      print(
        '📦 Supervisors response data: '
        '${response.data}',
      );

      return response;
    } catch (e) {
      print(
        '🔴 Error fetching supervisors: $e',
      );

      rethrow;
    }
  }

  // ============================================================
  // UPDATE CLASS SUPERVISOR
  // ============================================================
  //
  // PATCH /class/{classId}/supervisor
  //
  // supervisor_id:
  // - int  -> assign supervisor
  // - null -> remove supervisor
  //
  // ============================================================

  Future<Response> updateClassSupervisor({
    required int classId,
    required int? supervisorId,
  }) async {
    try {
      print(
        '🔵 Updating supervisor for class '
        '$classId -> $supervisorId',
      );

      final Map<String, dynamic> data = {};

      if (supervisorId != null) {
        data['supervisor_id'] = supervisorId;
      } else {
        data['supervisor_id'] = null;
      }

      final response = await _dio.patch(
        '/class/$classId/supervisor',
        data: data,
      );

      print(
        '🟢 Update supervisor response status: '
        '${response.statusCode}',
      );

      print(
        '📦 Update supervisor response: '
        '${response.data}',
      );

      return response;
    } catch (e) {
      print(
        '🔴 Error updating class supervisor: $e',
      );

      rethrow;
    }
  }

  // ============================================================
  // ASSIGN SUPERVISOR
  // ============================================================
  //
  // Kept for compatibility with existing code.
  //
  // ============================================================

  Future<Response> assignSupervisor({
    required int classId,
    required int supervisorId,
  }) async {
    return updateClassSupervisor(
      classId: classId,
      supervisorId: supervisorId,
    );
  }

  // ============================================================
  // GET ALL STUDENTS
  // ============================================================

  Future<Response> getAllStudents() async {
    try {
      print(
        '🔵 Fetching all students '
        'from /students/all',
      );

      final response = await _dio.get(
        '/students/all',
      );

      print(
        '🟢 All students response status: '
        '${response.statusCode}',
      );

      print(
        '📦 All students response data: '
        '${response.data}',
      );

      return response;
    } catch (e) {
      print('🔴 Error in getAllStudents: $e');
      rethrow;
    }
  }

  // ============================================================
  // GET STUDENT BY ID
  // ============================================================

  Future<Response> getStudentById(int id) async {
    try {
      print(
        '🔵 Fetching student details: $id',
      );

      final response = await _dio.get(
        '/student/$id',
      );

      print(
        '🟢 Student details response status: '
        '${response.statusCode}',
      );

      print(
        '📦 Student details response data: '
        '${response.data}',
      );

      return response;
    } catch (e) {
      print(
        '🔴 Error in getStudentById($id): $e',
      );

      rethrow;
    }
  }
}
