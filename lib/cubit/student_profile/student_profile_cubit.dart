import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_management/data/repository/student_profile_repository.dart';
import 'student_profile_state.dart';

class StudentProfileCubit extends Cubit<StudentProfileState> {
  final StudentProfileRepository repository;

  StudentProfileCubit(this.repository) : super(StudentProfileInitial());

  Future<void> getStudentProfile(int id) async {
    try {
      emit(StudentProfileLoading());

      final profile = await repository.getStudentProfile(id);

      emit(StudentProfileLoaded(profile));
    } catch (e) {
      emit(
        StudentProfileError(
          e.toString(),
        ),
      );
    }
  }

  Future<void> updateStudent(
    int id,
    Map<String, dynamic> data,
  ) async {
    try {
      await repository.updateStudent(id, data);
    } catch (e) {
      rethrow;
    }
  }
}
