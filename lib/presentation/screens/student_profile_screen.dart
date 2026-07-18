import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_management/constants/app_colors.dart';
import 'package:school_management/cubit/student_profile/student_profile_cubit.dart';
import 'package:school_management/cubit/student_profile/student_profile_state.dart';
import 'package:school_management/presentation/screen/widgets/student_details_section.dart';
import 'package:school_management/presentation/screen/widgets/stusent_overview_card.dart';
import 'package:school_management/presentation/screens/edit_student_screen.dart';

class StudentProfileScreen extends StatefulWidget {
  final int studentId;
  final VoidCallback onBack;

  const StudentProfileScreen({
    super.key,
    required this.studentId,
    required this.onBack,
  });

  @override
  State<StudentProfileScreen> createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends State<StudentProfileScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StudentProfileCubit>().getStudentProfile(widget.studentId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cardBg,
      body: BlocBuilder<StudentProfileCubit, StudentProfileState>(
        builder: (context, state) {
          if (state is StudentProfileLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            );
          }

          if (state is StudentProfileError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    color: Colors.redAccent,
                    size: 48,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    state.message,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      context
                          .read<StudentProfileCubit>()
                          .getStudentProfile(widget.studentId);
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text("Try Again"),
                  ),
                ],
              ),
            );
          }

          if (state is StudentProfileLoaded) {
            final student = state.profile;

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
                            "Student Profile",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (_) => Dialog(
                                backgroundColor: Colors.transparent,
                                insetPadding: const EdgeInsets.all(20),
                                child: SizedBox(
                                  width: 600,
                                  child: EditStudentScreen(
                                    student: student,
                                    studentId: widget.studentId,
                                  ),
                                ),
                              ),
                            ).then((value) {
                              if (value == true && mounted) {
                                context
                                    .read<StudentProfileCubit>()
                                    .getStudentProfile(widget.studentId);
                              }
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.edit),
                          label: const Text("Edit Student"),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        StudentOverviewCard(
                          student: student,
                        ),
                        const SizedBox(height: 20),
                        StudentDetailsSection(
                          student: student,
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
    );
  }
}
