import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_management/presentation/screen/widgets/app_error_dialog.dart';

import 'package:school_management/presentation/screen/widgets/class_content.dart';

import '../../cubit/class/class_cubit.dart';
import '../../constants/app_colors.dart' as app;

class ClassScreen extends StatelessWidget {
  const ClassScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: app.AppGradients.backgroundGradient,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text(
            'Classes Management',
            style: TextStyle(
              fontWeight: FontWeight.w700,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(
                Icons.auto_awesome_rounded,
              ),
              onPressed: () {
                _showDistributeDialog(context);
              },
              tooltip: 'Distribute Students',
            ),
            IconButton(
              icon: const Icon(
                Icons.refresh_rounded,
              ),
              onPressed: () {
                context.read<ClassCubit>().refreshClasses();
              },
            ),
          ],
        ),
        body: BlocListener<ClassCubit, ClassState>(
          listener: (context, state) {
            if (state is ClassDistributionError) {
              showDialog(
                context: context,
                builder: (_) => AppErrorDialog(
                  title: 'Distribution Failed',
                  message: state.message,
                  icon: Icons.groups_rounded,
                ),
              ).then((_) {
                context.read<ClassCubit>().loadClasses();
              });
            }
          },
          child: const ClassContent(),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            _showAddClassDialog(context);
          },
          backgroundColor: app.AppColors.primary,
          foregroundColor: Colors.white,
          icon: const Icon(
            Icons.add_rounded,
          ),
          label: const Text(
            'New Class',
            style: TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // ADD CLASS
  // ============================================================

  void _showAddClassDialog(BuildContext context) {
    final yearController = TextEditingController();
    final numberController = TextEditingController();

    int? selectedSupervisorId;

    List<Map<String, dynamic>> supervisors = [];

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            if (supervisors.isEmpty) {
              context.read<ClassCubit>().getSupervisors().then((result) {
                if (context.mounted) {
                  setState(() {
                    supervisors = result;
                  });
                }
              });
            }

            InputDecoration darkField(
              String label,
              String hint,
            ) {
              return InputDecoration(
                labelText: label,
                hintText: hint,
                labelStyle: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                ),
                hintStyle: TextStyle(
                  color: Colors.white.withOpacity(0.35),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: Colors.white.withOpacity(0.2),
                  ),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(10),
                  ),
                  borderSide: BorderSide(
                    color: app.AppColors.primary,
                  ),
                ),
              );
            }

            return AlertDialog(
              backgroundColor: const Color(0xFF1E2746),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text(
                'Add New Class',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: yearController,
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                      decoration: darkField(
                        'Grade Year (1-12)',
                        'e.g., 11',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: numberController,
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                      decoration: darkField(
                        'Section Number',
                        'e.g., 1',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<int>(
                      value: selectedSupervisorId,
                      dropdownColor: const Color(0xFF1E2746),
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Supervisor',
                        labelStyle: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: Colors.white.withOpacity(0.2),
                          ),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(10),
                          ),
                          borderSide: BorderSide(
                            color: app.AppColors.primary,
                          ),
                        ),
                      ),
                      hint: Text(
                        supervisors.isEmpty
                            ? 'Loading supervisors...'
                            : 'Select Supervisor',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.4),
                        ),
                      ),
                      items: supervisors
                          .map((supervisor) {
                            final id = _getSupervisorId(
                              supervisor,
                            );

                            final name = _getSupervisorName(
                              supervisor,
                            );

                            if (id == null) {
                              return null;
                            }

                            return DropdownMenuItem<int>(
                              value: id,
                              child: Text(
                                name,
                                style: const TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            );
                          })
                          .whereType<DropdownMenuItem<int>>()
                          .toList(),
                      onChanged: supervisors.isEmpty
                          ? null
                          : (value) {
                              setState(() {
                                selectedSupervisorId = value;
                              });
                            },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    final year = int.tryParse(
                      yearController.text.trim(),
                    );

                    final number = int.tryParse(
                      numberController.text.trim(),
                    );

                    if (year != null &&
                        number != null &&
                        year >= 1 &&
                        year <= 12) {
                      context.read<ClassCubit>().addClass(
                            year: year,
                            number: number,
                            supervisorId: selectedSupervisorId,
                          );

                      Navigator.pop(dialogContext);

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Class added successfully!',
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Please enter valid year (1-12) and number',
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: app.AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text(
                    'Add Class',
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ============================================================
  // SUPERVISOR HELPERS
  // ============================================================

  int? _getSupervisorId(
    Map<String, dynamic> supervisor,
  ) {
    final value =
        supervisor['user_id'] ?? supervisor['id'] ?? supervisor['userId'];

    if (value is int) {
      return value;
    }

    return int.tryParse(
      value?.toString() ?? '',
    );
  }

  String _getSupervisorName(
    Map<String, dynamic> supervisor,
  ) {
    final profile = supervisor['profile'];

    if (profile is Map<String, dynamic>) {
      final firstName = profile['f_name']?.toString() ?? '';

      final lastName = profile['l_name']?.toString() ?? '';

      final name =
          '$firstName $lastName'.replaceAll(RegExp(r'\s+'), ' ').trim();

      if (name.isNotEmpty) {
        return name;
      }
    }

    if (supervisor['full_name'] != null) {
      return supervisor['full_name'].toString();
    }

    if (supervisor['fullName'] != null) {
      return supervisor['fullName'].toString();
    }

    return supervisor['username']?.toString() ?? 'Supervisor';
  }

  // ============================================================
  // DISTRIBUTE STUDENTS
  // ============================================================

  void _showDistributeDialog(
    BuildContext context,
  ) {
    final capacityController = TextEditingController();

    InputDecoration darkField(
      String label,
      String hint,
    ) {
      return InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: TextStyle(
          color: Colors.white.withOpacity(0.7),
        ),
        hintStyle: TextStyle(
          color: Colors.white.withOpacity(0.35),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.2),
          ),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(10),
          ),
          borderSide: BorderSide(
            color: app.AppColors.primary,
          ),
        ),
      );
    }

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E2746),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Distribute Students',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Enter the maximum number of students per class',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: capacityController,
                style: const TextStyle(
                  color: Colors.white,
                ),
                decoration: darkField(
                  'Capacity per Class',
                  'e.g., 20',
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final capacity = int.tryParse(
                  capacityController.text.trim(),
                );

                if (capacity != null && capacity > 0) {
                  Navigator.pop(dialogContext);

                  context
                      .read<ClassCubit>()
                      .distributeStudents(capacity)
                      .catchError((error) {
                    showDialog(
                      context: context,
                      builder: (_) => AppErrorDialog(
                        title: 'Distribution Failed',
                        message: error is DioException &&
                                error.response?.statusCode == 409
                            ? 'Students are already distributed.'
                            : 'Something went wrong.',
                        icon: Icons.groups_rounded,
                      ),
                    );
                  });
                } else {
                  showDialog(
                    context: context,
                    builder: (_) => const AppErrorDialog(
                      title: 'Invalid Capacity',
                      message: 'Please enter a valid capacity number.',
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: app.AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text(
                'Distribute',
              ),
            ),
          ],
        );
      },
    );
  }
}
