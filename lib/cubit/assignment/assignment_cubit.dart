// lib/cubit/assignment/assignment_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_management/cubit/assignment/assignment_state.dart';
import 'package:school_management/data/repository/assignment_repository.dart';
import '../../data/model/assignment_model.dart';

class AssignmentCubit extends Cubit<AssignmentState> {
  final AssignmentRepository repository;

  AssignmentCubit(this.repository) : super(AssignmentInitial());

  Future<void> loadAssignments() async {
    try {
      emit(AssignmentLoading());

      final assignments = await repository.getAssignments();

      final sortedAssignments = List<Assignment>.from(assignments)
        ..sort((a, b) => a.dueDate.compareTo(b.dueDate));

      final upcoming = sortedAssignments
          .where((assignment) => !assignment.isOverdue)
          .take(5)
          .toList();

      emit(
        AssignmentLoaded(
          assignments: sortedAssignments,
          upcomingAssignments: upcoming,
        ),
      );
    } catch (e) {
      emit(AssignmentError(e.toString()));
    }
  }

  void refreshAssignments() {
    loadAssignments();
  }

  // ================= ADD =================

  Future<void> addAssignment({
    required String title,
    required String body,
    required String dueDate,
    required int subjectId,
    String? filePath,
  }) async {
    try {
      emit(AssignmentLoading());

      await repository.createAssignment(
        title: title,
        body: body,
        dueDate: dueDate,
        subjectId: subjectId,
        filePath: filePath,
      );

      await loadAssignments();
    } catch (e) {
      print('⚠️ Add Assignment Error (Check if it was actually saved): $e');

      await loadAssignments();
    }
  }
  // ================= UPDATE =================

  Future<void> updateAssignment({
    required int id,
    String? title,
    String? body,
    String? dueDate,
  }) async {
    try {
      emit(AssignmentLoading());

      await repository.updateAssignment(
        id: id,
        title: title,
        body: body,
        dueDate: dueDate,
      );

      await loadAssignments();
    } catch (e) {
      emit(AssignmentError(e.toString()));
    }
  }

  // ================= DELETE =================

  Future<void> deleteAssignment(int id) async {
    try {
      emit(AssignmentLoading());

      await repository.deleteAssignment(id);

      await loadAssignments();
    } catch (e) {
      emit(AssignmentError(e.toString()));
    }
  }
}
