import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:school_management/constants/app_colors.dart';
import 'package:school_management/cubit/auth/register/register_cubit.dart';
import 'package:school_management/cubit/auth/register/register_state.dart';
import 'package:school_management/data/model/student_model.dart';
import 'package:school_management/presentation/screen/widgets/app_data_picker.dart';
import 'package:school_management/presentation/screen/widgets/app_toast.dart';

class StudentForm extends StatefulWidget {
  const StudentForm({super.key});

  @override
  State<StudentForm> createState() => _StudentFormState();
}

class _StudentFormState extends State<StudentForm> {
  String? gender;
  DateTime? birthDate;

  final gradeController = TextEditingController();

  final firstNameController = TextEditingController();
  final middleNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final addressController = TextEditingController();
  final healthController = TextEditingController();

  final genders = [
    "Male",
    "Female",
  ];

  @override
  void dispose() {
    firstNameController.dispose();
    middleNameController.dispose();
    lastNameController.dispose();
    addressController.dispose();
    healthController.dispose();
    gradeController.dispose();

    super.dispose();
  }

  Widget _input(
    String hint,
    TextEditingController controller, {
    TextInputType? type,
  }) {
    return TextField(
      controller: controller,
      keyboardType: type,
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
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.cardBorder.withOpacity(0.3),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _dropdownGender() {
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
        value: genders.contains(gender) ? gender : null,
        hint: const Text(
          "Gender",
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
        items: genders
            .map(
              (g) => DropdownMenuItem(
                value: g,
                child: Text(
                  g,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            )
            .toList(),
        onChanged: (v) {
          setState(() {
            gender = v;
          });
        },
      ),
    );
  }

  Widget _gradeInput() {
    return TextField(
      controller: gradeController,
      keyboardType: TextInputType.number,
      maxLength: 2,
      style: const TextStyle(
        color: AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        counterText: "",
        hintText: "Choose Grade between 1 and 12",
        hintStyle: const TextStyle(
          color: AppColors.textHelper,
          fontStyle: FontStyle.italic,
        ),
        filled: true,
        fillColor: AppColors.cardElement,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.cardBorder.withOpacity(0.3),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 1.5,
          ),
        ),
      ),
    );
  }

  void _clearFields() {
    firstNameController.clear();
    middleNameController.clear();
    lastNameController.clear();
    addressController.clear();
    healthController.clear();
    gradeController.clear();

    setState(() {
      gender = null;
      birthDate = null;
    });
  }

  void _showCredentialsDialog({
    required String username,
    required String password,
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
          title: const Row(
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 28,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Account Created",
                  style: TextStyle(
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
              const Text(
                "Student account has been created successfully.",
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Username",
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.cardElement,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  username,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                "Password",
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.cardElement,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  password,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);

                _clearFields();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                "Done",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _button() {
    return BlocBuilder<RegisterCubit, RegisterState>(
      builder: (context, state) {
        final isLoading = state is RegisterLoading;

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
                : () async {
                    final grade = int.tryParse(
                      gradeController.text,
                    );

                    if (gender == null ||
                        birthDate == null ||
                        grade == null ||
                        grade < 1 ||
                        grade > 12) {
                      AppToast.show(
                        context,
                        message: "Please enter Grade between 1 and 12",
                        color: Colors.red,
                        icon: Icons.error,
                      );

                      return;
                    }

                    final student = StudentModel(
                      fName: firstNameController.text,
                      mName: middleNameController.text,
                      lName: lastNameController.text,
                      gender: gender!.toLowerCase(),
                      dob: birthDate!.toIso8601String(),
                      address: addressController.text,
                      grade: grade,
                      healthStatus: healthController.text,
                      roleId: 6,
                    );

                    await context.read<RegisterCubit>().register(student);
                  },
            child: isLoading
                ? const CircularProgressIndicator(
                    color: Colors.white,
                  )
                : const Text(
                    "Register Student",
                    style: TextStyle(
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
    return BlocListener<RegisterCubit, RegisterState>(
      listener: (context, state) {
        if (state is RegisterSuccess) {
          _showCredentialsDialog(
            username: state.username,
            password: state.password,
          );
        }

        if (state is RegisterError) {
          AppToast.show(
            context,
            message: state.message,
            color: Colors.red,
            icon: Icons.error,
          );
        }
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
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
            _dropdownGender(),
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
            _gradeInput(),
            const SizedBox(height: 12),
            _input(
              "Health Status",
              healthController,
            ),
            const SizedBox(height: 20),
            _button(),
          ],
        ),
      ),
    );
  }
}
