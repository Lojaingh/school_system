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

      final credentials = await repository.register(student);

      print('REGISTER SUCCESS');
      print('USERNAME: ${credentials['username']}');
      print('PASSWORD: ${credentials['password']}');

      emit(
        RegisterSuccess(
          username: credentials['username']!,
          password: credentials['password']!,
        ),
      );
    } catch (e) {
      print('REGISTER ERROR');
      print(e);

      emit(RegisterError(e.toString()));
    }
  }
}
