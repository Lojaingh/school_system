import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_management/constants/app_colors.dart';
import 'package:school_management/cubit/staff/staff_profile_cubit.dart';
import 'package:school_management/presentation/screen/widgets/delet_button.dart';

class StaffTable extends StatelessWidget {
  final List staff;
  final Function(int id, bool isManager) onOpenProfile;

  const StaffTable({
    super.key,
    required this.staff,
    required this.onOpenProfile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.cardElement,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              vertical: 14,
              horizontal: 12,
            ),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(.2),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: const Row(
              children: [
                Expanded(flex: 1, child: Text("#", style: _header)),
                Expanded(flex: 3, child: Text("Staff", style: _header)),
                Expanded(flex: 2, child: Text("Username", style: _header)),
                Expanded(flex: 2, child: Text("Gender", style: _header)),
                Expanded(flex: 2, child: Text("DOB", style: _header)),
                Expanded(flex: 2, child: Text("Role", style: _header)),
                Expanded(flex: 2, child: Text("Status", style: _header)),
                Expanded(flex: 2, child: Text("Actions", style: _header)),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: staff.length,
              itemBuilder: (context, index) {
                final s = staff[index];

                return Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 12,
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.white.withOpacity(.05),
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Text(
                          "${index + 1}",
                          style: const TextStyle(
                            color: Colors.white70,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: AppColors.primary,
                              child: Text(
                                s.firstName.isNotEmpty ? s.firstName[0] : "?",
                                style: const TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                "${s.firstName} ${s.lastName}",
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          s.username ?? "",
                          style: const TextStyle(
                            color: Colors.white70,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          s.gender,
                          style: const TextStyle(
                            color: Colors.white70,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          s.dob,
                          style: const TextStyle(
                            color: Colors.white70,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            s.role ?? "",
                            style: const TextStyle(
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          s.finishedAt == null ? "Active" : "Finished",
                          style: TextStyle(
                            color: s.finishedAt == null
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Row(
                          children: [
                            IconButton(
                              tooltip: "View Profile",
                              icon: const Icon(
                                Icons.visibility,
                                color: Colors.white70,
                              ),
                              onPressed: s.userId == null
                                  ? null
                                  : () {
                                      onOpenProfile(
                                        s.userId!,
                                        s.role?.toLowerCase() == "manager",
                                      );
                                    },
                            ),
                            if (s.userId != null)
                              DeleteButton(
                                id: s.userId!,
                                title: "${s.firstName} ${s.lastName}",
                                onDelete: (id) async {
                                  await context
                                      .read<StaffProfileCubit>()
                                      .deleteStaff(id);
                                },
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

const TextStyle _header = TextStyle(
  color: Colors.white,
  fontWeight: FontWeight.bold,
);
