import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_management/data/repository/reset_password_repository.dart';

import 'reset_password_state.dart';

class ResetPasswordCubit extends Cubit<ResetPasswordState> {
  final ResetPasswordRepository repository;

  ResetPasswordCubit(this.repository) : super(ResetPasswordInitial());

  Future<void> resetPassword({
    required int userId,
    required String newPassword,
    required String confirmation,
  }) async {
    try {
      emit(ResetPasswordLoading());

      final message = await repository.resetPassword(
        userId: userId,
        newPassword: newPassword,
        confirmation: confirmation,
      );

      emit(
        ResetPasswordSuccess(message),
      );
    } catch (e) {
      emit(
        ResetPasswordError(
          e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }
}
