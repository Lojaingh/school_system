import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_management/cubit/assignment/assignment_state.dart';
import 'package:school_management/data/repository/assignment_repository.dart';
import '../../data/model/assignment_model.dart';

class AssignmentCubit extends Cubit<AssignmentState> {
  final AssignmentRepository repository;

  AssignmentCubit(this.repository) : super(AssignmentInitial());

  Future<void> loadAssignments() async {
    if (isClosed) return;

    try {
      emit(AssignmentLoading());

      final assignments = await repository.getAssignments();

      if (isClosed) return;

      final sortedAssignments = List<Assignment>.from(assignments)
        ..sort(
          (a, b) => a.dueDate.compareTo(b.dueDate),
        );

      final upcoming = sortedAssignments
          .where(
            (assignment) => !assignment.isOverdue,
          )
          .take(5)
          .toList();

      if (isClosed) return;

      emit(
        AssignmentLoaded(
          assignments: sortedAssignments,
          upcomingAssignments: upcoming,
        ),
      );
    } catch (e) {
      if (isClosed) return;

      emit(
        AssignmentError(
          e.toString(),
        ),
      );
    }
  }

  void refreshAssignments() {
    if (isClosed) return;
    loadAssignments();
  }

  Future<void> addAssignment({
    required String title,
    required String body,
    required String dueDate,
    required int subjectId,
    required int schoolClassId,
    String? filePath,
  }) async {
    if (isClosed) return;

    try {
      emit(AssignmentLoading());

      await repository.createAssignment(
        title: title,
        body: body,
        dueDate: dueDate,
        subjectId: subjectId,
        schoolClassId: schoolClassId,
        filePath: filePath,
      );

      if (isClosed) return;

      await loadAssignments();
    } catch (e) {
      if (isClosed) return;

      print('❌ Add Assignment Error: $e');

      emit(
        AssignmentError(
          e.toString(),
        ),
      );
    }
  }

  Future<void> updateAssignment({
    required int id,
    int? subjectId,
    String? title,
    String? body,
    String? dueDate,
  }) async {
    if (isClosed) return;

    try {
      emit(AssignmentLoading());

      print(' Cubit - Updating assignment');
      print('   id: $id');
      print('   subjectId: $subjectId');
      print('   title: $title');
      print('   body: $body');
      print('   dueDate: $dueDate');

      await repository.updateAssignment(
        id: id,
        subjectId: subjectId,
        title: title,
        body: body,
        dueDate: dueDate,
      );

      if (isClosed) return;

      await loadAssignments();
    } catch (e) {
      if (isClosed) return;

      print('❌ Update error: $e');

      emit(
        AssignmentError(
          e.toString(),
        ),
      );
    }
  }

  Future<void> deleteAssignment(int id) async {
    if (isClosed) return;

    try {
      emit(AssignmentLoading());

      await repository.deleteAssignment(id);

      if (isClosed) return;

      await loadAssignments();
    } catch (e) {
      if (isClosed) return;

      emit(
        AssignmentError(
          e.toString(),
        ),
      );
    }
  }
}
