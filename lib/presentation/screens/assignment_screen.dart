// lib/presentation/screen/assignment_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:school_management/constants/app_colors.dart';

import 'package:school_management/cubit/assignment/assignment_cubit.dart';

import 'package:school_management/data/model/subject_model.dart';
import 'package:school_management/data/repository/subject_repository.dart';
import 'package:school_management/data/services/subject_service.dart';
import 'package:school_management/utils/shared_prefs_helper.dart'; // ✅ استيراد الـ SharedPrefs

import '../screen/widgets/assignment_content.dart';

class AssignmentScreen extends StatefulWidget {
  const AssignmentScreen({
    super.key,
  });

  @override
  State<AssignmentScreen> createState() => _AssignmentScreenState();
}

class _AssignmentScreenState extends State<AssignmentScreen> {
  final SubjectRepository repository = SubjectRepository(
    SubjectService(),
  );

  List<SubjectModel> subjects = [];
  String userRole = ''; // ✅ متغير لحفظ الدور الحالي

  @override
  void initState() {
    super.initState();
    _loadUserRole(); // ✅ جلب الدور عند فتح الصفحة
    loadSubjects();
  }

  // ✅ دالة لجلب الدور الحقيقي من الـ SharedPrefs
  Future<void> _loadUserRole() async {
    final role = await SharedPrefsHelper.getRole();
    if (mounted) {
      setState(() {
        userRole = role ??
            ''; // إذا كان فارغاً، اجعله فارغاً لكي لا يظهر الزر بشكل خاطئ
      });
    }
  }

  // ============================================================
  // LOAD SUBJECTS
  // ============================================================

  Future<void> loadSubjects() async {
    try {
      final result = await repository.getSubjects();

      if (!mounted) return;

      setState(() {
        subjects = result;
      });
    } catch (e) {
      debugPrint(
        '❌ Error loading subjects: $e',
      );
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

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
            icon: const Icon(
              Icons.refresh_rounded,
            ),
            onPressed: () {
              context.read<AssignmentCubit>().refreshAssignments();
              loadSubjects();
            },
          ),
          const SizedBox(width: 10),
        ],
      ),
      // ✅ نمرر الـ userRole للـ AssignmentContent
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
        ),
        child: AssignmentContent(userRole: userRole),
      ),

      // ============================================================
      // التعديل: الزر يظهر فقط إذا كان المستخدم 'teacher'
      // (المدير 'manager' لن يرى الزر إطلاقاً)
      // ============================================================
      floatingActionButton: userRole == 'teacher'
          ? FloatingActionButton.extended(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              icon: const Icon(
                Icons.add,
              ),
              label: const Text(
                "New Assignment",
              ),
              onPressed: _showAddAssignmentDialog,
            )
          : null, // إخفاء الزر
    );
  }

  // ============================================================
  // ADD ASSIGNMENT DIALOG (بقية الكود كما هو تماماً دون تغيير)
  // ============================================================

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
                          suffixIcon: const Icon(Icons.calendar_month,
                              color: Colors.white70),
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
                            child: Text("${subject.name} (${subject.id})"),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setStateDialog(() {
                            selectedSubject = value;
                          });
                        },
                      ),
                      const SizedBox(height: 8),
                      if (selectedSubject != null)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Subject ID: ${selectedSubject!.id}",
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text("Cancel"),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  icon: const Icon(Icons.add),
                  label: const Text("Create"),
                  onPressed: () async {
                    final title = titleController.text.trim();
                    final body = bodyController.text.trim();
                    final dueDate = dueDateController.text.trim();

                    if (title.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text("Please enter a title"),
                            backgroundColor: Colors.red),
                      );
                      return;
                    }
                    if (body.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text("Please enter a description"),
                            backgroundColor: Colors.red),
                      );
                      return;
                    }
                    if (dueDate.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text("Please select a due date"),
                            backgroundColor: Colors.red),
                      );
                      return;
                    }
                    if (selectedSubject == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text("Please select a subject"),
                            backgroundColor: Colors.red),
                      );
                      return;
                    }

                    await context.read<AssignmentCubit>().addAssignment(
                          title: title,
                          body: body,
                          dueDate: dueDate,
                          subjectId: selectedSubject!.id,
                        );

                    if (!context.mounted) return;
                    Navigator.pop(dialogContext);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text("Assignment created successfully"),
                          backgroundColor: Colors.green),
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
