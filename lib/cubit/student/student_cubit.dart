import 'package:flutter_bloc/flutter_bloc.dart';
import 'student_state.dart';
import 'package:school_management/data/repository/student_repository.dart';

class StudentCubit extends Cubit<StudentState> {
  final StudentRepository repository;

  StudentCubit(this.repository) : super(StudentInitial());

  Future<void> getStudents(int roleId) async {
    try {
      emit(StudentLoading());

      final students = await repository.getStudents(roleId);

      emit(StudentLoaded(students));
    } catch (e) {
      emit(StudentError(e.toString()));
    }
  }

  // ==========================
  // 🗑 DELETE STUDENT
  // ==========================
  Future<void> deleteStudent(int id) async {
    try {
      emit(StudentLoading());

      await repository.deleteStudent(id);

      final students = await repository.getStudents(6);

      emit(StudentLoaded(students));
    } catch (e) {
      emit(StudentError(e.toString()));
    }
  }
}
