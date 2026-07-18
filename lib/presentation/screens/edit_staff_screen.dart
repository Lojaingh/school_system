import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:school_management/constants/app_colors.dart';
import 'package:school_management/cubit/staff/staff_profile_cubit.dart';
import 'package:school_management/data/model/staff_profile_model.dart';
import 'package:school_management/presentation/screen/widgets/app_data_picker.dart';

class EditStaffScreen extends StatefulWidget {
  final StaffProfileModel staff;
  final int staffId;

  const EditStaffScreen({
    super.key,
    required this.staff,
    required this.staffId,
  });

  @override
  State<EditStaffScreen> createState() => _EditStaffScreenState();
}

class _EditStaffScreenState extends State<EditStaffScreen> {
  late TextEditingController firstName;
  late TextEditingController lastName;
  late TextEditingController salary;
  late TextEditingController contact;

  DateTime? selectedDob;

  String gender = "male";
  String employment = "employed";

  @override
  void initState() {
    super.initState();

    firstName = TextEditingController(
      text: widget.staff.firstName,
    );

    lastName = TextEditingController(
      text: widget.staff.lastName,
    );

    salary = TextEditingController(
      text: widget.staff.salary?.toString() ?? "",
    );

    contact = TextEditingController(
      text: widget.staff.contact ?? "",
    );

    if (widget.staff.dob.isNotEmpty) {
      selectedDob = DateTime.tryParse(widget.staff.dob);
    }

    gender = widget.staff.gender;
    employment = widget.staff.employment ?? "employed";
  }

  @override
  void dispose() {
    firstName.dispose();
    lastName.dispose();
    salary.dispose();
    contact.dispose();
    super.dispose();
  }

  Future<void> save() async {
    await context.read<StaffProfileCubit>().updateStaff(
      widget.staffId,
      {
        "f_name": firstName.text,
        "l_name": lastName.text,
        "gender": gender,
        "dob": selectedDob == null
            ? ""
            : "${selectedDob!.year}-${selectedDob!.month}-${selectedDob!.day}",
        "salary": salary.text,
        "contact": contact.text,
        "employment_status": employment,
      },
    );

    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        maxHeight: 650,
      ),
      decoration: const BoxDecoration(
        gradient: AppGradients.cardGradient,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.cardBg,
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.cardBorder,
                  ),
                ),
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      "Edit Staff",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _field("First Name", firstName),
                  _field("Last Name", lastName),
                  const SizedBox(height: 5),
                  AppDatePicker(
                    label: "Date of Birth",
                    date: selectedDob,
                    onPick: (date) {
                      setState(() {
                        selectedDob = date;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  _field("Salary", salary),
                  _field("Contact", contact),
                  const SizedBox(height: 12),
                  _dropdown(
                    "Gender",
                    gender,
                    [
                      "male",
                      "female",
                    ],
                    (v) {
                      setState(() {
                        gender = v!;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  _dropdown(
                    "Employment",
                    employment,
                    [
                      "employed",
                      "finished",
                    ],
                    (v) {
                      setState(() {
                        employment = v!;
                      });
                    },
                  ),
                  const SizedBox(height: 25),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: save,
                      icon: const Icon(Icons.save),
                      label: const Text("Save Changes"),
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
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(
    String title,
    TextEditingController controller,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        style: const TextStyle(
          color: Colors.white,
        ),
        decoration: InputDecoration(
          labelText: title,
          labelStyle: const TextStyle(
            color: AppColors.textSecondary,
          ),
          filled: true,
          fillColor: AppColors.cardElement,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _dropdown(
    String title,
    String value,
    List<String> items,
    Function(String?) onChanged,
  ) {
    return DropdownButtonFormField<String>(
      value: value,
      dropdownColor: AppColors.cardElement,
      style: const TextStyle(
        color: Colors.white,
      ),
      decoration: InputDecoration(
        labelText: title,
        labelStyle: const TextStyle(
          color: AppColors.textSecondary,
        ),
        filled: true,
        fillColor: AppColors.cardElement,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      items: items.map(
        (e) {
          return DropdownMenuItem(
            value: e,
            child: Text(
              e,
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
          );
        },
      ).toList(),
      onChanged: onChanged,
    );
  }
}
