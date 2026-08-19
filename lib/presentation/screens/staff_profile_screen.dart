import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_management/constants/app_colors.dart';
import 'package:school_management/cubit/staff/staff_profile_cubit.dart';
import 'package:school_management/cubit/staff/staff_profile_state.dart';
import 'package:school_management/presentation/screen/widgets/staff_details_section.dart';
import 'package:school_management/presentation/screen/widgets/staff_overview_card.dart';
import 'package:school_management/presentation/screens/edit_staff_screen.dart';

class StaffProfileScreen extends StatefulWidget {
  final int staffId;
  final bool isManager;
  final VoidCallback onBack;

  const StaffProfileScreen({
    super.key,
    required this.staffId,
    this.isManager = false,
    required this.onBack,
  });

  @override
  State<StaffProfileScreen> createState() => _StaffProfileScreenState();
}

class _StaffProfileScreenState extends State<StaffProfileScreen> {
  void loadProfile() {
    context.read<StaffProfileCubit>().getStaffProfile(
          widget.staffId,
          isManager: widget.isManager,
        );
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadProfile();
    });
  }

  void _showResetPasswordDialog() {
    final passwordController = TextEditingController();
    final confirmController = TextEditingController();

    bool obscurePassword = true;
    bool obscureConfirm = true;
    bool loading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> reset() async {
              final password = passwordController.text.trim();
              final confirm = confirmController.text.trim();

              if (password.isEmpty || confirm.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      "Please enter both passwords",
                    ),
                  ),
                );
                return;
              }

              if (password != confirm) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      "Passwords do not match",
                    ),
                  ),
                );
                return;
              }

              setDialogState(() {
                loading = true;
              });

              final message =
                  await context.read<StaffProfileCubit>().resetPassword(
                        widget.staffId,
                        password,
                        confirm,
                      );

              if (!mounted) return;

              if (message != null) {
                Navigator.pop(dialogContext);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(message),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                setDialogState(() {
                  loading = false;
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      "Failed to reset password",
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }

            return Dialog(
              backgroundColor: AppColors.cardBg,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                width: 450,
                padding: const EdgeInsets.all(24),
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
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.lock_reset,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            "Reset Password",
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: passwordController,
                      obscureText: obscurePassword,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: "New Password",
                        hintStyle: const TextStyle(
                          color: AppColors.textHelper,
                        ),
                        filled: true,
                        fillColor: AppColors.cardElement,
                        suffixIcon: IconButton(
                          onPressed: () {
                            setDialogState(() {
                              obscurePassword = !obscurePassword;
                            });
                          },
                          icon: Icon(
                            obscurePassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: confirmController,
                      obscureText: obscureConfirm,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: "Confirm New Password",
                        hintStyle: const TextStyle(
                          color: AppColors.textHelper,
                        ),
                        filled: true,
                        fillColor: AppColors.cardElement,
                        suffixIcon: IconButton(
                          onPressed: () {
                            setDialogState(() {
                              obscureConfirm = !obscureConfirm;
                            });
                          },
                          icon: Icon(
                            obscureConfirm
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: loading
                              ? null
                              : () {
                                  Navigator.pop(dialogContext);
                                },
                          child: const Text(
                            "Cancel",
                            style: TextStyle(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: loading ? null : reset,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: loading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  "Reset Password",
                                ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).then((_) {
      passwordController.dispose();
      confirmController.dispose();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppGradients.backgroundGradient,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: BlocBuilder<StaffProfileCubit, StaffProfileState>(
          builder: (context, state) {
            if (state is StaffLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                ),
              );
            }

            if (state is StaffError) {
              return Center(
                child: ElevatedButton(
                  onPressed: loadProfile,
                  child: const Text("Try Again"),
                ),
              );
            }

            if (state is StaffProfileLoaded) {
              final staff = state.staff;

              return SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        gradient: AppGradients.cardGradient,
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: widget.onBack,
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                            ),
                          ),

                          const Expanded(
                            child: Text(
                              "Staff Profile",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          // Reset Password
                          ElevatedButton.icon(
                            onPressed: _showResetPasswordDialog,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            icon: const Icon(
                              Icons.lock_reset,
                            ),
                            label: const Text(
                              "Reset Password",
                            ),
                          ),

                          const SizedBox(width: 10),

                          // Edit Staff
                          ElevatedButton.icon(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (_) {
                                  return Dialog(
                                    backgroundColor: Colors.transparent,
                                    insetPadding: const EdgeInsets.all(20),
                                    child: SizedBox(
                                      width: 600,
                                      child: EditStaffScreen(
                                        staff: staff,
                                        staffId: widget.staffId,
                                      ),
                                    ),
                                  );
                                },
                              ).then((updated) {
                                if (updated == true && mounted) {
                                  loadProfile();
                                }
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            icon: const Icon(
                              Icons.edit,
                            ),
                            label: const Text(
                              "Edit Staff",
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          StaffOverviewCard(
                            staff: staff,
                          ),
                          const SizedBox(height: 20),
                          StaffDetailsSection(
                            staff: staff,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }
}
