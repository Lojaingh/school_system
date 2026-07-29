// lib/presentation/screen/assignment_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:school_management/constants/app_colors.dart';

import 'package:school_management/cubit/assignment/assignment_cubit.dart';

import 'package:school_management/data/model/subject_model.dart';
import 'package:school_management/data/repository/subject_repository.dart';
import 'package:school_management/data/services/subject_service.dart';

import '../screen/widgets/assignment_content.dart';
import 'package:school_management/data/model/assignment_model.dart';

class AssignmentScreen extends StatefulWidget {
  const AssignmentScreen({super.key});

  @override
  State<AssignmentScreen> createState() => _AssignmentScreenState();
}

class _AssignmentScreenState extends State<AssignmentScreen> {
  final SubjectRepository repository = SubjectRepository(SubjectService());

  List<SubjectModel> subjects = [];

  @override
  void initState() {
    super.initState();
    loadSubjects();
  }

  Future<void> loadSubjects() async {
    try {
      subjects = await repository.getSubjects();

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Assignments",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 2),
            Text(
              "Manage school assignments",
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              context.read<AssignmentCubit>().refreshAssignments();
            },
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: AssignmentContent(),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text("New Assignment"),
        onPressed: () => _showAddAssignmentDialog(),
      ),
    );
  }

  void _showAddAssignmentDialog() {
    final titleController = TextEditingController();
    final bodyController = TextEditingController();
    final dueDateController = TextEditingController();

    SubjectModel? selectedSubject;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: AppColors.cardBg,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text(
                "Create Assignment",
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SizedBox(
                width: 420,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextField(
                        controller: titleController,
                        style: const TextStyle(color: Colors.white),
                        decoration: _decoration("Title"),
                      ),
                      const SizedBox(height: 15),
                      TextField(
                        controller: bodyController,
                        maxLines: 4,
                        style: const TextStyle(color: Colors.white),
                        decoration: _decoration("Description"),
                      ),
                      const SizedBox(height: 15),
                      TextField(
                        controller: dueDateController,
                        readOnly: true,
                        style: const TextStyle(color: Colors.white),
                        decoration: _decoration("Due Date").copyWith(
                          suffixIcon: const Icon(
                            Icons.calendar_month,
                            color: Colors.white70,
                          ),
                        ),
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2035),
                            initialDate: DateTime.now(),
                          );

                          if (picked != null) {
                            dueDateController.text =
                                "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                          }
                        },
                      ),
                      const SizedBox(height: 15),
                      DropdownButtonFormField<SubjectModel>(
                        value: selectedSubject,
                        dropdownColor: AppColors.cardBg,
                        style: const TextStyle(color: Colors.white),
                        decoration: _decoration("Subject"),
                        items: subjects.map((subject) {
                          return DropdownMenuItem<SubjectModel>(
                            value: subject,
                            child: Text(subject.name),
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
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: const Text("Cancel"),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  icon: const Icon(Icons.add),
                  label: const Text("Create"),
                  onPressed: () {
                    if (selectedSubject == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Please select a subject"),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    context.read<AssignmentCubit>().addAssignment(
                          title: titleController.text.trim(),
                          body: bodyController.text.trim(),
                          dueDate: dueDateController.text.trim(),
                          subjectId: selectedSubject!.id,
                        );

                    Navigator.pop(dialogContext);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Assignment created successfully"),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ❌ ✅ حذف هذه الدالة (مكررة وغير مستخدمة)
  // void _showEditAssignmentDialog(Assignment assignment) { ... }

  InputDecoration _decoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      filled: true,
      fillColor: AppColors.cardElement,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: AppColors.cardBorder,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: AppColors.primary,
          width: 2,
        ),
      ),
    );
  }
}
