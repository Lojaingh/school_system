import 'package:school_management/data/model/external_model.dart';
import 'package:school_management/data/model/school_class_model.dart';

abstract class ExternalState {}

class ExternalInitial extends ExternalState {}

class ExternalLoading extends ExternalState {}

class ExternalLoaded extends ExternalState {
  final List<ExternalModel> externals;

  ExternalLoaded(this.externals);
}

class ExternalDetailsLoading extends ExternalState {}

class ExternalDetailsLoaded extends ExternalState {
  final ExternalModel external;

  ExternalDetailsLoaded(this.external);
}

class ExternalAddLoading extends ExternalState {}

class ExternalAddSuccess extends ExternalState {
  final String message;

  ExternalAddSuccess(this.message);
}

class ExternalUpdateLoading extends ExternalState {}

class ExternalUpdateSuccess extends ExternalState {
  final String message;
  final List<ExternalModel> externals;

  ExternalUpdateSuccess({
    required this.message,
    required this.externals,
  });
}

class ExternalDeleteLoading extends ExternalState {}

class ExternalDeleteSuccess extends ExternalState {
  final String message;
  final List<ExternalModel> externals;

  ExternalDeleteSuccess({
    required this.message,
    required this.externals,
  });
}

class TeacherClassesLoading extends ExternalState {}

class TeacherClassesLoaded extends ExternalState {
  final List<SchoolClassModel> classes;

  TeacherClassesLoaded(this.classes);
}

class GradeClassesLoading extends ExternalState {}

class GradeClassesLoaded extends ExternalState {
  final List<SchoolClassModel> classes;

  GradeClassesLoaded(this.classes);
}

class ExternalError extends ExternalState {
  final String message;

  ExternalError(this.message);
}
