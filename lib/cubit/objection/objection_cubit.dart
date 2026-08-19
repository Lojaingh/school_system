import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repository/objection_repository.dart';
import 'objection_state.dart';

class ObjectionCubit extends Cubit<ObjectionState> {
  final ObjectionRepository repository;

  ObjectionCubit(this.repository) : super(ObjectionInitial());
  Future<void> getObjections() async {
    try {
      emit(ObjectionLoading());

      final data = await repository.getObjections();

      emit(
        ObjectionLoaded(data),
      );
    } catch (e) {
      emit(
        ObjectionError(
          e.toString(),
        ),
      );
    }
  }
  Future<void> updateObjectionStatus({
    required int id,
    required String status,
  }) async {
    try {
      emit(ObjectionUpdateLoading());

      final message = await repository.updateObjectionStatus(
        id: id,
        status: status,
      );

      emit(
        ObjectionUpdateSuccess(message),
      );
      final data = await repository.getObjections();

      emit(
        ObjectionLoaded(data),
      );
    } catch (e) {
      emit(
        ObjectionError(
          e.toString(),
        ),
      );
    }
  }
}
