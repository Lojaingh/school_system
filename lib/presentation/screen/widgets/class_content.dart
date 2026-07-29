import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_management/data/model/student_profile_model.dart';
import '../../../cubit/class/class_cubit.dart';

import '../../../data/model/class_model.dart';

import '../../../constants/app_colors.dart';

class ClassContent extends StatelessWidget {
  final bool showOnlyYear;
  final int? year;

  const ClassContent({
    super.key,
    this.showOnlyYear = false,
    this.year,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ClassCubit, ClassState>(
      builder: (context, state) {
        if (state is ClassLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: CircularProgressIndicator(color: Colors.white),
            ),
          );
        } else if (state is ClassLoaded) {
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

          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
            itemCount: classes.length,
            itemBuilder: (context, index) {
              final classItem = classes[index];
              return _ClassCard(
                classItem: classItem,
                onTap: () {
                  _showClassDetailsSheet(context, classItem);
                },
                onDelete: () {
                  _showDeleteConfirmation(context, classItem.id);
                },
                onMove: () {
                  _showMoveStudentDialog(context, classItem.id);
                },
              );
            },
          );
        } else if (state is ClassError) {
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
                    style: TextStyle(color: Colors.white.withOpacity(0.6)),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ClassCubit>().refreshClasses();
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

  // ── حذف صف ──
  void _showDeleteConfirmation(BuildContext context, int classId) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1E2746),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title:
            const Text('Delete Class', style: TextStyle(color: Colors.white)),
        content: Text(
          'Are you sure you want to delete this class?',
          style: TextStyle(color: Colors.white.withOpacity(0.75)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cancel',
                style: TextStyle(color: Colors.white.withOpacity(0.7))),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<ClassCubit>().deleteClass(classId);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // ── ✅ معدّل: نقل طالب — هلق منستنى (await) النتيجة الحقيقية من الباك
  // ومنعرض رسالة نجاح/فشل مبنية فعلياً على شو صار، بدل ما نفترض النجاح
  // دايماً بمجرد إغلاق الـ Dialog.
  void _showMoveStudentDialog(BuildContext context, int currentClassId) {
    final studentIdController = TextEditingController();
    final targetClassIdController = TextEditingController();

    InputDecoration darkField(String label, String hint) => InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.35)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.primary),
          ),
        );

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1E2746),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title:
            const Text('Move Student', style: TextStyle(color: Colors.white)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: studentIdController,
                style: const TextStyle(color: Colors.white),
                decoration: darkField('Student ID', 'Enter student user_id'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: targetClassIdController,
                style: const TextStyle(color: Colors.white),
                decoration:
                    darkField('Target Class ID', 'Enter class id to move to'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cancel',
                style: TextStyle(color: Colors.white.withOpacity(0.7))),
          ),
          ElevatedButton(
            onPressed: () async {
              final studentId = int.tryParse(studentIdController.text.trim());
              final targetClassId =
                  int.tryParse(targetClassIdController.text.trim());

              if (studentId == null || targetClassId == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter valid IDs'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              // نسكر الـ Dialog قبل ما نستنى، حتى الواجهة تضل مستجيبة
              Navigator.pop(dialogContext);

              final cubit = context.read<ClassCubit>();

              // ✅ ننتظر فعلياً انتهاء العملية بالباك
              await cubit.moveStudent(
                userId: studentId,
                classId: targetClassId,
              );

              if (!context.mounted) return;

              // ✅ منشوف شو صارت حالة الـ Cubit فعلياً بعد الانتظار:
              // ClassLoaded = نجح ورجع حمّل الصفوف، ClassError = فشل فعلياً
              final resultState = cubit.state;
              if (resultState is ClassError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content:
                        Text('Failed to move student: ${resultState.message}'),
                    backgroundColor: Colors.red,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Student moved successfully!'),
                    backgroundColor: Colors.green,
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
      ),
    );
  }

  // ── ✅ عرض تفاصيل الصف (طلابه) كـ Bottom Sheet ──
  void _showClassDetailsSheet(BuildContext context, SchoolClass classItem) {
    final cubit = context.read<ClassCubit>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => BlocProvider.value(
        value: cubit,
        child: _ClassDetailsSheet(classItem: classItem),
      ),
    );
  }
}

// ── محتوى Bottom Sheet لتفاصيل الصف وطلابه ──
class _ClassDetailsSheet extends StatefulWidget {
  final SchoolClass classItem;

  const _ClassDetailsSheet({required this.classItem});

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
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                      icon: const Icon(Icons.refresh_rounded,
                          color: Colors.white70),
                      onPressed: () => setState(_loadStudents),
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
                        child: CircularProgressIndicator(color: Colors.white),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Text(
                            'Failed to load students: ${snapshot.error}',
                            style: TextStyle(color: Colors.red.shade300),
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
                          style:
                              TextStyle(color: Colors.white.withOpacity(0.5)),
                        ),
                      );
                    }

                    return ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      itemCount: students.length,
                      itemBuilder: (context, index) {
                        final s = students[index];
                        final fullName = '${s.firstName} ${s.lastName}'.trim();
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.08)),
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
                              if (s.healthStatus != null &&
                                  s.healthStatus!.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
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

// ── Class Card Widget (تصميم Glass غامق) ──
class _ClassCard extends StatelessWidget {
  final SchoolClass classItem;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onMove;

  const _ClassCard({
    required this.classItem,
    required this.onTap,
    required this.onDelete,
    required this.onMove,
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
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.primary.withOpacity(0.4)),
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
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 14,
                      runSpacing: 4,
                      children: [
                        _InfoChip(
                          icon: Icons.calendar_today_rounded,
                          label: 'Year: ${classItem.academicId}',
                        ),
                        _InfoChip(
                          icon: Icons.person_outline_rounded,
                          label: classItem.supervisorId != null
                              ? 'Supervisor: ${classItem.supervisorId}'
                              : 'No Supervisor',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onMove,
                icon: const Icon(Icons.swap_horiz_rounded,
                    color: Colors.lightBlueAccent),
                tooltip: 'Move Student',
              ),
              IconButton(
                onPressed: onDelete,
                icon: Icon(Icons.delete_outline_rounded,
                    color: Colors.red.shade300),
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

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.white.withOpacity(0.55)),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.6),
          ),
        ),
      ],
    );
  }
}
