import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/model/schedule_model.dart';
import '../../data/network/dio_client.dart';
import '../../utils/shared_prefs_helper.dart';

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

  List<StaffMember> teachersForSubject(int? subjectId) {
    final allTeachers = teachers;

    if (subjectId == null) {
      return allTeachers;
    }

    final teacherIdsForSubject = _slots
        .where((s) => s.subjectId == subjectId)
        .map((s) => s.teacherId)
        .toSet();

    if (teacherIdsForSubject.isEmpty) {
      return allTeachers;
    }

    final filtered =
        allTeachers.where((t) => teacherIdsForSubject.contains(t.id)).toList();

    return filtered.isEmpty ? allTeachers : filtered;
  }

  Future<void> loadAll() async {
    if (isClosed) return;

    try {
      emit(ScheduleLoading());

      final role = await SharedPrefsHelper.getRole();

      if (isClosed) return;

      final normalizedRole = role?.trim().toLowerCase() ?? '';

      late final Response schedulesResponse;
      late final Response classesResponse;
      late final Response subjectsResponse;
      Response? staffResponse;

      schedulesResponse = await DioClient.dio.get('/schedules');

      if (isClosed) return;

      if (normalizedRole == 'supervisor') {
        classesResponse = await DioClient.dio.get('/supervisor/classes');
      } else {
        classesResponse = await DioClient.dio.get('/class/all');
      }

      if (isClosed) return;

      subjectsResponse = await DioClient.dio.get('/subjects');

      if (isClosed) return;
      if (normalizedRole == 'manager') {
        staffResponse = await DioClient.dio.get('/staff/all');
      }

      if (isClosed) return;

      _classes = ClassItem.listFromResponse(
        classesResponse.data,
      );

      _subjects = SubjectItem.listFromResponse(
        subjectsResponse.data,
      );

      if (staffResponse != null) {
        _allStaff = StaffMember.listFromResponse(
          staffResponse.data,
        );
      } else {
        _allStaff = List<StaffMember>.from(
          _allStaff,
        );
      }

      _slots = _attachTeacherNames(
        ScheduleSlot.listFromResponse(
          schedulesResponse.data,
        ),
      );

      if (isClosed) return;

      emit(
        ScheduleLoaded(
          _slots,
          _classes,
          _subjects,
          teachers,
        ),
      );
    } catch (e) {
      if (isClosed) return;

      emit(
        ScheduleError(
          _errorMessage(e),
        ),
      );
    }
  }

  Future<void> loadSchedulesOnly() async {
    if (isClosed) return;

    try {
      emit(ScheduleLoading());

      final role = await SharedPrefsHelper.getRole();

      if (isClosed) return;

      final normalizedRole = role?.trim().toLowerCase() ?? '';

      final schedulesResponse = await DioClient.dio.get('/schedules');

      if (isClosed) return;
      if (normalizedRole == 'manager') {
        final staffResponse = await DioClient.dio.get('/staff/all');

        if (isClosed) return;

        _allStaff = StaffMember.listFromResponse(
          staffResponse.data,
        );
      }

      _slots = _attachTeacherNames(
        ScheduleSlot.listFromResponse(
          schedulesResponse.data,
        ),
      );

      if (isClosed) return;

      emit(
        ScheduleLoaded(
          _slots,
          _classes,
          _subjects,
          teachers,
        ),
      );
    } catch (e) {
      if (isClosed) return;

      emit(
        ScheduleError(
          _errorMessage(e),
        ),
      );
    }
  }

  List<ScheduleSlot> _attachTeacherNames(
    List<ScheduleSlot> rawSlots,
  ) {
    final nameMap = {
      for (final s in _allStaff) s.id: s.name,
    };

    return rawSlots
        .map(
          (s) => s.withTeacherName(
            nameMap[s.teacherId],
          ),
        )
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
    if (isClosed) return false;

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

      if (isClosed) return false;

      await loadSchedulesOnly();

      return !isClosed;
    } catch (e) {
      if (isClosed) return false;

      emit(
        ScheduleError(
          _errorMessage(e),
        ),
      );

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
    if (isClosed) return false;

    try {
      final map = <String, String>{};

      if (dayOfWeek != null) {
        map['day_of_week'] = dayOfWeek.toString();
      }

      if (periodNumber != null) {
        map['period_number'] = periodNumber.toString();
      }

      if (subjectId != null) {
        map['subject_id'] = subjectId.toString();
      }

      if (teacherId != null) {
        map['teacher_id'] = teacherId.toString();
      }

      await DioClient.dio.put(
        '/schedules/$id',
        data: FormData.fromMap(map),
      );

      if (isClosed) return false;

      await loadSchedulesOnly();

      return !isClosed;
    } catch (e) {
      if (isClosed) return false;

      emit(
        ScheduleError(
          _errorMessage(e),
        ),
      );

      return false;
    }
  }

  Future<bool> deleteSchedule(int id) async {
    if (isClosed) return false;

    try {
      await DioClient.dio.delete(
        '/schedules/$id',
      );

      if (isClosed) return false;

      await loadSchedulesOnly();

      return !isClosed;
    } catch (e) {
      if (isClosed) return false;

      emit(
        ScheduleError(
          _errorMessage(e),
        ),
      );

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
