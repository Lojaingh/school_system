import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_management/data/model/student_model.dart';
import 'package:school_management/data/repository/register_repository.dart';

import 'register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  final RegisterRepository repository;

  RegisterCubit(this.repository) : super(RegisterInitial());

  Future<void> register(StudentModel student) async {
    try {
      print('REGISTER START');

      emit(RegisterLoading());

      final message = await repository.register(student);

      print('REGISTER SUCCESS');
      print(message);

      emit(RegisterSuccess(message));
    } catch (e) {
      print('REGISTER ERROR');
      print(e);

      emit(RegisterError(e.toString()));
    }
  }
}
