import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_management/constants/app_colors.dart';
import 'package:school_management/cubit/assignment/assignment_cubit.dart';
import 'package:school_management/data/model/subject_model.dart';
import 'package:school_management/data/repository/assignment_repository.dart';
import 'package:school_management/data/repository/subject_repository.dart';
import 'package:school_management/data/services/subject_service.dart';
import 'package:school_management/utils/shared_prefs_helper.dart';
import '../screen/widgets/assignment_content.dart';

class AssignmentScreen extends StatefulWidget {
  const AssignmentScreen({
    super.key,
  });

  @override
  State<AssignmentScreen> createState() => _AssignmentScreenState();
}

class _AssignmentScreenState extends State<AssignmentScreen> {
  final SubjectRepository subjectRepository = SubjectRepository(
    SubjectService(),
  );

  final AssignmentRepository assignmentRepository = AssignmentRepository();

  List<SubjectModel> subjects = [];

  List<Map<String, dynamic>> classes = [];

  String userRole = '';

  bool isLoadingClasses = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _loadUserRole();

    if (!mounted) return;

    await loadSubjects();

    if (!mounted) return;

    if (_canManageAssignments) {
      await loadClasses();
    }
  }

  Future<void> _loadUserRole() async {
    final role = await SharedPrefsHelper.getRole();

    if (!mounted) return;

    setState(() {
      userRole = role?.trim().toLowerCase() ?? '';
    });

    print('🟣 ASSIGNMENT SCREEN ROLE: $userRole');
    print(
      '🟣 CAN MANAGE: $_canManageAssignments',
    );
  }

  bool get _isTeacher => userRole.toLowerCase() == 'teacher';

  bool get _isManager => userRole.toLowerCase() == 'manager';

  bool get _canManageAssignments => _isTeacher || _isManager;

  Future<void> loadSubjects() async {
    try {
      final result = await subjectRepository.getSubjects();

      if (!mounted) return;

      setState(() {
        subjects = result;
      });

      print(
        '🟢 Subjects loaded: ${subjects.length}',
      );
    } catch (e) {
      debugPrint(
        '❌ Error loading subjects: $e',
      );
    }
  }

  Future<void> loadClasses() async {
    if (!_canManageAssignments) return;

    if (userRole.isEmpty) return;

    if (!mounted) return;

    setState(() {
      isLoadingClasses = true;
    });

    print('════════════════════════════════');
    print('🔵 LOAD ASSIGNMENT CLASSES');
    print('🟣 ROLE: $userRole');

    try {
      final result = await assignmentRepository.getClasses(
        role: userRole,
      );

      if (!mounted) return;

      setState(() {
        classes = result;
        isLoadingClasses = false;
      });

      print(
        '🟢 Classes loaded: ${classes.length}',
      );

      for (final classItem in classes) {
        print(
          '   → ${_className(classItem)} | ID: ${_classId(classItem)}',
        );
      }

      print('════════════════════════════════');
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoadingClasses = false;
      });

      debugPrint(
        '❌ Error loading classes: $e',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final canManageAssignments = _canManageAssignments;

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

              if (_canManageAssignments) {
                loadClasses();
              }
            },
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
        ),
        child: AssignmentContent(
          userRole: userRole,
        ),
      ),
      floatingActionButton: canManageAssignments
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
          : null,
    );
  }

  void _showAddAssignmentDialog() {
    if (!_canManageAssignments) {
      return;
    }

    final titleController = TextEditingController();

    final bodyController = TextEditingController();

    final dueDateController = TextEditingController();

    SubjectModel? selectedSubject;

    Map<String, dynamic>? selectedClass;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (
            context,
            setStateDialog,
          ) {
            return AlertDialog(
              backgroundColor: AppColors.cardBg,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  20,
                ),
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
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                        decoration: _decoration(
                          "Title",
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      TextField(
                        controller: bodyController,
                        maxLines: 4,
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                        decoration: _decoration(
                          "Description",
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      TextField(
                        controller: dueDateController,
                        readOnly: true,
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                        decoration: _decoration(
                          "Due Date",
                        ).copyWith(
                          suffixIcon: const Icon(
                            Icons.calendar_month,
                            color: Colors.white70,
                          ),
                        ),
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            firstDate: DateTime.now(),
                            lastDate: DateTime(
                              2035,
                            ),
                            initialDate: DateTime.now(),
                          );

                          if (picked != null) {
                            dueDateController.text =
                                "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                          }
                        },
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      DropdownButtonFormField<SubjectModel>(
                        value: selectedSubject,
                        dropdownColor: AppColors.cardBg,
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                        decoration: _decoration(
                          "Subject",
                        ),
                        items: subjects.map(
                          (subject) {
                            return DropdownMenuItem<SubjectModel>(
                              value: subject,
                              child: Text(
                                "${subject.name} (${subject.id})",
                              ),
                            );
                          },
                        ).toList(),
                        onChanged: (value) {
                          setStateDialog(
                            () {
                              selectedSubject = value;
                            },
                          );
                        },
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      if (isLoadingClasses)
                        const Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: 10,
                          ),
                          child: CircularProgressIndicator(),
                        )
                      else
                        DropdownButtonFormField<Map<String, dynamic>>(
                          value: selectedClass,
                          dropdownColor: AppColors.cardBg,
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                          decoration: _decoration(
                            "Class",
                          ),
                          hint: const Text(
                            "Select class",
                            style: TextStyle(
                              color: Colors.white70,
                            ),
                          ),
                          items: classes.map(
                            (classItem) {
                              return DropdownMenuItem<Map<String, dynamic>>(
                                value: classItem,
                                child: Text(
                                  _className(
                                    classItem,
                                  ),
                                ),
                              );
                            },
                          ).toList(),
                          onChanged: (value) {
                            setStateDialog(
                              () {
                                selectedClass = value;
                              },
                            );
                          },
                        ),
                      const SizedBox(
                        height: 8,
                      ),
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
                      if (selectedClass != null)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Class ID: ${_classId(selectedClass!)}",
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
                  onPressed: () {
                    Navigator.pop(
                      dialogContext,
                    );
                  },
                  child: const Text(
                    "Cancel",
                  ),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  icon: const Icon(
                    Icons.add,
                  ),
                  label: const Text(
                    "Create",
                  ),
                  onPressed: () async {
                    final title = titleController.text.trim();

                    final body = bodyController.text.trim();

                    final dueDate = dueDateController.text.trim();

                    if (title.isEmpty) {
                      _showError(
                        context,
                        "Please enter a title",
                      );
                      return;
                    }

                    if (body.isEmpty) {
                      _showError(
                        context,
                        "Please enter a description",
                      );
                      return;
                    }

                    if (dueDate.isEmpty) {
                      _showError(
                        context,
                        "Please select a due date",
                      );
                      return;
                    }

                    if (selectedSubject == null) {
                      _showError(
                        context,
                        "Please select a subject",
                      );
                      return;
                    }

                    if (selectedClass == null) {
                      _showError(
                        context,
                        "Please select a class",
                      );
                      return;
                    }

                    final classId = _classId(
                      selectedClass!,
                    );

                    if (classId == null) {
                      _showError(
                        context,
                        "Invalid class",
                      );
                      return;
                    }

                    print(
                      '📤 Creating assignment as: $userRole',
                    );

                    print(
                      '📤 Subject ID: ${selectedSubject!.id}',
                    );

                    print(
                      '📤 Class ID: $classId',
                    );

                    await context.read<AssignmentCubit>().addAssignment(
                          title: title,
                          body: body,
                          dueDate: dueDate,
                          subjectId: selectedSubject!.id,
                          schoolClassId: classId,
                        );

                    if (!context.mounted) {
                      return;
                    }

                    Navigator.pop(
                      dialogContext,
                    );

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Assignment created successfully",
                        ),
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

  String _className(
    Map<String, dynamic> item,
  ) {
    if (item['name'] != null) {
      return item['name'].toString();
    }

    if (item['label'] != null) {
      return item['label'].toString();
    }

    final year = item['year'];
    final number = item['number'];

    if (year != null && number != null) {
      return 'Grade $year - Section $number';
    }

    return 'Class ${item['id']}';
  }

  int? _classId(
    Map<String, dynamic> item,
  ) {
    final value = item['id'];

    if (value is int) {
      return value;
    }

    return int.tryParse(
      value?.toString() ?? '',
    );
  }

  void _showError(
    BuildContext context,
    String message,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  InputDecoration _decoration(
    String label,
  ) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(
        color: Colors.white70,
      ),
      filled: true,
      fillColor: AppColors.cardElement,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
          14,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
          14,
        ),
        borderSide: const BorderSide(
          color: AppColors.cardBorder,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
          14,
        ),
        borderSide: const BorderSide(
          color: AppColors.primary,
          width: 2,
        ),
      ),
    );
  }
}
