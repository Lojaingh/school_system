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
  String? selectedClassId;
  DateTime? birthDate;

  final genders = ["Male", "Female"];

  final classes = [
    {"id": 1, "name": "Class 1"},
    {"id": 2, "name": "Class 2"},
    {"id": 3, "name": "Class 3"},
    {"id": 4, "name": "Class 4"},
  ];

  // Controllers
  final firstNameController = TextEditingController();
  final middleNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final addressController = TextEditingController();
  final healthController = TextEditingController();

  @override
  void dispose() {
    firstNameController.dispose();
    middleNameController.dispose();
    lastNameController.dispose();
    addressController.dispose();
    healthController.dispose();
    super.dispose();
  }

  Widget _input(String hint, TextEditingController controller,
      {TextInputType? type}) {
    return TextField(
      controller: controller,
      keyboardType: type,
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textHelper),
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
          style: TextStyle(color: AppColors.textHelper),
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
        onChanged: (v) => setState(() => gender = v),
      ),
    );
  }

  Widget _dropdownClass() {
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
        value: selectedClassId,
        hint: const Text(
          "Class",
          style: TextStyle(color: AppColors.textHelper),
        ),
        dropdownColor: AppColors.cardBg,
        isExpanded: true,
        underline: const SizedBox(),
        icon: const Icon(
          Icons.arrow_drop_down,
          color: AppColors.textSecondary,
        ),
        items: classes
            .map(
              (c) => DropdownMenuItem<String>(
                value: c["id"].toString(),
                child: Text(
                  c["name"].toString(),
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            )
            .toList(),
        onChanged: (value) {
          setState(() {
            selectedClassId = value;
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
    healthController.clear();

    setState(() {
      gender = null;
      birthDate = null;
      selectedClassId = null;
    });
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
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: isLoading
                ? null
                : () async {
                    if (gender == null ||
                        birthDate == null ||
                        selectedClassId == null) {
                      return;
                    }

                    final student = StudentModel(
                      username: "STU-${DateTime.now().millisecondsSinceEpoch}",
                      password: "123456",
                      fName: firstNameController.text,
                      mName: middleNameController.text,
                      lName: lastNameController.text,
                      gender: gender!.toLowerCase(),
                      dob: birthDate!.toIso8601String(),
                      address: addressController.text,
                      grade: int.parse(selectedClassId!),
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
                    style: TextStyle(color: Colors.white),
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
          AppToast.show(
            context,
            message: "Registration successful",
            color: Colors.green,
            icon: Icons.check_circle,
          );

          _clearFields();
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
            _input("First Name", firstNameController),
            const SizedBox(height: 12),
            _input("Middle Name", middleNameController),
            const SizedBox(height: 12),
            _input("Last Name", lastNameController),
            const SizedBox(height: 12),
            _dropdownGender(),
            const SizedBox(height: 12),
            AppDatePicker(
              label: "Date of Birth",
              date: birthDate,
              onPick: (d) => setState(() => birthDate = d),
            ),
            const SizedBox(height: 12),
            _input("Address", addressController),
            const SizedBox(height: 12),
            _dropdownClass(),
            const SizedBox(height: 12),
            _input("Health Status", healthController),
            const SizedBox(height: 20),
            _button(),
          ],
        ),
      ),
    );
  }
}
