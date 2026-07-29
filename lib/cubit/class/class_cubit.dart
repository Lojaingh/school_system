// lib/cubit/class/class_cubit.dart

// lib/cubit/class/class_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:school_management/data/model/student_profile_model.dart';
import '../../data/model/class_model.dart';

import '../../data/repository/class_repository.dart';

part 'class_state.dart';

class ClassCubit extends Cubit<ClassState> {
  final ClassRepository repository;

  ClassCubit(this.repository) : super(ClassInitial());

  // ── جلب جميع الصفوف ──
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

  // ── جلب الصفوف حسب السنة ──
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

  // ── إضافة صف جديد ──
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
      print('❌ ClassCubit Error: $e');
      emit(ClassError(e.toString()));
    }
  }

  // ── حذف صف ──
  Future<void> deleteClass(int id) async {
    try {
      emit(ClassLoading());
      await repository.deleteClass(id);
      await loadClasses();
    } catch (e) {
      print('❌ ClassCubit Error: $e');
      emit(ClassError(e.toString()));
    }
  }

  // ── نقل طالب ──
  Future<void> moveStudent({
    required int userId,
    required int classId,
  }) async {
    try {
      emit(ClassLoading());
      await repository.moveStudent(
        userId: userId,
        classId: classId,
      );
      await loadClasses();
    } catch (e) {
      print('❌ ClassCubit Error: $e');
      emit(ClassError(e.toString()));
    }
  }

  // ── توزيع الطلاب ──
  Future<void> distributeStudents(int capacity) async {
    try {
      emit(ClassLoading());
      await repository.distributeStudents(capacity);
      await loadClasses();
    } catch (e) {
      print('❌ ClassCubit Error: $e');
      emit(ClassError(e.toString()));
    }
  }

  // ── ✅ جلب طلاب صف معين (باستخدام الـ API الجديد) ──
  Future<List<StudentProfileModel>> getStudentsForClass(
      int classId, int year) async {
    try {
      print('🔵 Getting students for class: $classId');

      // ✅ استخدام الـ API الجديد مباشرة
      final students = await repository.getClassStudents(classId);

      print('🔵 Found ${students.length} students in class $classId');
      for (var s in students) {
        print('   - ${s.firstName} ${s.lastName} (ID: ${s.userId})');
      }

      return students;
    } catch (e) {
      print('❌ Error getting students for class: $e');
      return [];
    }
  }

  // ── جلب كل الطلاب (للحالات النادرة) ──
  Future<List<StudentProfileModel>> fetchAllStudents() {
    return repository.getAllStudents();
  }

  // ── تحديث الصفوف ──
  void refreshClasses() {
    loadClasses();
  }
}
