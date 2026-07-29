import 'package:school_management/data/model/subject_model.dart';

abstract class SubjectState {}

class SubjectInitial extends SubjectState {}

class SubjectLoading extends SubjectState {}

class SubjectsLoaded extends SubjectState {
  final List<SubjectModel> subjects;

  SubjectsLoaded(this.subjects);
}

class SubjectAdded extends SubjectState {
  final String message;

  SubjectAdded(this.message);
}

class SubjectUpdated extends SubjectState {
  final String message;

  SubjectUpdated(this.message);
}

class SubjectDeleted extends SubjectState {
  final String message;

  SubjectDeleted(this.message);
}

class SubjectError extends SubjectState {
  final String message;

  SubjectError(this.message);
}
