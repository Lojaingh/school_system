import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_management/constants/app_colors.dart';
import 'package:school_management/cubit/resetpassword/reset_password_cubit.dart';
import 'package:school_management/cubit/resetpassword/reset_password_state.dart';

import 'package:school_management/data/repository/reset_password_repository.dart';
import 'package:school_management/data/services/reset_password_service.dart';

class ResetPasswordDialog extends StatefulWidget {
  final int userId;

  const ResetPasswordDialog({
    super.key,
    required this.userId,
  });

  @override
  State<ResetPasswordDialog> createState() => _ResetPasswordDialogState();
}

class _ResetPasswordDialogState extends State<ResetPasswordDialog> {
  final passwordController = TextEditingController();
  final confirmationController = TextEditingController();

  bool obscurePassword = true;
  bool obscureConfirmation = true;

  @override
  void dispose() {
    passwordController.dispose();
    confirmationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ResetPasswordCubit(
        ResetPasswordRepository(
          ResetPasswordService(),
        ),
      ),
      child: BlocConsumer<ResetPasswordCubit, ResetPasswordState>(
        listener: (context, state) {
          if (state is ResetPasswordSuccess) {
            Navigator.pop(context, true);
          }

          if (state is ResetPasswordError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is ResetPasswordLoading;

          return Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              width: 450,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: AppGradients.cardGradient,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.cardBorder,
                ),
                boxShadow: AppShadows.cardShadow,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.lock_reset_rounded,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        "Reset Password",
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  _passwordField(
                    label: "New Password",
                    controller: passwordController,
                    obscure: obscurePassword,
                    onToggle: () {
                      setState(() {
                        obscurePassword = !obscurePassword;
                      });
                    },
                  ),
                  const SizedBox(height: 14),
                  _passwordField(
                    label: "Confirm New Password",
                    controller: confirmationController,
                    obscure: obscureConfirmation,
                    onToggle: () {
                      setState(() {
                        obscureConfirmation = !obscureConfirmation;
                      });
                    },
                  ),
                  const SizedBox(height: 25),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: isLoading
                              ? null
                              : () => Navigator.pop(
                                    context,
                                  ),
                          child: const Text("Cancel"),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: isLoading
                              ? null
                              : () {
                                  final password =
                                      passwordController.text.trim();

                                  final confirmation =
                                      confirmationController.text.trim();

                                  if (password.isEmpty ||
                                      confirmation.isEmpty) {
                                    return;
                                  }

                                  if (password != confirmation) {
                                    ScaffoldMessenger.of(
                                      context,
                                    ).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          "Passwords do not match",
                                        ),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                    return;
                                  }

                                  context
                                      .read<ResetPasswordCubit>()
                                      .resetPassword(
                                        userId: widget.userId,
                                        newPassword: password,
                                        confirmation: confirmation,
                                      );
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  "Reset Password",
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _passwordField({
    required String label,
    required TextEditingController controller,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(
        color: AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: AppColors.textHelper,
        ),
        filled: true,
        fillColor: AppColors.cardElement,
        suffixIcon: IconButton(
          onPressed: onToggle,
          icon: Icon(
            obscure ? Icons.visibility_off : Icons.visibility,
            color: AppColors.textSecondary,
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}
