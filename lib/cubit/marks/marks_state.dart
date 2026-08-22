import 'package:school_management/data/model/student_marks_model.dart';
import 'package:school_management/data/model/subject_marks_model.dart';

sealed class MarksState {
  const MarksState();
}

class MarksInitial extends MarksState {
  const MarksInitial();
}

class MarksLoading extends MarksState {
  const MarksLoading();
}

class MarksLoaded extends MarksState {
  final SubjectMarksData data;

  const MarksLoaded({
    required this.data,
  });
}

class MarksSaving extends MarksState {
  const MarksSaving();
}

class MarksSaved extends MarksState {
  final StudentMarksResponse response;

  const MarksSaved({
    required this.response,
  });
}

class MarksError extends MarksState {
  final String message;
  final int? statusCode;

  const MarksError({
    required this.message,
    this.statusCode,
  });
}
