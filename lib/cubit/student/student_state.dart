import 'package:school_management/data/model/student_profile_model.dart';

abstract class StudentState {}

class StudentInitial extends StudentState {}

class StudentLoading extends StudentState {}

class StudentLoaded extends StudentState {
  final List<StudentProfileModel> students;

  StudentLoaded(this.students);
}

class StudentError extends StudentState {
  final String message;

  StudentError(this.message);
}
