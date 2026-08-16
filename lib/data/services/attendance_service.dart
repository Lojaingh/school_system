// lib/data/services/attendance_service.dart

import 'package:dio/dio.dart';
import '../network/dio_client.dart';

class AttendanceService {
  final Dio _dio = DioClient.dio;

  // ── جلب طلاب صف معين ──
  Future<Response> getClassStudents(int classId) async {
    try {
      print('🔵 Fetching students for class: $classId');
      final response = await _dio.get(
        '/class',
        queryParameters: {'class_id': classId},
      );
      print('🟢 Class students response status: ${response.statusCode}');
      return response;
    } catch (e) {
      print('🔴 Error in getClassStudents: $e');
      rethrow;
    }
  }

  // ── تسجيل الحضور للطلاب ──
  Future<Response> markAttendance({
    required int classId,
    required List<int> absent,
    required List<int> late,
    required List<int> excused,
  }) async {
    try {
      print('🔵 Marking attendance for class: $classId');
      print('   Absent: $absent, Late: $late, Excused: $excused');

      final response = await _dio.post(
        '/classes/$classId/attendance',
        data: {
          'absent': absent,
          'late': late,
          'excused': excused,
        },
      );
      print('🟢 Attendance response status: ${response.statusCode}');
      return response;
    } catch (e) {
      print('🔴 Error in markAttendance: $e');
      rethrow;
    }
  }
}
