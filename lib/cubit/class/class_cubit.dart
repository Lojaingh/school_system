import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:school_management/data/model/student_profile_model.dart';

import '../../data/model/class_model.dart';
import '../../data/repository/class_repository.dart';

part 'class_state.dart';

class ClassCubit extends Cubit<ClassState> {
  final ClassRepository repository;

  ClassCubit(this.repository) : super(ClassInitial());

  // ============================================================
  // GET CLASSES
  // ============================================================

  Future<void> loadClasses() async {
    try {
      emit(ClassLoading());

      final classes = await repository.getClasses();

      emit(ClassLoaded(classes));
    } catch (e) {
      print('❌ ClassCubit Error: $e');
      emit(ClassError(e.toString()));
    }
  }

  // ============================================================
  // GET CLASSES BY GRADE
  // ============================================================

  Future<void> loadClassesByGrade(int year) async {
    try {
      emit(ClassLoading());

      final classes = await repository.getClassesByGrade(year);

      emit(ClassLoaded(classes));
    } catch (e) {
      print('❌ ClassCubit Error: $e');
      emit(ClassError(e.toString()));
    }
  }

  // ============================================================
  // ADD CLASS
  // ============================================================

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
      print('❌ ClassCubit Error adding class: $e');
      emit(ClassError(e.toString()));
    }
  }

  // ============================================================
  // DELETE CLASS
  // ============================================================

  Future<void> deleteClass(int id) async {
    try {
      emit(ClassLoading());

      await repository.deleteClass(id);

      await loadClasses();
    } catch (e) {
      print('❌ ClassCubit Error deleting class: $e');
      emit(ClassError(e.toString()));
    }
  }

  // ============================================================
  // MOVE STUDENT
  // ============================================================

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
      print('❌ ClassCubit Error moving student: $e');
      emit(ClassError(e.toString()));
      rethrow;
    }
  }

  // ============================================================
  // DISTRIBUTE STUDENTS
  // ============================================================

  Future<void> distributeStudents(int capacity) async {
    try {
      emit(ClassLoading());

      await repository.distributeStudents(capacity);

      await loadClasses();
    } catch (e) {
      print('❌ ClassCubit Error distributing students: $e');
      emit(ClassError(e.toString()));
    }
  }

  // ============================================================
  // GET SUPERVISORS
  // ============================================================

  Future<List<Map<String, dynamic>>> getSupervisors() async {
    try {
      print('🔵 ClassCubit: loading supervisors...');

      final supervisors = await repository.getSupervisors();

      print(
        '🟢 ClassCubit: '
        '${supervisors.length} supervisors found',
      );

      return supervisors;
    } catch (e) {
      print(
        '❌ ClassCubit Error loading supervisors: $e',
      );

      return [];
    }
  }

  // ============================================================
  // UPDATE CLASS SUPERVISOR
  // ============================================================

  Future<void> updateClassSupervisor({
    required int classId,
    required int? supervisorId,
  }) async {
    try {
      print(
        '🔵 Updating supervisor '
        '$supervisorId for class $classId',
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
        '❌ ClassCubit updateClassSupervisor Error: $e',
      );

      emit(ClassError(e.toString()));

      rethrow;
    }
  }

  // ============================================================
  // OLD ASSIGN SUPERVISOR
  // ============================================================

  Future<void> assignSupervisor({
    required int classId,
    required int supervisorId,
  }) async {
    try {
      print(
        '🔵 Assigning supervisor $supervisorId '
        'to class $classId',
      );

      await repository.assignSupervisor(
        classId: classId,
        supervisorId: supervisorId,
      );

      print(
        '🟢 Supervisor assigned successfully',
      );

      await loadClasses();
    } catch (e) {
      print(
        '❌ ClassCubit assignSupervisor Error: $e',
      );

      emit(ClassError(e.toString()));

      rethrow;
    }
  }

  // ============================================================
  // GET STUDENTS FOR CLASS
  // ============================================================

  Future<List<StudentProfileModel>> getStudentsForClass(
    int classId,
    int year,
  ) async {
    try {
      print(
        '🔵 Getting students for class: $classId',
      );

      final students = await repository.getClassStudents(classId);

      print(
        '🔵 Found ${students.length} '
        'students in class $classId',
      );

      return students;
    } catch (e) {
      print(
        '❌ Error getting students for class: $e',
      );

      return [];
    }
  }

  // ============================================================
  // GET STUDENTS BY GRADE
  // ============================================================

  Future<List<StudentProfileModel>> getStudentsByGrade(
    int year,
  ) {
    return repository.getStudentsByGrade(year);
  }

  // ============================================================
  // GET ALL STUDENTS
  // ============================================================

  Future<List<StudentProfileModel>> fetchAllStudents() {
    return repository.getAllStudents();
  }

  // ============================================================
  // GET ALL CLASSES
  // ============================================================

  Future<List<SchoolClass>> fetchAllClasses() {
    return repository.getClasses();
  }

  // ============================================================
  // REFRESH
  // ============================================================

  void refreshClasses() {
    loadClasses();
  }
}
