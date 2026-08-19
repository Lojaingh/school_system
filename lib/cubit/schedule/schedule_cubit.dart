import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/model/schedule_model.dart';
import '../../data/network/dio_client.dart';

// ==========================================
// States
// ==========================================

abstract class ScheduleState {}

class ScheduleInitial extends ScheduleState {}

class ScheduleLoading extends ScheduleState {}

class ScheduleLoaded extends ScheduleState {
  final List<ScheduleSlot> slots;
  final List<ClassItem> classes;
  final List<SubjectItem> subjects;
  final List<StaffMember> teachers;

  ScheduleLoaded(
    this.slots, [
    this.classes = const [],
    this.subjects = const [],
    this.teachers = const [],
  ]);
}

class ScheduleError extends ScheduleState {
  final String message;
  ScheduleError(this.message);
}

// ==========================================
// Cubit
// ==========================================

class ScheduleCubit extends Cubit<ScheduleState> {
  ScheduleCubit() : super(ScheduleInitial());

  List<ScheduleSlot> _slots = [];
  List<ClassItem> _classes = [];
  List<SubjectItem> _subjects = [];
  List<StaffMember> _allStaff = [];

  List<ScheduleSlot> get slots => _slots;
  List<ClassItem> get classes => _classes;
  List<SubjectItem> get subjects => _subjects;
  List<StaffMember> get teachers =>
      _allStaff.where((s) => s.isTeacher).toList();

  /// حل مؤقت لحد ما نتأكد من مكان subject_id الحقيقي بالـ API (GET /staff/{id}):
  /// بيرجع الأساتذة يلي سبق ودرّسوا هالمادة (حسب الجدول الحالي).
  /// إذا ما في ولا أستاذ درّسها لسا، بيرجع كل الأساتذة (منشان ما نعلّق الإضافة).
  List<StaffMember> teachersForSubject(int? subjectId) {
    final allTeachers = teachers;
    if (subjectId == null) return allTeachers;

    final teacherIdsForSubject = _slots
        .where((s) => s.subjectId == subjectId)
        .map((s) => s.teacherId)
        .toSet();

    if (teacherIdsForSubject.isEmpty) return allTeachers;

    final filtered =
        allTeachers.where((t) => teacherIdsForSubject.contains(t.id)).toList();

    return filtered.isEmpty ? allTeachers : filtered;
  }

  /// يجيب كل شي: الحصص + الصفوف + المواد + الموظفين (تستعمل بصفحة الجدول الكاملة)
  Future<void> loadAll() async {
    try {
      emit(ScheduleLoading());
      final results = await Future.wait([
        DioClient.dio.get('/schedules'),
        DioClient.dio.get('/class/all'),
        DioClient.dio.get('/subjects'),
        DioClient.dio.get('/staff/all'),
      ]);
      _classes = ClassItem.listFromResponse(results[1].data);
      _subjects = SubjectItem.listFromResponse(results[2].data);
      _allStaff = StaffMember.listFromResponse(results[3].data);
      _slots =
          _attachTeacherNames(ScheduleSlot.listFromResponse(results[0].data));
      emit(ScheduleLoaded(_slots, _classes, _subjects, teachers));
    } catch (e) {
      emit(ScheduleError(_errorMessage(e)));
    }
  }

  /// يجيب الحصص + الموظفين بس (تستعمل بالبطاقة المصغّرة بالداشبورد - أخف)
  Future<void> loadSchedulesOnly() async {
    try {
      emit(ScheduleLoading());
      final results = await Future.wait([
        DioClient.dio.get('/schedules'),
        DioClient.dio.get('/staff/all'),
      ]);
      _allStaff = StaffMember.listFromResponse(results[1].data);
      _slots =
          _attachTeacherNames(ScheduleSlot.listFromResponse(results[0].data));
      emit(ScheduleLoaded(_slots, _classes, _subjects, teachers));
    } catch (e) {
      emit(ScheduleError(_errorMessage(e)));
    }
  }

  List<ScheduleSlot> _attachTeacherNames(List<ScheduleSlot> rawSlots) {
    final nameMap = {for (final s in _allStaff) s.id: s.name};
    return rawSlots
        .map((s) => s.withTeacherName(nameMap[s.teacherId]))
        .toList();
  }

  Future<bool> addSchedule({
    required int classId,
    required int subjectId,
    required int teacherId,
    required int academicYearId,
    required int dayOfWeek,
    required int periodNumber,
  }) async {
    try {
      await DioClient.dio.post(
        '/schedules',
        data: FormData.fromMap({
          'class_id': classId.toString(),
          'subject_id': subjectId.toString(),
          'teacher_id': teacherId.toString(),
          'academic_year_id': academicYearId.toString(),
          'day_of_week': dayOfWeek.toString(),
          'period_number': periodNumber.toString(),
        }),
      );
      await loadSchedulesOnly();
      return true;
    } catch (e) {
      emit(ScheduleError(_errorMessage(e)));
      return false;
    }
  }

  Future<bool> updateSchedule({
    required int id,
    int? dayOfWeek,
    int? periodNumber,
    int? subjectId,
    int? teacherId,
  }) async {
    try {
      final map = <String, String>{};
      if (dayOfWeek != null) map['day_of_week'] = dayOfWeek.toString();
      if (periodNumber != null) map['period_number'] = periodNumber.toString();
      if (subjectId != null) map['subject_id'] = subjectId.toString();
      if (teacherId != null) map['teacher_id'] = teacherId.toString();

      await DioClient.dio.put(
        '/schedules/$id',
        data: FormData.fromMap(map),
      );
      await loadSchedulesOnly();
      return true;
    } catch (e) {
      emit(ScheduleError(_errorMessage(e)));
      return false;
    }
  }

  Future<bool> deleteSchedule(int id) async {
    try {
      await DioClient.dio.delete('/schedules/$id');
      await loadSchedulesOnly();
      return true;
    } catch (e) {
      emit(ScheduleError(_errorMessage(e)));
      return false;
    }
  }

  String _errorMessage(Object e) {
    if (e is DioException) {
      final data = e.response?.data;
      if (data is Map && data['message'] != null) {
        return data['message'].toString();
      }
      return e.message ?? 'Connection error';
    }
    return e.toString();
  }
}
