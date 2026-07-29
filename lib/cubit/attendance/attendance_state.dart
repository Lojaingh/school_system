// lib/cubit/attendance/attendance_state.dart

part of 'attendance_cubit.dart';

abstract class AttendanceState {}

class AttendanceInitial extends AttendanceState {}

class AttendanceLoading extends AttendanceState {}

// ── حالة تحميل الطلاب ──
class AttendanceLoaded extends AttendanceState {
  final ClassStudentsResponse data;
  final int classId;

  AttendanceLoaded(this.data, this.classId);
}

// ── حالة حفظ الحضور ──
class AttendanceSaved extends AttendanceState {
  final String message;

  AttendanceSaved(this.message);
}

// ── حالة الخطأ ──
class AttendanceError extends AttendanceState {
  final String message;

  AttendanceError(this.message);
}
