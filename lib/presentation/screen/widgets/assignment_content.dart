// lib/presentation/screen/widgets/assignment_content.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../constants/app_colors.dart';
import '../../../cubit/assignment/assignment_cubit.dart';
import '../../../cubit/assignment/assignment_state.dart';
import '../../../data/model/assignment_model.dart';
import '../../../data/model/subject_model.dart';
import '../../../data/repository/subject_repository.dart';
import '../../../data/services/subject_service.dart';

class AssignmentContent extends StatefulWidget {
  final bool showOnlyUpcoming;
  final int? limit;
  final String userRole;

  const AssignmentContent({
    super.key,
    this.showOnlyUpcoming = false,
    this.limit,
    required this.userRole,
  });

  @override
  State<AssignmentContent> createState() => _AssignmentContentState();
}

class _AssignmentContentState extends State<AssignmentContent> {
  bool _isFirstLoad = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_isFirstLoad) {
      final state = context.read<AssignmentCubit>().state;

      if (state is AssignmentInitial) {
        context.read<AssignmentCubit>().loadAssignments();
      }

      _isFirstLoad = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppGradients.backgroundGradient,
      ),
      child: BlocBuilder<AssignmentCubit, AssignmentState>(
        builder: (context, state) {
          if (state is AssignmentLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            );
          }

          if (state is AssignmentError) {
            return _ErrorWidget(
              message: state.message,
            );
          }

          if (state is AssignmentLoaded) {
            final assignments = widget.showOnlyUpcoming
                ? state.upcomingAssignments
                : state.assignments;

            final displayAssignments =
                widget.limit != null && assignments.length > widget.limit!
                    ? assignments.take(widget.limit!).toList()
                    : assignments;

            if (displayAssignments.isEmpty) {
              return const _EmptyAssignments();
            }

            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () async {
                await context.read<AssignmentCubit>().loadAssignments();
              },
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  const Text(
                    "Assignments",
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "Manage school assignments and homework",
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // STATISTICS
                  Row(
                    children: [
                      Expanded(
                        child: _TopCard(
                          title: "Total",
                          value: displayAssignments.length.toString(),
                          color: AppColors.cardBlue,
                          icon: Icons.assignment_rounded,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _TopCard(
                          title: "Upcoming",
                          value: displayAssignments
                              .where((e) => !e.isOverdue)
                              .length
                              .toString(),
                          color: AppColors.cardGreen,
                          icon: Icons.schedule,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _TopCard(
                          title: "Overdue",
                          value: displayAssignments
                              .where((e) => e.isOverdue)
                              .length
                              .toString(),
                          color: AppColors.error,
                          icon: Icons.warning_amber_rounded,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    "All Assignments",
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 18),
                  ...displayAssignments.map(
                    (assignment) => Padding(
                      padding: const EdgeInsets.only(bottom: 18),
                      // ✅ تمرير الـ userRole إلى الـ Card
                      child: _AssignmentCard(
                        assignment: assignment,
                        userRole: widget.userRole,
                      ),
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

class _TopCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _TopCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppGradients.cardGradient,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: AppShadows.cardShadow,
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: color.withOpacity(.15),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _AssignmentCard extends StatelessWidget {
  final Assignment assignment;
  final String userRole;

  const _AssignmentCard({
    required this.assignment,
    required this.userRole,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppGradients.cardGradient,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: AppShadows.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 52,
                width: 52,
                decoration: BoxDecoration(
                  color: assignment.hasFile
                      ? AppColors.cardOrange.withOpacity(.15)
                      : AppColors.cardBlue.withOpacity(.15),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  assignment.hasFile
                      ? Icons.attach_file_rounded
                      : Icons.assignment_rounded,
                  color: assignment.hasFile
                      ? AppColors.cardOrange
                      : AppColors.cardBlue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      assignment.title,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      assignment.subjectName.isNotEmpty
                          ? assignment.subjectName
                          : "Unknown Subject",
                      style: const TextStyle(
                        color: AppColors.primaryLight,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Subject ID: ${assignment.subjectId}",
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _StatusBadge(assignment: assignment),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (userRole == 'teacher') ...[
                        IconButton(
                          tooltip: "Edit",
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () {
                            _showEditAssignmentDialog(context, assignment);
                          },
                        ),
                        IconButton(
                          tooltip: "Delete",
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            _showDeleteDialog(context, assignment.id);
                          },
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            assignment.body,
            style: const TextStyle(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          Divider(color: AppColors.cardBorder.withOpacity(.6)),
          const SizedBox(height: 15),
          Row(
            children: [
              const Icon(Icons.calendar_today_rounded,
                  size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                assignment.dueDate,
                style: const TextStyle(color: AppColors.textPrimary),
              ),
              const Spacer(),
              const Icon(Icons.timer_outlined,
                  color: AppColors.warning, size: 18),
              const SizedBox(width: 6),
              Text(
                assignment.isOverdue
                    ? "Expired"
                    : "${assignment.daysRemaining.toInt()} days",
                style: TextStyle(
                  color: assignment.isOverdue
                      ? AppColors.error
                      : AppColors.warning,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          if (assignment.hasFile)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(.08),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.attach_file, color: AppColors.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        assignment.fileName ?? "Attachment",
                        style: const TextStyle(
                          color: AppColors.primaryLight,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Icon(Icons.open_in_new,
                        color: AppColors.primary, size: 18),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showEditAssignmentDialog(
    BuildContext context,
    Assignment assignment,
  ) {
    final titleController = TextEditingController(text: assignment.title);
    final bodyController = TextEditingController(text: assignment.body);
    final dueDateController = TextEditingController(text: assignment.dueDate);

    final subjectRepository = SubjectRepository(SubjectService());

    showDialog(
      context: context,
      builder: (dialogContext) {
        return FutureBuilder<List<SubjectModel>>(
          future: subjectRepository.getSubjects(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const AlertDialog(
                backgroundColor: AppColors.cardBg,
                content: SizedBox(
                  height: 100,
                  child: Center(
                      child:
                          CircularProgressIndicator(color: AppColors.primary)),
                ),
              );
            }

            final subjects = snapshot.data ?? [];
            SubjectModel? selectedSubject;
            for (final subject in subjects) {
              if (subject.id == assignment.subjectId) {
                selectedSubject = subject;
                break;
              }
            }

            return StatefulBuilder(
              builder: (context, setStateDialog) {
                return AlertDialog(
                  backgroundColor: AppColors.cardBg,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  title: const Text(
                    "Edit Assignment",
                    style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold),
                  ),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: titleController,
                          style: const TextStyle(color: Colors.white),
                          decoration: _decoration("Title"),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: bodyController,
                          maxLines: 3,
                          style: const TextStyle(color: Colors.white),
                          decoration: _decoration("Description"),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: dueDateController,
                          style: const TextStyle(color: Colors.white),
                          readOnly: true,
                          decoration: _decoration("Due Date").copyWith(
                            suffixIcon: const Icon(Icons.calendar_month,
                                color: Colors.white70),
                          ),
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2035),
                            );
                            if (picked != null) {
                              dueDateController.text =
                                  "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                            }
                          },
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<SubjectModel>(
                          value: selectedSubject,
                          dropdownColor: AppColors.cardBg,
                          style: const TextStyle(color: Colors.white),
                          decoration: _decoration("Subject"),
                          items: subjects.map((subject) {
                            return DropdownMenuItem<SubjectModel>(
                              value: subject,
                              child: Text("${subject.name} (${subject.id})"),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setStateDialog(() {
                              selectedSubject = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      child: const Text("Cancel"),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        final title = titleController.text.trim();
                        final body = bodyController.text.trim();
                        final dueDate = dueDateController.text.trim();

                        if (title.isEmpty &&
                            body.isEmpty &&
                            dueDate.isEmpty &&
                            selectedSubject == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Please change at least one field"),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        await context.read<AssignmentCubit>().updateAssignment(
                              id: assignment.id,
                              subjectId: selectedSubject?.id,
                              title: title.isNotEmpty ? title : null,
                              body: body.isNotEmpty ? body : null,
                              dueDate: dueDate.isNotEmpty ? dueDate : null,
                            );

                        if (!context.mounted) return;
                        Navigator.pop(dialogContext);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Assignment updated successfully"),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary),
                      child: const Text("Save"),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    int assignmentId,
  ) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "Delete Assignment",
          style: TextStyle(
              color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          "Are you sure you want to delete this assignment? This action cannot be undone.",
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await context
                  .read<AssignmentCubit>()
                  .deleteAssignment(assignmentId);
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Assignment deleted successfully"),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  InputDecoration _decoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      filled: true,
      fillColor: AppColors.cardElement,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.cardBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final Assignment assignment;

  const _StatusBadge({required this.assignment});

  @override
  Widget build(BuildContext context) {
    late Color color;
    late String text;

    if (assignment.isOverdue) {
      color = AppColors.error;
      text = "Overdue";
    } else if (assignment.daysRemaining <= 3) {
      color = AppColors.warning;
      text = "Due Soon";
    } else {
      color = AppColors.success;
      text = "Upcoming";
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(.15),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withOpacity(.4)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _EmptyAssignments extends StatelessWidget {
  const _EmptyAssignments();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assignment_outlined,
              size: 80,
              color: AppColors.textSecondary.withOpacity(.5),
            ),
            const SizedBox(height: 20),
            const Text(
              "No Assignments Yet",
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "There are no assignments available.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorWidget extends StatelessWidget {
  final String message;

  const _ErrorWidget({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded,
                color: AppColors.error, size: 72),
            const SizedBox(height: 18),
            const Text(
              "Something went wrong",
              style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 22),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 25),
            ElevatedButton.icon(
              onPressed: () {
                context.read<AssignmentCubit>().refreshAssignments();
              },
              icon: const Icon(Icons.refresh),
              label: const Text("Retry"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
