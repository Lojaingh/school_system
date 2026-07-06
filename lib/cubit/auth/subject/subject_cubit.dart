import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_management/cubit/auth/subject/subject_state.dart';
import 'package:school_management/data/model/subject_model.dart';
import 'package:school_management/data/repository/subject_repository.dart';

class SubjectCubit extends Cubit<SubjectState> {
  final SubjectRepository repository;

  SubjectCubit(this.repository) : super(SubjectInitial());

  Future<void> addSubject(SubjectModel subject) async {
    try {
      emit(SubjectLoading());

      final message = await repository.addSubject(subject);

      emit(SubjectAdded(message));
    } catch (e) {
      emit(SubjectError(e.toString()));
    }
  }

  Future<void> getSubjects() async {
    try {
      emit(SubjectLoading());

      final subjects = await repository.getSubjects();

      emit(SubjectsLoaded(subjects));
    } catch (e) {
      emit(SubjectError(e.toString()));
    }
  }

  Future<void> getSubject(int id) async {
    try {
      emit(SubjectLoading());

      final subject = await repository.getSubject(id);

      emit(SubjectLoaded(subject));
    } catch (e) {
      emit(SubjectError(e.toString()));
    }
  }

  Future<void> updateSubject(int id, SubjectModel subject) async {
    try {
      emit(SubjectLoading());

      final message = await repository.updateSubject(id, subject);

      emit(SubjectUpdated(message));
    } catch (e) {
      emit(SubjectError(e.toString()));
    }
  }

  Future<void> deleteSubject(int id) async {
    try {
      emit(SubjectLoading());

      final message = await repository.deleteSubject(id);

      emit(SubjectDeleted(message));
    } catch (e) {
      emit(SubjectError(e.toString()));
    }
  }
}
