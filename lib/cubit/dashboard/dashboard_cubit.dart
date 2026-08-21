import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/model/dashboard_model.dart';
import '../../data/network/dio_client.dart';

abstract class DashboardState {}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final DashboardApiStats stats;
  final WeeklyAttendanceResponse? weeklyAttendance;

  DashboardLoaded(this.stats, [this.weeklyAttendance]);
}

class DashboardError extends DashboardState {
  final String message;
  DashboardError(this.message);
}

class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit() : super(DashboardInitial());

  Future<void> loadStats() async {
    try {
      emit(DashboardLoading());

      final results = await Future.wait([
        DioClient.dio.get('/staff/numbers'),
        DioClient.dio.get('/students/number'),
        DioClient.dio.get('/attendance/weekly'),
      ]);

      final staffStats = StaffStats.fromJson(results[0].data);
      final studentStats = StudentStats.fromJson(results[1].data);

      final dashboardStats = DashboardApiStats(
        students: studentStats.total,
        teachers: staffStats.teachers,
        employees: staffStats.staffWithoutTeachers,
        books: 0,
      );

      WeeklyAttendanceResponse? weeklyAttendance;
      try {
        weeklyAttendance = WeeklyAttendanceResponse.fromJson(results[2].data);
      } catch (e) {
        weeklyAttendance = null;
      }

      emit(DashboardLoaded(dashboardStats, weeklyAttendance));
    } catch (e) {
      emit(DashboardError(e.toString()));
    }
  }

  void refreshStats() {
    loadStats();
  }
}
