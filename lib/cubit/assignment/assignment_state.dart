import 'package:school_management/data/model/assignment_model.dart';

abstract class AssignmentState {}

class AssignmentInitial extends AssignmentState {}

class AssignmentLoading extends AssignmentState {}

class AssignmentLoaded extends AssignmentState {
  final List<Assignment> assignments;

  AssignmentLoaded(this.assignments);
}

class AssignmentError extends AssignmentState {
  final String message;

  AssignmentError(this.message);
}
