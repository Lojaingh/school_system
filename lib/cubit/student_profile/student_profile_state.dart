import 'package:school_management/data/model/student_profile_model.dart';

abstract class StudentProfileState {}

class StudentProfileInitial extends StudentProfileState {}

class StudentProfileLoading extends StudentProfileState {}

class StudentProfileLoaded extends StudentProfileState {
  final StudentProfileModel profile;

  StudentProfileLoaded(this.profile);
}

class StudentProfileError extends StudentProfileState {
  final String message;

  StudentProfileError(this.message);
}
