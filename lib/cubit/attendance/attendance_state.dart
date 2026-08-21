part of 'attendance_cubit.dart';

abstract class AttendanceState {}

class AttendanceInitial extends AttendanceState {}

class AttendanceLoading extends AttendanceState {}

class AttendanceLoaded extends AttendanceState {
  final ClassStudentsResponse data;
  final int classId;

  AttendanceLoaded(this.data, this.classId);
}

class AttendanceSaved extends AttendanceState {
  final String message;

  AttendanceSaved(this.message);
}

class AttendanceError extends AttendanceState {
  final String message;

  AttendanceError(this.message);
}
