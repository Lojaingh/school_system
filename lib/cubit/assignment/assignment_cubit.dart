import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_management/cubit/assignment/assignment_state.dart';
import 'package:school_management/data/repository/assignment_repository.dart';

class AssignmentCubit extends Cubit<AssignmentState> {
  AssignmentCubit() : super(AssignmentInitial());

  final AssignmentRepository _repository = AssignmentRepository();

  Future<void> getAssignments() async {
    try {
      emit(AssignmentLoading());

      final assignments = await _repository.getAssignments();

      emit(AssignmentLoaded(assignments));
    } catch (e) {
      emit(AssignmentError(e.toString()));
    }
  }
}
