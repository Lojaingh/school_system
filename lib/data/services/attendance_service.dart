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

  // ── تسجيل الحضور للطلاب (بدون تغيير — مطابق للـ API الحالي) ──
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

  Future<Response> getClassAttendances({
    required int schoolClassId,
    required String date, // بصيغة yyyy-MM-dd
  }) async {
    try {
      print('🔵 Fetching class attendance: class=$schoolClassId, date=$date');
      final response = await _dio.get(
        '/class/attendance',
        queryParameters: {
          'school_class_id': schoolClassId,
          'date': date,
        },
      );
      print('🟢 Class attendance response status: ${response.statusCode}');
      return response;
    } catch (e) {
      print('🔴 Error in getClassAttendances: $e');
      rethrow;
    }
  }

  Future<Response> markSingleStaffAttendance({
    required int userId,
    required String status, // present / absent / late / excused (حروف صغيرة)
  }) async {
    try {
      print('🔵 Marking staff attendance: user=$userId, status=$status');
      final response = await _dio.post(
        '/staff/attendance',
        data: FormData.fromMap({
          'user_id': userId,
          'status': status,
        }),
      );
      print('🟢 Staff attendance response status: ${response.statusCode}');
      return response;
    } catch (e) {
      print('🔴 Error in markSingleStaffAttendance (user=$userId): $e');
      rethrow;
    }
  }

  Future<void> markStaffAttendanceBulk(Map<int, String> statuses) async {
    final failures = <String>[];

    for (final entry in statuses.entries) {
      try {
        await markSingleStaffAttendance(
          userId: entry.key,
          status: entry.value,
        );
      } catch (e) {
        failures.add('user ${entry.key}: $e');
      }
    }

    if (failures.isNotEmpty) {
      throw Exception('Failed to mark attendance for: ${failures.join(' | ')}');
    }
  }

  Future<Response> getStaffAttendanceByDate(String date) async {
    try {
      print('🔵 Fetching staff attendance for date: $date');
      final response = await _dio.get(
        '/staff/attendance',
        queryParameters: {'date': date},
      );
      print(
          '🟢 Staff attendance by date response status: ${response.statusCode}');
      return response;
    } catch (e) {
      print('🔴 Error in getStaffAttendanceByDate: $e');
      rethrow;
    }
  }

  Future<Response> getStaff() async {
    try {
      print('🔵 Fetching staff from: /staff/all');
      final response = await _dio.get('/staff/all');
      print('🟢 Staff response status: ${response.statusCode}');
      return response;
    } catch (e) {
      print('🔴 Error in getStaff: $e');
      rethrow;
    }
  }
}
