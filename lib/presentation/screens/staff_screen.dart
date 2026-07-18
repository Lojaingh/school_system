import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_management/constants/app_colors.dart';
import 'package:school_management/cubit/staff/staff_profile_cubit.dart';
import 'package:school_management/cubit/staff/staff_profile_state.dart';
import 'package:school_management/presentation/screen/widgets/staff_table.dart';

class StaffScreen extends StatefulWidget {
  final Function(int id, bool isManager) onOpenProfile;

  const StaffScreen({
    super.key,
    required this.onOpenProfile,
  });

  @override
  State<StaffScreen> createState() => _StaffScreenState();
}

class _StaffScreenState extends State<StaffScreen> {
  final searchController = TextEditingController();

  List staff = [];
  List filteredStaff = [];
  int? selectedRole;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StaffProfileCubit>().getStaff();
    });
  }

  void _setData(List data) {
    setState(() {
      staff = data;
      filteredStaff = data;
    });
  }

  void _filter(String value) {
    setState(() {
      filteredStaff = staff.where((s) {
        final name = "${s.firstName} ${s.lastName}".toLowerCase();

        return name.contains(value.toLowerCase());
      }).toList();
    });
  }

  void _changeRole(int? roleId) {
    setState(() {
      selectedRole = roleId;
    });

    context.read<StaffProfileCubit>().getStaff(
          roleId: roleId,
        );
  }

  Widget _statCard(
    String title,
    String value,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: AppGradients.cardGradient,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.cardBorder,
          ),
          boxShadow: AppShadows.cardShadow,
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<StaffProfileCubit, StaffProfileState>(
      listener: (context, state) {
        if (state is StaffLoaded) {
          _setData(state.staff);
        }
      },
      builder: (context, state) {
        return Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: AppGradients.cardGradient,
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.topBarBorder,
                  ),
                ),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Staff Management",
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    "Manage all school staff",
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _statCard(
                    "Total",
                    filteredStaff.length.toString(),
                    AppColors.cardBlue,
                  ),
                  const SizedBox(width: 10),
                  _statCard(
                    "Active",
                    filteredStaff
                        .where((e) => e.finishedAt == null)
                        .length
                        .toString(),
                    AppColors.success,
                  ),
                  const SizedBox(width: 10),
                  _statCard(
                    "Finished",
                    filteredStaff
                        .where((e) => e.finishedAt != null)
                        .length
                        .toString(),
                    AppColors.error,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        gradient: AppGradients.cardGradient,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppColors.cardBorder,
                        ),
                        boxShadow: AppShadows.cardShadow,
                      ),
                      child: TextField(
                        controller: searchController,
                        onChanged: _filter,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                        ),
                        decoration: const InputDecoration(
                          icon: Icon(
                            Icons.search_rounded,
                            color: AppColors.textHelper,
                          ),
                          hintText: "Search staff...",
                          hintStyle: TextStyle(
                            color: AppColors.textHelper,
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      gradient: AppGradients.cardGradient,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppColors.cardBorder,
                      ),
                      boxShadow: AppShadows.cardShadow,
                    ),
                    child: DropdownButton<int?>(
                      value: selectedRole,
                      dropdownColor: AppColors.cardBg,
                      underline: const SizedBox(),
                      iconEnabledColor: AppColors.textSecondary,
                      hint: const Text(
                        "Role",
                        style: TextStyle(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: null,
                          child: Text("All"),
                        ),
                        DropdownMenuItem(
                          value: 1,
                          child: Text("Manager"),
                        ),
                        DropdownMenuItem(
                          value: 2,
                          child: Text("Assistant"),
                        ),
                        DropdownMenuItem(
                          value: 3,
                          child: Text("Supervisor"),
                        ),
                      ],
                      onChanged: _changeRole,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: StaffTable(
                staff: filteredStaff,
                onOpenProfile: widget.onOpenProfile,
              ),
            ),
          ],
        );
      },
    );
  }
}
