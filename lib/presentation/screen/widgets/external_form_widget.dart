import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:school_management/constants/app_colors.dart';
import 'package:school_management/cubit/external/external_cubit.dart';
import 'package:school_management/cubit/external/external_state.dart';
import 'package:school_management/data/model/external_model.dart';
import 'package:school_management/data/model/school_class_model.dart';
import 'package:school_management/utils/shared_prefs_helper.dart';

class ExternalFormWidget extends StatefulWidget {
  final ExternalModel? external;

  /// true إذا المستخدم Teacher
  /// false إذا Manager
  final bool isTeacher;

  const ExternalFormWidget({
    super.key,
    this.external,
    this.isTeacher = false,
    required bool isManager,
  });

  bool get isEdit => external != null;

  @override
  State<ExternalFormWidget> createState() => _ExternalFormWidgetState();
}

class _ExternalFormWidgetState extends State<ExternalFormWidget> {
  int? schoolClassId;

  PlatformFile? selectedFile;

  final TextEditingController notesController = TextEditingController();

  bool _submitted = false;

  List<SchoolClassModel> classes = [];

  bool classesLoading = true;

  @override
  void initState() {
    super.initState();

    // إذا تعديل، نعبّي البيانات القديمة
    if (widget.external != null) {
      schoolClassId = widget.external!.schoolClassId;
      notesController.text = widget.external!.notes ?? "";

      print("🟣 EDIT EXTERNAL");
      print("🟣 External ID: ${widget.external!.id}");
      print("🟣 Old class ID: $schoolClassId");
      print("🟣 Old notes: ${notesController.text}");
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      print("🟣 EXTERNAL FORM INITIALIZED");
      print("🟣 isTeacher: ${widget.isTeacher}");

      _loadClasses();
    });
  }

  Future<void> _loadClasses() async {
    try {
      final role = await SharedPrefsHelper.getRole();

      if (!mounted) return;

      final normalizedRole = role?.trim().toLowerCase();

      print("════════════════════════════════");
      print("🟣 EXTERNAL FORM - LOAD CLASSES");
      print("🟣 ROLE FROM SHARED PREFS: $role");
      print("🟣 NORMALIZED ROLE: $normalizedRole");
      print("🟣 WIDGET isTeacher: ${widget.isTeacher}");
      print("════════════════════════════════");

      setState(() {
        classesLoading = true;
        classes = [];
      });

      final cubit = context.read<ExternalCubit>();

      if (normalizedRole == "teacher") {
        print("🔵 CALLING getTeacherClasses()");
        await cubit.getTeacherClasses();
      } else if (normalizedRole == "manager") {
        print("🔵 CALLING getAllClasses()");
        await cubit.getAllClasses();
      } else {
        print("🔴 UNKNOWN ROLE: $normalizedRole");

        if (!mounted) return;

        setState(() {
          classesLoading = false;
        });
      }
    } catch (e, stackTrace) {
      print("🔴 LOAD CLASSES ERROR: $e");
      print(stackTrace);

      if (!mounted) return;

      setState(() {
        classesLoading = false;
      });
    }
  }

  @override
  void dispose() {
    notesController.dispose();
    super.dispose();
  }

  Future<void> pickFile() async {
    if (_submitted) return;

    print("🟣 OPENING FILE PICKER...");

    final result = await FilePicker.pickFiles(
      type: FileType.any,
      allowMultiple: false,
      withData: true,
    );

    if (result == null || result.files.isEmpty) {
      print("🟡 FILE PICKER CANCELLED");
      return;
    }

    if (!mounted) return;

    setState(() {
      selectedFile = result.files.first;
    });

    print("🟢 SELECTED FILE: ${selectedFile!.name}");
    print("🟢 FILE SIZE: ${selectedFile!.size}");
    print("🟢 FILE EXTENSION: ${selectedFile!.extension}");
  }

  void submit() {
    if (_submitted) return;

    print("════════════════════════════════");
    print("🟣 SUBMIT EXTERNAL");
    print("🟣 schoolClassId: $schoolClassId");
    print("🟣 selectedFile: ${selectedFile?.name}");
    print("🟣 notes: ${notesController.text}");
    print("🟣 isEdit: ${widget.isEdit}");
    print("════════════════════════════════");

    if (schoolClassId == null) {
      print("🔴 schoolClassId IS NULL");

      _showMessage("Please select a school class");
      return;
    }

    if (!widget.isEdit && selectedFile == null) {
      print("🔴 FILE IS NULL");

      _showMessage("Please select a file");
      return;
    }

    setState(() {
      _submitted = true;
    });

    final cubit = context.read<ExternalCubit>();

    if (widget.isEdit) {
      print("🔵 UPDATING EXTERNAL...");

      cubit.updateExternal(
        id: widget.external!.id,
        schoolClassId: schoolClassId,
        file: selectedFile,
        notes: notesController.text.trim(),
      );
    } else {
      print("🔵 ADDING EXTERNAL...");

      cubit.addExternal(
        schoolClassId: schoolClassId!,
        file: selectedFile!,
        notes: notesController.text.trim(),
      );
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ExternalCubit, ExternalState>(
      listener: (context, state) {
        print("🟡 FORM STATE: ${state.runtimeType}");

        // =========================
        // TEACHER CLASSES
        // =========================
        if (state is TeacherClassesLoaded) {
          print("════════════════════════════════");
          print("🟢 TEACHER CLASSES RECEIVED");
          print("🟢 COUNT: ${state.classes.length}");

          for (final item in state.classes) {
            print(
              "➡️ id=${item.id}, "
              "label=${item.label}, "
              "year=${item.year}, "
              "number=${item.number}",
            );
          }

          print("════════════════════════════════");

          if (!mounted) return;

          setState(() {
            classes = List<SchoolClassModel>.from(state.classes);
            classesLoading = false;

            // إذا الصف القديم غير موجود بالقائمة
            if (schoolClassId != null &&
                !classes.any((item) => item.id == schoolClassId)) {
              print(
                "🟡 OLD CLASS ID $schoolClassId NOT FOUND IN TEACHER CLASSES",
              );

              schoolClassId = null;
            }
          });

          return;
        }

        // =========================
        // MANAGER CLASSES
        // =========================
        if (state is AllClassesLoaded) {
          print("════════════════════════════════");
          print("🟢 ALL CLASSES RECEIVED");
          print("🟢 COUNT: ${state.classes.length}");

          for (final item in state.classes) {
            print(
              "➡️ id=${item.id}, "
              "label=${item.label}, "
              "year=${item.year}, "
              "number=${item.number}",
            );
          }

          print("════════════════════════════════");

          if (!mounted) return;

          setState(() {
            classes = List<SchoolClassModel>.from(state.classes);
            classesLoading = false;

            if (schoolClassId != null &&
                !classes.any((item) => item.id == schoolClassId)) {
              print(
                "🟡 OLD CLASS ID $schoolClassId NOT FOUND IN ALL CLASSES",
              );

              schoolClassId = null;
            }
          });

          return;
        }

        // =========================
        // ADD SUCCESS
        // =========================
        if (state is ExternalAddSuccess) {
          print("🟢 EXTERNAL ADDED SUCCESSFULLY");

          Navigator.pop(context, true);
          return;
        }

        // =========================
        // UPDATE SUCCESS
        // =========================
        if (state is ExternalUpdateSuccess) {
          print("🟢 EXTERNAL UPDATED SUCCESSFULLY");

          Navigator.pop(context, true);
          return;
        }

        // =========================
        // ERROR
        // =========================
        if (state is ExternalError) {
          print("🔴 EXTERNAL FORM ERROR:");
          print(state.message);

          if (mounted) {
            setState(() {
              _submitted = false;
            });

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.redAccent,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }

          return;
        }
      },
      builder: (context, state) {
        final bool loading = state is ExternalAddLoading ||
            state is ExternalUpdateLoading ||
            _submitted;

        print(
          "🟡 BUILD FORM | "
          "classes=${classes.length} | "
          "classesLoading=$classesLoading | "
          "selectedClassId=$schoolClassId | "
          "loading=$loading",
        );

        SchoolClassModel? selectedClass;

        if (schoolClassId != null) {
          for (final item in classes) {
            if (item.id == schoolClassId) {
              selectedClass = item;
              break;
            }
          }
        }

        return Container(
          width: 600,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: AppGradients.cardGradient,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.cardBorder,
            ),
            boxShadow: AppShadows.cardShadow,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // =========================
                // HEADER
                // =========================
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.folder_copy_outlined,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.isEdit ? "Edit External" : "Add External",
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: loading ? null : () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.close,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 25),

                // =========================
                // SCHOOL CLASS
                // =========================
                if (classesLoading)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 18,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.cardElement,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.cardBorder.withOpacity(.3),
                      ),
                    ),
                    child: const Row(
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                            strokeWidth: 2,
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          "Loading school classes...",
                          style: TextStyle(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  )
                else if (classes.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 18,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.cardElement,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.redAccent.withOpacity(.3),
                      ),
                    ),
                    child: const Text(
                      "No school classes available",
                      style: TextStyle(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  )
                else
                  _dropdown<SchoolClassModel>(
                    label: "School Class",
                    value: selectedClass,
                    items: classes,
                    itemLabel: (item) {
                      final label = item.label;

                      print(
                        "🟢 DROPDOWN ITEM → "
                        "id=${item.id}, "
                        "label=$label",
                      );

                      if (label != null && label.trim().isNotEmpty) {
                        return label;
                      }

                      return "Class ${item.id}";
                    },
                    onChanged: loading
                        ? null
                        : (value) {
                            print("════════════════════════════════");
                            print("🔵 DROPDOWN CHANGED");
                            print("🔵 VALUE: $value");

                            if (value == null) {
                              print("🔴 SELECTED VALUE IS NULL");
                              return;
                            }

                            print("🟢 SELECTED CLASS ID: ${value.id}");
                            print("🟢 SELECTED CLASS LABEL: ${value.label}");

                            setState(() {
                              schoolClassId = value.id;
                            });

                            print(
                              "🟢 schoolClassId AFTER SET: $schoolClassId",
                            );
                            print("════════════════════════════════");
                          },
                  ),

                const SizedBox(height: 16),

                // =========================
                // FILE
                // =========================
                InkWell(
                  onTap: loading ? null : pickFile,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.cardElement,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.cardBorder.withOpacity(.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.upload_file_outlined,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            selectedFile != null
                                ? selectedFile!.name
                                : widget.isEdit
                                    ? "Choose new file (optional)"
                                    : "Choose file",
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Icon(
                          Icons.attach_file,
                          color: AppColors.textHelper,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // =========================
                // NOTES
                // =========================
                TextField(
                  controller: notesController,
                  maxLines: 4,
                  enabled: !loading,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    labelText: "Notes",
                    labelStyle: const TextStyle(
                      color: AppColors.textHelper,
                    ),
                    filled: true,
                    fillColor: AppColors.cardElement,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                // =========================
                // BUTTONS
                // =========================
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed:
                            loading ? null : () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textSecondary,
                          padding: const EdgeInsets.symmetric(
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text("Cancel"),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: loading ? null : submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: loading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                widget.isEdit ? "Save Changes" : "Add External",
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _dropdown<T>({
    required String label,
    required T? value,
    required List<T> items,
    required String Function(T) itemLabel,
    required ValueChanged<T?>? onChanged,
  }) {
    print("🟡 DROPDOWN BUILD: $label");
    print("🟡 ITEMS COUNT: ${items.length}");
    print("🟡 CURRENT VALUE: $value");

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
      ),
      decoration: BoxDecoration(
        color: AppColors.cardElement,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.cardBorder.withOpacity(.3),
        ),
      ),
      child: DropdownButton<T>(
        value: value,
        isExpanded: true,
        underline: const SizedBox(),
        dropdownColor: AppColors.cardBg,
        hint: Text(
          label,
          style: const TextStyle(
            color: AppColors.textHelper,
          ),
        ),
        icon: const Icon(
          Icons.keyboard_arrow_down_rounded,
          color: AppColors.textSecondary,
        ),
        style: const TextStyle(
          color: AppColors.textPrimary,
        ),
        items: items.map((item) {
          final text = itemLabel(item);

          return DropdownMenuItem<T>(
            value: item,
            child: Text(
              text,
              style: const TextStyle(
                color: AppColors.textPrimary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }
}
