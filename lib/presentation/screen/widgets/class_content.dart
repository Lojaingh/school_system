import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_management/data/model/student_profile_model.dart';

import '../../../cubit/class/class_cubit.dart';
import '../../../data/model/class_model.dart';
import '../../../constants/app_colors.dart';

class ClassContent extends StatefulWidget {
  final bool showOnlyYear;
  final int? year;

  const ClassContent({
    super.key,
    this.showOnlyYear = false,
    this.year,
  });

  @override
  State<ClassContent> createState() => _ClassContentState();
}

class _ClassContentState extends State<ClassContent> {
  late Future<List<Map<String, dynamic>>> _supervisorsFuture;

  @override
  void initState() {
    super.initState();
    _loadSupervisors();
  }

  void _loadSupervisors() {
    _supervisorsFuture = context.read<ClassCubit>().getSupervisors();
  }

  String _getSupervisorName(Map<String, dynamic> supervisor) {
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

  int? _getSupervisorId(Map<String, dynamic> supervisor) {
    final value =
        supervisor['user_id'] ?? supervisor['id'] ?? supervisor['userId'];

    if (value is int) {
      return value;
    }

    return int.tryParse(value?.toString() ?? '');
  }

  String _findSupervisorName(
    List<Map<String, dynamic>> supervisors,
    int? supervisorId,
  ) {
    if (supervisorId == null) {
      return 'No Supervisor';
    }

    for (final supervisor in supervisors) {
      final id = _getSupervisorId(supervisor);

      if (id == supervisorId) {
        return _getSupervisorName(supervisor);
      }
    }

    return 'Supervisor #$supervisorId';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ClassCubit, ClassState>(
      builder: (context, state) {
        if (state is ClassLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            ),
          );
        }

        if (state is ClassLoaded) {
          final classes = state.classes;

          if (classes.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.class_outlined,
                      size: 48,
                      color: Colors.white.withOpacity(0.5),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No classes found',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.85),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap the + button to add a class',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return FutureBuilder<List<Map<String, dynamic>>>(
            future: _supervisorsFuture,
            builder: (context, supervisorSnapshot) {
              final supervisors = supervisorSnapshot.data ?? [];

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
                itemCount: classes.length,
                itemBuilder: (context, index) {
                  final classItem = classes[index];

                  return _ClassCard(
                    classItem: classItem,
                    supervisorName: _findSupervisorName(
                      supervisors,
                      classItem.supervisorId,
                    ),
                    onTap: () {
                      _showClassDetailsSheet(
                        context,
                        classItem,
                      );
                    },
                    onDelete: () {
                      _showDeleteConfirmation(
                        context,
                        classItem.id,
                      );
                    },
                    onMove: () {
                      _showMoveStudentDialog(
                        context,
                        classItem.id,
                      );
                    },
                    onEditSupervisor: () {
                      _showEditSupervisorDialog(
                        context,
                        classItem,
                        supervisors,
                      );
                    },
                  );
                },
              );
            },
          );
        }

        if (state is ClassError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    size: 48,
                    color: Colors.red.shade300,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Error loading classes',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.red.shade300,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ClassCubit>().refreshClasses();
                      _loadSupervisors();
                      setState(() {});
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  // ============================================================
  // DELETE CLASS
  // ============================================================

  void _showDeleteConfirmation(
    BuildContext context,
    int classId,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1E2746),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Delete Class',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        content: Text(
          'Are you sure you want to delete this class?',
          style: TextStyle(
            color: Colors.white.withOpacity(0.75),
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
              Navigator.pop(dialogContext);

              context.read<ClassCubit>().deleteClass(classId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // EDIT SUPERVISOR
  // ============================================================

  void _showEditSupervisorDialog(
    BuildContext context,
    SchoolClass classItem,
    List<Map<String, dynamic>> supervisors,
  ) {
    int? selectedSupervisorId;

    final supervisorIds =
        supervisors.map(_getSupervisorId).whereType<int>().toSet();

    if (classItem.supervisorId != null &&
        supervisorIds.contains(classItem.supervisorId)) {
      selectedSupervisorId = classItem.supervisorId;
    }

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1E2746),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              title: const Row(
                children: [
                  Icon(
                    Icons.manage_accounts_rounded,
                    color: AppColors.primary,
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Edit Supervisor',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    classItem.displayName,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 16),
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
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    items: [
                      const DropdownMenuItem<int>(
                        value: -1,
                        child: Text(
                          'No Supervisor',
                          style: TextStyle(
                            color: Colors.white70,
                          ),
                        ),
                      ),
                      ...{
                        for (final supervisor in supervisors)
                          if (_getSupervisorId(supervisor) != null)
                            _getSupervisorId(supervisor)!: supervisor,
                      }.values.map(
                        (supervisor) {
                          final id = _getSupervisorId(supervisor)!;

                          return DropdownMenuItem<int>(
                            value: id,
                            child: Text(
                              _getSupervisorName(supervisor),
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                    onChanged: (value) {
                      setStateDialog(() {
                        selectedSupervisorId = value == -1 ? null : value;
                      });
                    },
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
                  onPressed: () async {
                    try {
                      await context.read<ClassCubit>().updateClassSupervisor(
                            classId: classItem.id,
                            supervisorId: selectedSupervisorId,
                          );

                      if (!dialogContext.mounted) return;

                      Navigator.pop(dialogContext);

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Supervisor updated successfully!',
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );

                      context.read<ClassCubit>().refreshClasses();

                      _loadSupervisors();
                      if (mounted) {
                        setState(() {});
                      }
                    } catch (e) {
                      if (!dialogContext.mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Failed to update supervisor: $e',
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ============================================================
  // MOVE STUDENT
  // ============================================================

  void _showMoveStudentDialog(
    BuildContext context,
    int currentClassId,
  ) {
    final cubit = context.read<ClassCubit>();

    final studentsFuture = cubit.fetchAllStudents();
    final classesFuture = cubit.fetchAllClasses();

    int? selectedStudentId;
    int? selectedClassId;

    showDialog(
      context: context,
      builder: (dialogContext) => FutureBuilder(
        future: Future.wait([
          studentsFuture,
          classesFuture,
        ]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const AlertDialog(
              backgroundColor: Color(0xFF1E2746),
              content: Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              ),
            );
          }

          if (snapshot.hasError) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1E2746),
              title: const Text(
                'Error',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              content: Text(
                'Failed to load data: ${snapshot.error}',
                style: const TextStyle(
                  color: Colors.white70,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Close'),
                ),
              ],
            );
          }

          final students =
              snapshot.data?[0] as List<StudentProfileModel>? ?? [];

          final classes = snapshot.data?[1] as List<SchoolClass>? ?? [];

          final currentClassStudents = students
              .where(
                (student) => student.classId == currentClassId,
              )
              .toList();

          if (currentClassStudents.isEmpty) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1E2746),
              title: const Text(
                'No Students',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              content: const Text(
                'No students in this class to move',
                style: TextStyle(
                  color: Colors.white70,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Close'),
                ),
              ],
            );
          }

          final targetClasses = classes
              .where(
                (classItem) => classItem.id != currentClassId,
              )
              .toList();

          return StatefulBuilder(
            builder: (context, setStateDialog) {
              return AlertDialog(
                backgroundColor: const Color(0xFF1E2746),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title: const Text(
                  'Move Student',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<int>(
                      value: selectedStudentId,
                      dropdownColor: const Color(0xFF1E2746),
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                      hint: Text(
                        'Select Student',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                        ),
                      ),
                      decoration: InputDecoration(
                        labelText: 'Student',
                        labelStyle: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: Colors.white.withOpacity(0.2),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      items: currentClassStudents.map(
                        (student) {
                          return DropdownMenuItem<int>(
                            value: student.userId,
                            child: Text(
                              student.fullName,
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          );
                        },
                      ).toList(),
                      onChanged: (value) {
                        setStateDialog(() {
                          selectedStudentId = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      value: selectedClassId,
                      dropdownColor: const Color(0xFF1E2746),
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                      hint: Text(
                        'Select Target Class',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                        ),
                      ),
                      decoration: InputDecoration(
                        labelText: 'Target Class',
                        labelStyle: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: Colors.white.withOpacity(0.2),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      items: targetClasses.map(
                        (classItem) {
                          return DropdownMenuItem<int>(
                            value: classItem.id,
                            child: Text(
                              classItem.displayName,
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          );
                        },
                      ).toList(),
                      onChanged: (value) {
                        setStateDialog(() {
                          selectedClassId = value;
                        });
                      },
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
                      if (selectedStudentId != null &&
                          selectedClassId != null) {
                        cubit.moveStudent(
                          userId: selectedStudentId!,
                          classId: selectedClassId!,
                        );

                        Navigator.pop(dialogContext);

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Student moved successfully!',
                            ),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Please select both student and target class',
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Move'),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  // ============================================================
  // CLASS DETAILS
  // ============================================================

  void _showClassDetailsSheet(
    BuildContext context,
    SchoolClass classItem,
  ) {
    final cubit = context.read<ClassCubit>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => BlocProvider.value(
        value: cubit,
        child: _ClassDetailsSheet(
          classItem: classItem,
        ),
      ),
    );
  }
}

// ============================================================
// CLASS DETAILS SHEET
// ============================================================

class _ClassDetailsSheet extends StatefulWidget {
  final SchoolClass classItem;

  const _ClassDetailsSheet({
    required this.classItem,
  });

  @override
  State<_ClassDetailsSheet> createState() => _ClassDetailsSheetState();
}

class _ClassDetailsSheetState extends State<_ClassDetailsSheet> {
  late Future<List<StudentProfileModel>> _studentsFuture;

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  void _loadStudents() {
    _studentsFuture = context.read<ClassCubit>().getStudentsForClass(
          widget.classItem.id,
          widget.classItem.year,
        );
  }

  void _showMoveStudentDialog(
    BuildContext context,
    int currentClassId, {
    StudentProfileModel? student,
  }) {
    final cubit = context.read<ClassCubit>();

    final classesFuture = cubit.fetchAllClasses();

    int? selectedClassId;

    showDialog(
      context: context,
      builder: (dialogContext) => FutureBuilder<List<SchoolClass>>(
        future: classesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const AlertDialog(
              backgroundColor: Color(0xFF1E2746),
              content: Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              ),
            );
          }

          if (snapshot.hasError) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1E2746),
              title: const Text(
                'Error',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              content: Text(
                'Failed to load classes: ${snapshot.error}',
                style: const TextStyle(
                  color: Colors.white70,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Close'),
                ),
              ],
            );
          }

          final classes = snapshot.data ?? [];

          final targetClasses = classes
              .where(
                (c) => c.id != currentClassId,
              )
              .toList();

          if (targetClasses.isEmpty) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1E2746),
              title: const Text(
                'No Classes',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              content: const Text(
                'No other classes available to move the student to',
                style: TextStyle(
                  color: Colors.white70,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Close'),
                ),
              ],
            );
          }

          return StatefulBuilder(
            builder: (context, setStateDialog) {
              return AlertDialog(
                backgroundColor: const Color(0xFF1E2746),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title: const Text(
                  'Move Student',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (student != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.person_rounded,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Moving: ${student.fullName}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      value: selectedClassId,
                      dropdownColor: const Color(0xFF1E2746),
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                      hint: Text(
                        'Select Target Class',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                        ),
                      ),
                      decoration: InputDecoration(
                        labelText: 'Target Class',
                        labelStyle: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: Colors.white.withOpacity(0.2),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      items: targetClasses.map(
                        (classItem) {
                          return DropdownMenuItem<int>(
                            value: classItem.id,
                            child: Text(
                              classItem.displayName,
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          );
                        },
                      ).toList(),
                      onChanged: (value) {
                        setStateDialog(() {
                          selectedClassId = value;
                        });
                      },
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
                      if (selectedClassId != null && student != null) {
                        cubit.moveStudent(
                          userId: student.userId!,
                          classId: selectedClassId!,
                        );

                        Navigator.pop(dialogContext);

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Student moved successfully!',
                            ),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Please select a target class',
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Move'),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.35,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF12183A),
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(24),
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.classItem.displayName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.refresh_rounded,
                        color: Colors.white70,
                      ),
                      onPressed: () {
                        setState(_loadStudents);
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: FutureBuilder<List<StudentProfileModel>>(
                  future: _studentsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Text(
                            'Failed to load students: ${snapshot.error}',
                            style: TextStyle(
                              color: Colors.red.shade300,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    }

                    final students = snapshot.data ?? [];

                    if (students.isEmpty) {
                      return Center(
                        child: Text(
                          'No students in this class yet',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(
                        16,
                        8,
                        16,
                        24,
                      ),
                      itemCount: students.length,
                      itemBuilder: (context, index) {
                        final s = students[index];

                        final fullName = '${s.firstName} ${s.lastName}'.trim();

                        return Container(
                          margin: const EdgeInsets.only(
                            bottom: 10,
                          ),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.08),
                            ),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundColor:
                                    AppColors.primary.withOpacity(0.2),
                                child: Text(
                                  fullName.isNotEmpty
                                      ? fullName[0].toUpperCase()
                                      : '?',
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      fullName.isEmpty ? 'Unnamed' : fullName,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'ID: ${s.userId ?? '-'}  •  ${s.gender}',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.5),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.swap_horiz_rounded,
                                  color: Colors.lightBlueAccent,
                                ),
                                tooltip: 'Move Student',
                                onPressed: () {
                                  Navigator.pop(context);

                                  _showMoveStudentDialog(
                                    context,
                                    widget.classItem.id,
                                    student: s,
                                  );
                                },
                              ),
                              if (s.healthStatus != null &&
                                  s.healthStatus!.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        Colors.orangeAccent.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    s.healthStatus!,
                                    style: const TextStyle(
                                      color: Colors.orangeAccent,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ============================================================
// CLASS CARD
// ============================================================

class _ClassCard extends StatelessWidget {
  final SchoolClass classItem;
  final String supervisorName;

  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onMove;
  final VoidCallback onEditSupervisor;

  const _ClassCard({
    required this.classItem,
    required this.supervisorName,
    required this.onTap,
    required this.onDelete,
    required this.onMove,
    required this.onEditSupervisor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.06),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.4),
                  ),
                ),
                child: Center(
                  child: Text(
                    classItem.shortName,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      classItem.displayName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Wrap(
                      spacing: 14,
                      runSpacing: 5,
                      children: [
                        _InfoChip(
                          icon: Icons.calendar_today_rounded,
                          label: 'Year: ${classItem.academicId}',
                        ),
                        _InfoChip(
                          icon: Icons.person_outline_rounded,
                          label: supervisorName,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Edit Supervisor
              IconButton(
                onPressed: onEditSupervisor,
                icon: const Icon(
                  Icons.manage_accounts_outlined,
                  color: Colors.lightBlueAccent,
                ),
                tooltip: 'Edit Supervisor',
              ),

              // Move Student
              IconButton(
                onPressed: onMove,
                icon: const Icon(
                  Icons.swap_horiz_rounded,
                  color: Colors.lightBlueAccent,
                ),
                tooltip: 'Move Student',
              ),

              // Delete
              IconButton(
                onPressed: onDelete,
                icon: Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.red.shade300,
                ),
                tooltip: 'Delete Class',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: Colors.white.withOpacity(0.55),
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.6),
            ),
          ),
        ),
      ],
    );
  }
}
