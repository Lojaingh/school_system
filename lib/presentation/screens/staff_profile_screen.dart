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
                            onPressed: () {
                              widget.onBack();
                            },
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
                            icon: const Icon(Icons.edit),
                            label: const Text("Edit Staff"),
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
