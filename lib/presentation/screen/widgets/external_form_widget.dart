import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_management/constants/app_colors.dart';
import 'package:school_management/cubit/external/external_cubit.dart';
import 'package:school_management/cubit/external/external_state.dart';
import 'package:school_management/data/model/external_model.dart';
import 'package:school_management/data/model/school_class_model.dart';

class ExternalFormWidget extends StatefulWidget {
  final ExternalModel? external;

  const ExternalFormWidget({
    super.key,
    this.external,
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

  @override
  void initState() {
    super.initState();

    if (widget.external != null) {
      schoolClassId = widget.external!.schoolClassId;
      notesController.text = widget.external!.notes ?? "";
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      context.read<ExternalCubit>().getTeacherClasses();
    });
  }

  @override
  void dispose() {
    notesController.dispose();
    super.dispose();
  }
  Future<void> pickFile() async {
    if (_submitted) return;

    final result = await FilePicker.pickFiles(
      type: FileType.any,
      allowMultiple: false,
      withData: true,
    );

    if (result == null || result.files.isEmpty) {
      return;
    }

    if (!mounted) return;

    setState(() {
      selectedFile = result.files.first;
    });
  }

  void submit() {
    if (_submitted) return;

    if (schoolClassId == null) {
      _showMessage("Please select a school class");
      return;
    }

    if (!widget.isEdit && selectedFile == null) {
      _showMessage("Please select a file");
      return;
    }

    setState(() {
      _submitted = true;
    });

    final cubit = context.read<ExternalCubit>();

    if (widget.isEdit) {
      cubit.updateExternal(
        id: widget.external!.id,
        schoolClassId: schoolClassId,
        file: selectedFile,
        notes: notesController.text.trim(),
      );
    } else {
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
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ExternalCubit, ExternalState>(
      listener: (context, state) {
        if (state is ExternalAddSuccess || state is ExternalUpdateSuccess) {
          Navigator.pop(context, true);
          return;
        }

        if (state is ExternalError) {
          if (mounted) {
            setState(() {
              _submitted = false;
            });
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      },
      builder: (context, state) {
        final bool loading = state is ExternalAddLoading ||
            state is ExternalUpdateLoading ||
            _submitted;
        List<SchoolClassModel> classes = [];

        if (state is TeacherClassesLoaded) {
          classes = state.classes;
        }
        SchoolClassModel? selectedClass;

        for (final item in classes) {
          if (item.id == schoolClassId) {
            selectedClass = item;
            break;
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
                _dropdown<SchoolClassModel>(
                  label: "School Class",
                  value: selectedClass,
                  items: classes,
                  itemLabel: (item) => item.label ?? "Class ${item.id}",
                  onChanged: loading
                      ? null
                      : (value) {
                          setState(() {
                            schoolClassId = value?.id;
                          });
                        },
                ),

                const SizedBox(height: 16),
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
                        child: const Text(
                          "Cancel",
                        ),
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
          return DropdownMenuItem<T>(
            value: item,
            child: Text(
              itemLabel(item),
              style: const TextStyle(
                color: AppColors.textPrimary,
              ),
            ),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }
}
