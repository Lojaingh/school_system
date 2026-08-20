import 'package:school_management/data/model/external_model.dart';
import 'package:school_management/data/model/school_class_model.dart';

abstract class ExternalState {}

class ExternalInitial extends ExternalState {}

// =========================
// EXTERNALS
// =========================

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

// =========================
// ADD
// =========================

class ExternalAddLoading extends ExternalState {}

class ExternalAddSuccess extends ExternalState {
  final String message;

  ExternalAddSuccess(this.message);
}

// =========================
// UPDATE
// =========================

class ExternalUpdateLoading extends ExternalState {}

class ExternalUpdateSuccess extends ExternalState {
  final String message;
  final List<ExternalModel> externals;

  ExternalUpdateSuccess({
    required this.message,
    required this.externals,
  });
}

// =========================
// DELETE
// =========================

class ExternalDeleteLoading extends ExternalState {}

class ExternalDeleteSuccess extends ExternalState {
  final String message;
  final List<ExternalModel> externals;

  ExternalDeleteSuccess({
    required this.message,
    required this.externals,
  });
}

// =========================
// TEACHER CLASSES
// =========================

class TeacherClassesLoading extends ExternalState {}

class TeacherClassesLoaded extends ExternalState {
  final List<SchoolClassModel> classes;

  TeacherClassesLoaded(this.classes);
}

// =========================
// MANAGER - ALL CLASSES
// =========================

class AllClassesLoading extends ExternalState {}

class AllClassesLoaded extends ExternalState {
  final List<SchoolClassModel> classes;

  AllClassesLoaded(this.classes);
}

// =========================
// GRADE CLASSES
// =========================

class GradeClassesLoading extends ExternalState {}

class GradeClassesLoaded extends ExternalState {
  final List<SchoolClassModel> classes;

  GradeClassesLoaded(this.classes);
}

// =========================
// ERROR
// =========================

class ExternalError extends ExternalState {
  final String message;

  ExternalError(this.message);
}
