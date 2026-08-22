import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';

import 'package:school_management/data/model/student_profile_model.dart';
import '../../data/model/class_model.dart';
import '../../data/repository/class_repository.dart';

part 'class_state.dart';

class ClassCubit extends Cubit<ClassState> {
  final ClassRepository repository;

  ClassCubit(this.repository) : super(ClassInitial());

  Future<void> loadClasses() async {
    try {
      emit(ClassLoading());

      final classes = await repository.getClasses();

      emit(ClassLoaded(classes));
    } catch (e) {
      print('❌ ClassCubit Error: $e');

      emit(
        ClassError(
          _cleanErrorMessage(e),
        ),
      );
    }
  }

  Future<void> loadClassesByGrade(int year) async {
    try {
      emit(ClassLoading());

      final classes = await repository.getClassesByGrade(year);

      emit(ClassLoaded(classes));
    } catch (e) {
      print('❌ ClassCubit Error: $e');

      emit(
        ClassError(
          _cleanErrorMessage(e),
        ),
      );
    }
  }

  Future<void> addClass({
    required int year,
    required int number,
    int? supervisorId,
  }) async {
    try {
      emit(ClassLoading());

      await repository.addClass(
        year: year,
        number: number,
        supervisorId: supervisorId,
      );

      await loadClasses();
    } catch (e) {
      print('❌ Add class error: $e');

      emit(
        ClassError(
          _cleanErrorMessage(e),
        ),
      );
    }
  }

  Future<void> deleteClass(int id) async {
    try {
      emit(ClassLoading());

      await repository.deleteClass(id);

      await loadClasses();
    } catch (e) {
      print('❌ Delete class error: $e');

      emit(
        ClassError(
          _cleanErrorMessage(e),
        ),
      );
    }
  }

  Future<void> moveStudent({
    required int userId,
    required int classId,
  }) async {
    try {
      await repository.moveStudent(
        userId: userId,
        classId: classId,
      );

      await loadClasses();
    } catch (e) {
      print('❌ Move student error: $e');

      emit(
        ClassError(
          _cleanErrorMessage(e),
        ),
      );
    }
  }

  Future<bool> distributeStudents(int capacity) async {
    try {
      await repository.distributeStudents(capacity);
      await loadClasses();
      return true;
    } catch (e) {
      print('❌ ClassCubit Error distributing students: $e');

      if (e is DioException && e.response?.statusCode == 409) {
        emit(
          ClassDistributionError('Students are already distributed.'),
        );
        return false;
      }

      emit(
        ClassDistributionError(
          _cleanErrorMessage(e),
        ),
      );

      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getSupervisors() async {
    try {
      final supervisors = await repository.getSupervisors();

      return supervisors;
    } catch (e) {
      print(
        '❌ Supervisors error: $e',
      );

      return [];
    }
  }

  Future<void> updateClassSupervisor({
    required int classId,
    required int? supervisorId,
  }) async {
    try {
      print(
        '🔵 Updating supervisor $supervisorId for class $classId',
      );

      await repository.updateClassSupervisor(
        classId: classId,
        supervisorId: supervisorId,
      );

      print(
        '🟢 Supervisor updated successfully',
      );

      await loadClasses();
    } catch (e) {
      print(
        '❌ Update supervisor error: $e',
      );

      emit(
        ClassError(
          _cleanErrorMessage(e),
        ),
      );
    }
  }

  Future<void> assignSupervisor({
    required int classId,
    required int supervisorId,
  }) async {
    try {
      await repository.assignSupervisor(
        classId: classId,
        supervisorId: supervisorId,
      );

      await loadClasses();
    } catch (e) {
      print(
        '❌ Assign supervisor error: $e',
      );

      emit(
        ClassError(
          _cleanErrorMessage(e),
        ),
      );
    }
  }

  Future<List<StudentProfileModel>> getStudentsForClass(
    int classId,
    int year,
  ) async {
    try {
      return await repository.getClassStudents(classId);
    } catch (e) {
      print(
        '❌ Students error: $e',
      );

      return [];
    }
  }

  Future<List<StudentProfileModel>> getStudentsByGrade(
    int year,
  ) {
    return repository.getStudentsByGrade(year);
  }

  Future<List<StudentProfileModel>> fetchAllStudents() {
    return repository.getAllStudents();
  }

  Future<List<SchoolClass>> fetchAllClasses() {
    return repository.getClasses();
  }

  void refreshClasses() {
    loadClasses();
  }

  String _cleanErrorMessage(dynamic error) {
    if (error is DioException) {
      final status = error.response?.statusCode;

      if (status == 403) {
        return "You are not allowed to perform this action.";
      }

      if (status == 401) {
        return "Your session has expired. Please login again.";
      }

      if (status == 404) {
        return "Requested data not found.";
      }

      if (status == 500) {
        return "Server error. Please try again later.";
      }

      final data = error.response?.data;

      if (data is Map && data['message'] != null) {
        return data['message'].toString();
      }
    }

    return "Something went wrong. Please try again.";
  }
}
