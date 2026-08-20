import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:school_management/constants/app_colors.dart';
import 'package:school_management/cubit/external/external_cubit.dart';
import 'package:school_management/cubit/external/external_state.dart';
import 'package:school_management/data/model/external_model.dart';
import 'package:school_management/presentation/screen/widgets/external_card.dart';
import 'package:school_management/presentation/screen/widgets/external_form_widget.dart';
import 'package:school_management/utils/shared_prefs_helper.dart';

class ExternalsScreen extends StatefulWidget {
  const ExternalsScreen({super.key});

  @override
  State<ExternalsScreen> createState() => _ExternalsScreenState();
}

class _ExternalsScreenState extends State<ExternalsScreen> {
  bool canManage = false;
  bool isTeacher = false;
  bool isManager = false;

  @override
  void initState() {
    super.initState();

    _loadPermission();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ExternalCubit>().getExternals();
    });
  }

  Future<void> _loadPermission() async {
    final role = await SharedPrefsHelper.getRole();

    if (!mounted) return;

    final normalizedRole = role?.trim().toLowerCase();

    print("🟡 EXTERNAL SCREEN ROLE: $normalizedRole");

    setState(() {
      isTeacher = normalizedRole == 'teacher';
      isManager = normalizedRole == 'manager';
      canManage = isTeacher || isManager;
    });

    print("🟡 isTeacher: $isTeacher");
    print("🟡 isManager: $isManager");
    print("🟡 canManage: $canManage");
  }

  void _openAddDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(20),
          child: ExternalFormWidget(
            isTeacher: isTeacher,
            isManager: isManager,
          ),
        );
      },
    );
  }

  void _openEditDialog(ExternalModel external) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(20),
          child: ExternalFormWidget(
            external: external,
            isTeacher: isTeacher,
            isManager: isManager,
          ),
        );
      },
    );
  }

  void _deleteExternal(ExternalModel external) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.cardBg,
          title: const Text(
            "Delete External",
            style: TextStyle(
              color: AppColors.textPrimary,
            ),
          ),
          content: const Text(
            "Are you sure you want to delete this external?",
            style: TextStyle(
              color: AppColors.textSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);

                context.read<ExternalCubit>().deleteExternal(
                      external.id,
                    );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppGradients.backgroundGradient,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: BlocConsumer<ExternalCubit, ExternalState>(
          listener: (context, state) {
            print("🟣 EXTERNAL SCREEN STATE: ${state.runtimeType}");

            if (state is ExternalDeleteSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }

            if (state is ExternalUpdateSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }

            if (state is ExternalAddSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }

            if (state is ExternalError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.redAccent,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is ExternalLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                ),
              );
            }

            if (state is ExternalError) {
              return Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    context.read<ExternalCubit>().getExternals();
                  },
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text("Try Again"),
                ),
              );
            }

            List<ExternalModel> externals = [];

            if (state is ExternalLoaded) {
              externals = state.externals;
            } else if (state is ExternalUpdateSuccess) {
              externals = state.externals;
            } else if (state is ExternalDeleteSuccess) {
              externals = state.externals;
            }

            return Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    gradient: AppGradients.cardGradient,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(11),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.folder_copy_rounded,
                          color: AppColors.primary,
                          size: 25,
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Externals",
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 23,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "Manage external files and documents",
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (canManage)
                        ElevatedButton.icon(
                          onPressed: _openAddDialog,
                          icon: const Icon(Icons.add_rounded),
                          label: const Text("Add External"),
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
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: externals.isEmpty
                      ? const Center(
                          child: Text(
                            "No externals found",
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 16,
                            ),
                          ),
                        )
                      : RefreshIndicator(
                          color: AppColors.primary,
                          onRefresh: () async {
                            await context.read<ExternalCubit>().getExternals();
                          },
                          child: GridView.builder(
                            padding: const EdgeInsets.all(24),
                            gridDelegate:
                                const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 400,
                              mainAxisExtent: 385,
                              crossAxisSpacing: 18,
                              mainAxisSpacing: 18,
                            ),
                            itemCount: externals.length,
                            itemBuilder: (context, index) {
                              final external = externals[index];

                              return ExternalCard(
                                external: external,
                                canManage: canManage,
                                onEdit: canManage
                                    ? () {
                                        _openEditDialog(external);
                                      }
                                    : null,
                                onDelete: canManage
                                    ? () {
                                        _deleteExternal(external);
                                      }
                                    : null,
                              );
                            },
                          ),
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
