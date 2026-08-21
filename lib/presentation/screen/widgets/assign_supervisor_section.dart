import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_management/cubit/class/class_cubit.dart';
import 'package:school_management/data/model/class_model.dart';

class AssignSupervisorSection extends StatefulWidget {
  const AssignSupervisorSection({
    super.key,
  });

  @override
  State<AssignSupervisorSection> createState() =>
      _AssignSupervisorSectionState();
}

class _AssignSupervisorSectionState extends State<AssignSupervisorSection> {
  List<Map<String, dynamic>> supervisors = [];

  bool loadingSupervisors = true;

  @override
  void initState() {
    super.initState();
    _loadSupervisors();
  }

  Future<void> _loadSupervisors() async {
    final result = await context.read<ClassCubit>().getSupervisors();

    if (!mounted) return;

    setState(() {
      supervisors = result;
      loadingSupervisors = false;
    });
  }

  String _supervisorName(
    Map<String, dynamic> supervisor,
  ) {
    final profile = supervisor['profile'] ?? {};

    final firstName = profile['f_name'] ?? '';

    final lastName = profile['l_name'] ?? '';

    return '$firstName $lastName'.trim();
  }

  int? _supervisorId(
    Map<String, dynamic> supervisor,
  ) {
    final id = supervisor['user_id'];

    if (id is int) {
      return id;
    }

    return int.tryParse(
      id?.toString() ?? '',
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ClassCubit, ClassState>(
      builder: (context, state) {
        if (state is ClassLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (state is ClassError) {
          return Center(
            child: Text(
              state.message,
            ),
          );
        }

        if (state is! ClassLoaded) {
          return const SizedBox();
        }

        // فقط الصفوف التي لا يوجد لها موجه
        final classesWithoutSupervisor = state.classes
            .where(
              (schoolClass) => schoolClass.supervisorId == null,
            )
            .toList();

        if (classesWithoutSupervisor.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(20),
            child: const Center(
              child: Text(
                'جميع الصفوف لديها موجه ✅',
              ),
            ),
          );
        }

        if (loadingSupervisors) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (supervisors.isEmpty) {
          return const Center(
            child: Text(
              'لا يوجد موجهون متاحون',
            ),
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: classesWithoutSupervisor.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final SchoolClass schoolClass = classesWithoutSupervisor[index];

            return Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // =========================
                    // CLASS NAME
                    // =========================

                    Expanded(
                      flex: 2,
                      child: Text(
                        schoolClass.displayName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),

                    const SizedBox(width: 20),

                    // =========================
                    // SUPERVISOR DROPDOWN
                    // =========================

                    Expanded(
                      flex: 2,
                      child: DropdownButtonFormField<int>(
                        decoration: const InputDecoration(
                          labelText: 'اختر الموجه',
                          border: OutlineInputBorder(),
                        ),
                        items: supervisors.map(
                          (
                            supervisor,
                          ) {
                            final id = _supervisorId(
                              supervisor,
                            );

                            return DropdownMenuItem<int>(
                              value: id,
                              child: Text(
                                _supervisorName(
                                  supervisor,
                                ),
                              ),
                            );
                          },
                        ).toList(),
                        onChanged: (supervisorId) async {
                          if (supervisorId == null) {
                            return;
                          }

                          await context.read<ClassCubit>().assignSupervisor(
                                classId: schoolClass.id,
                                supervisorId: supervisorId,
                              );

                          if (!mounted) {
                            return;
                          }

                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'تم تعيين الموجه للصف بنجاح ✅',
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
