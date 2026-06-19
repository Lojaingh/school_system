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

  @override
  void dispose() {
    firstNameController.dispose();
    middleNameController.dispose();
    lastNameController.dispose();
    addressController.dispose();
    salaryController.dispose();
    contactController.dispose();
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
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
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
        hint: Text(hint, style: const TextStyle(color: AppColors.textHelper)),
        dropdownColor: AppColors.cardBg,
        isExpanded: true,
        underline: const SizedBox(),
        icon: const Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
        style: const TextStyle(color: AppColors.textPrimary),
        items: items
            .map((e) => DropdownMenuItem(
                  value: e,
                  child: Text(e,
                      style: const TextStyle(color: AppColors.textPrimary)),
                ))
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
        hint: const Text("Select Role",
            style: TextStyle(color: AppColors.textHelper)),
        dropdownColor: AppColors.cardBg,
        isExpanded: true,
        underline: const SizedBox(),
        icon: const Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
        items: roles
            .map(
              (r) => DropdownMenuItem(
                value: r["id"],
                child: Text(r["title"]!,
                    style: const TextStyle(color: AppColors.textPrimary)),
              ),
            )
            .toList(),
        onChanged: (v) => setState(() => roleId = v),
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
              padding: const EdgeInsets.symmetric(vertical: 14),
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
                      return;
                    }

                    final staff = StaffModel(
                      fName: firstNameController.text,
                      mName: middleNameController.text,
                      lName: lastNameController.text,
                      gender: gender!,
                      dob: birthDate!.toIso8601String().split('T')[0],
                      address: addressController.text,
                      roleId: int.parse(roleId!),
                      hireDate: hireDate!.toIso8601String().split('T')[0],
                      salary: double.tryParse(salaryController.text) ?? 0,
                      contact: contactController.text,
                    );

                    context.read<StaffCubit>().registerStaff(staff);
                  },
            child: isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
                    "Register Staff",
                    style: TextStyle(color: Colors.white),
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
          AppToast.show(
            context,
            message: "Registration successful",
            color: Colors.green,
            icon: Icons.check_circle,
          );

          firstNameController.clear();
          middleNameController.clear();
          lastNameController.clear();
          addressController.clear();
          salaryController.clear();
          contactController.clear();

          setState(() {
            gender = null;
            roleId = null;

            birthDate = null;
            hireDate = null;
          });
        }

        if (state is StaffRegisterError) {
          AppToast.show(
            context,
            message: state.message ?? "Registration failed",
            color: Colors.red,
            icon: Icons.error,
          );
        }
      },
      child: SingleChildScrollView(
        child: Column(
          children: [
            _input("First Name", firstNameController),
            const SizedBox(height: 12),
            _input("Middle Name", middleNameController),
            const SizedBox(height: 12),
            _input("Last Name", lastNameController),
            const SizedBox(height: 12),
            _dropdown(
              hint: "Gender",
              value: gender,
              items: genders,
              onChanged: (v) => setState(() => gender = v),
            ),
            const SizedBox(height: 12),
            AppDatePicker(
              label: "Date of Birth",
              date: birthDate,
              onPick: (d) => setState(() => birthDate = d),
            ),
            const SizedBox(height: 12),
            _input("Address", addressController),
            const SizedBox(height: 12),
            _roleDropdown(),
            const SizedBox(height: 12),
            AppDatePicker(
              label: "Hire Date",
              date: hireDate,
              onPick: (d) => setState(() => hireDate = d),
            ),
            const SizedBox(height: 12),
            _input("Salary", salaryController, type: TextInputType.number),
            const SizedBox(height: 12),
            _input("Contact", contactController, type: TextInputType.phone),
            const SizedBox(height: 12),
            const SizedBox(height: 20),
            _button(),
          ],
        ),
      ),
    );
  }
}
