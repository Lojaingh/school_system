// lib/cubit/attendance/attendance_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/model/class_students_model.dart';
import '../../data/services/attendance_service.dart';

part 'attendance_state.dart';

class AttendanceCubit extends Cubit<AttendanceState> {
  final AttendanceService service;

  AttendanceCubit(this.service) : super(AttendanceInitial());

  // ── جلب طلاب الصف ──
  Future<void> loadClassStudents(int classId) async {
    try {
      emit(AttendanceLoading());
      final response = await service.getClassStudents(classId);

      if (response.statusCode == 200) {
        final data = ClassStudentsResponse.fromJson(response.data);
        emit(AttendanceLoaded(data, classId));
      } else {
        emit(
            AttendanceError('Failed to load students: ${response.statusCode}'));
      }
    } catch (e) {
      emit(AttendanceError(e.toString()));
    }
  }

  // ── تسجيل الحضور ──
  Future<void> markAttendance({
    required int classId,
    required List<int> absent,
    required List<int> late,
    required List<int> excused,
  }) async {
    try {
      emit(AttendanceLoading());
      print('📤 Sending attendance:');
      print('   classId: $classId');
      print('   absent: $absent');
      print('   late: $late');
      print('   excused: $excused');

      final response = await service.markAttendance(
        classId: classId,
        absent: absent,
        late: late,
        excused: excused,
      );

      if (response.statusCode == 200) {
        final message =
            response.data['message'] ?? 'Attendance saved successfully';
        emit(AttendanceSaved(message));
        // إعادة تحميل البيانات بعد الحفظ
        await loadClassStudents(classId);
      } else {
        emit(AttendanceError(
            'Failed to save attendance: ${response.statusCode}'));
      }
    } catch (e) {
      emit(AttendanceError(e.toString()));
    }
  }

  void resetState() {
    emit(AttendanceInitial());
  }
}
