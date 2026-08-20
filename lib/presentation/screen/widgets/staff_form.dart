import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_management/constants/app_colors.dart';
import 'package:school_management/cubit/auth/register/staff_cubit.dart';
import 'package:school_management/cubit/auth/register/staff_state.dart';
import 'package:school_management/data/model/staff_model.dart';
import 'package:school_management/presentation/screen/widgets/app_data_picker.dart';
import 'package:school_management/presentation/screen/widgets/app_toast.dart';

class StaffForm extends StatefulWidget {
  const StaffForm({super.key});

  @override
  State<StaffForm> createState() => _StaffFormState();
}

class _StaffFormState extends State<StaffForm> {
  String? gender;
  String? roleId;
  DateTime? birthDate;
  DateTime? hireDate;

  String? selectedSubjectId;
  List<Map<String, dynamic>> subjects = [];
  bool isLoadingSubjects = false;

  final genders = ["male", "female"];

  final roles = [
    {"id": "2", "title": "Assistant"},
    {"id": "3", "title": "Supervisor"},
    {"id": "4", "title": "Librarian"},
    {"id": "5", "title": "Teacher"},
  ];

  final firstNameController = TextEditingController();
  final middleNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final addressController = TextEditingController();
  final salaryController = TextEditingController();
  final contactController = TextEditingController();
  final notesController = TextEditingController();

  bool get isTeacher => roleId == "5";

  @override
  void initState() {
    super.initState();
    _loadSubjects();
  }

  Future<void> _loadSubjects() async {
    if (!mounted) return;

    setState(() {
      isLoadingSubjects = true;
    });

    try {
      final data = await context.read<StaffCubit>().repository.getSubjects();

      if (!mounted) return;

      setState(() {
        subjects = data;
        isLoadingSubjects = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoadingSubjects = false;
      });

      AppToast.show(
        context,
        message: "Failed to load subjects",
        color: Colors.red,
        icon: Icons.error,
      );

      print("SUBJECTS LOAD ERROR: $e");
    }
  }

  @override
  void dispose() {
    firstNameController.dispose();
    middleNameController.dispose();
    lastNameController.dispose();
    addressController.dispose();
    salaryController.dispose();
    contactController.dispose();
    notesController.dispose();
    super.dispose();
  }

  Widget _input(
    String hint,
    TextEditingController controller, {
    TextInputType? type,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: type,
      maxLines: maxLines,
      style: const TextStyle(
        color: AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          color: AppColors.textHelper,
        ),
        filled: true,
        fillColor: AppColors.cardElement,
        border: InputBorder.none,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 1.5,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
      ),
    );
  }

  Widget _dropdown({
    required String hint,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.cardElement,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.cardBorder.withOpacity(0.3),
        ),
      ),
      child: DropdownButton<String>(
        value: value,
        hint: Text(
          hint,
          style: const TextStyle(
            color: AppColors.textHelper,
          ),
        ),
        dropdownColor: AppColors.cardBg,
        isExpanded: true,
        underline: const SizedBox(),
        icon: const Icon(
          Icons.arrow_drop_down,
          color: AppColors.textSecondary,
        ),
        style: const TextStyle(
          color: AppColors.textPrimary,
        ),
        items: items
            .map(
              (e) => DropdownMenuItem<String>(
                value: e,
                child: Text(
                  e,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            )
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _roleDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.cardElement,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.cardBorder.withOpacity(0.3),
        ),
      ),
      child: DropdownButton<String>(
        value: roleId,
        hint: const Text(
          "Select Role",
          style: TextStyle(
            color: AppColors.textHelper,
          ),
        ),
        dropdownColor: AppColors.cardBg,
        isExpanded: true,
        underline: const SizedBox(),
        icon: const Icon(
          Icons.arrow_drop_down,
          color: AppColors.textSecondary,
        ),
        items: roles
            .map(
              (r) => DropdownMenuItem<String>(
                value: r["id"],
                child: Text(
                  r["title"]!,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            )
            .toList(),
        onChanged: (v) {
          setState(() {
            roleId = v;

            if (roleId != "5") {
              selectedSubjectId = null;
              notesController.clear();
            }
          });
        },
      ),
    );
  }

  Widget _subjectDropdown() {
    if (isLoadingSubjects) {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 16,
        ),
        decoration: BoxDecoration(
          color: AppColors.cardElement,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.cardBorder.withOpacity(0.3),
          ),
        ),
        child: const Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            ),
            SizedBox(width: 12),
            Text(
              "Loading subjects...",
              style: TextStyle(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.cardElement,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.cardBorder.withOpacity(0.3),
        ),
      ),
      child: DropdownButton<String>(
        value: selectedSubjectId,
        hint: const Text(
          "Select Subject",
          style: TextStyle(
            color: AppColors.textHelper,
          ),
        ),
        dropdownColor: AppColors.cardBg,
        isExpanded: true,
        underline: const SizedBox(),
        icon: const Icon(
          Icons.arrow_drop_down,
          color: AppColors.textSecondary,
        ),
        items: subjects.map((subject) {
          return DropdownMenuItem<String>(
            value: subject["id"].toString(),
            child: Text(
              subject["name"].toString(),
              style: const TextStyle(
                color: AppColors.textPrimary,
              ),
            ),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            selectedSubjectId = value;
          });
        },
      ),
    );
  }

  void _clearFields() {
    firstNameController.clear();
    middleNameController.clear();
    lastNameController.clear();
    addressController.clear();
    salaryController.clear();
    contactController.clear();
    notesController.clear();

    setState(() {
      gender = null;
      roleId = null;
      birthDate = null;
      hireDate = null;
      selectedSubjectId = null;
    });
  }

  void _showCredentials({
    required String username,
    required String password,
    required String accountType,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.cardBg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 28,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  "$accountType Account Created",
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Please give these login credentials to the $accountType.",
                style: const TextStyle(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 20),
              _credentialBox(
                title: "Username",
                value: username,
              ),
              const SizedBox(height: 12),
              _credentialBox(
                title: "Password",
                value: password,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text(
                "Done",
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _credentialBox({
    required String title,
    required String value,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardElement,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 5),
          SelectableText(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _button() {
    return BlocBuilder<StaffCubit, StaffRegisterState>(
      builder: (context, state) {
        final isLoading = state is StaffRegisterLoading;

        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(
                vertical: 14,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: isLoading
                ? null
                : () {
                    if (gender == null ||
                        birthDate == null ||
                        hireDate == null ||
                        roleId == null) {
                      AppToast.show(
                        context,
                        message: "Please fill all required fields",
                        color: Colors.orange,
                        icon: Icons.warning,
                      );
                      return;
                    }

                    if (isTeacher && selectedSubjectId == null) {
                      AppToast.show(
                        context,
                        message: "Please select a subject",
                        color: Colors.orange,
                        icon: Icons.warning,
                      );
                      return;
                    }

                    final staff = StaffModel(
                      fName: firstNameController.text.trim(),
                      mName: middleNameController.text.trim(),
                      lName: lastNameController.text.trim(),
                      gender: gender!,
                      dob: birthDate!.toIso8601String().split('T')[0],
                      address: addressController.text.trim(),
                      roleId: int.parse(roleId!),
                      hireDate: hireDate!.toIso8601String().split('T')[0],
                      salary: double.tryParse(
                            salaryController.text.trim(),
                          ) ??
                          0,
                      contact: contactController.text.trim(),
                      subjectId: isTeacher
                          ? int.parse(
                              selectedSubjectId!,
                            )
                          : null,
                      notes: isTeacher ? notesController.text.trim() : null,
                    );

                    if (isTeacher) {
                      context.read<StaffCubit>().registerTeacher(staff);
                    } else {
                      context.read<StaffCubit>().registerStaff(staff);
                    }
                  },
            child: isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    isTeacher ? "Register Teacher" : "Register Staff",
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<StaffCubit, StaffRegisterState>(
      listener: (context, state) {
        if (state is StaffRegisterSuccess) {
          _clearFields();

          _showCredentials(
            username: state.username,
            password: state.password,
            accountType: isTeacher ? "Staff" : "Staff",
          );
        }

        if (state is TeacherRegisterSuccess) {
          _clearFields();

          _showCredentials(
            username: state.username,
            password: state.password,
            accountType: "Teacher",
          );
        }

        if (state is StaffRegisterError) {
          AppToast.show(
            context,
            message: state.message,
            color: Colors.red,
            icon: Icons.error,
          );
        }
      },
      child: SingleChildScrollView(
        child: Column(
          children: [
            _input(
              "First Name",
              firstNameController,
            ),
            const SizedBox(height: 12),
            _input(
              "Middle Name",
              middleNameController,
            ),
            const SizedBox(height: 12),
            _input(
              "Last Name",
              lastNameController,
            ),
            const SizedBox(height: 12),
            _dropdown(
              hint: "Gender",
              value: gender,
              items: genders,
              onChanged: (v) {
                setState(() {
                  gender = v;
                });
              },
            ),
            const SizedBox(height: 12),
            AppDatePicker(
              label: "Date of Birth",
              date: birthDate,
              onPick: (d) {
                setState(() {
                  birthDate = d;
                });
              },
            ),
            const SizedBox(height: 12),
            _input(
              "Address",
              addressController,
            ),
            const SizedBox(height: 12),
            _roleDropdown(),
            if (isTeacher) ...[
              const SizedBox(height: 12),
              _subjectDropdown(),
              const SizedBox(height: 12),
              _input(
                "Notes",
                notesController,
                maxLines: 3,
              ),
            ],
            const SizedBox(height: 12),
            AppDatePicker(
              label: "Hire Date",
              date: hireDate,
              onPick: (d) {
                setState(() {
                  hireDate = d;
                });
              },
            ),
            const SizedBox(height: 12),
            _input(
              "Salary",
              salaryController,
              type: TextInputType.number,
            ),
            const SizedBox(height: 12),
            _input(
              "Contact",
              contactController,
              type: TextInputType.phone,
            ),
            const SizedBox(height: 20),
            _button(),
          ],
        ),
      ),
    );
  }
}
