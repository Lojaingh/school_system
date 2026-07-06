abstract class SubjectState {}

class SubjectInitial extends SubjectState {}

class SubjectLoading extends SubjectState {}

class SubjectsLoaded extends SubjectState {
  final List<dynamic> subjects;

  SubjectsLoaded(this.subjects);
}

class SubjectLoaded extends SubjectState {
  final Map<String, dynamic> subject;

  SubjectLoaded(this.subject);
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
