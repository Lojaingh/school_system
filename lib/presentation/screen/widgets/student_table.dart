import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_management/constants/app_colors.dart';
import 'package:school_management/cubit/student/student_cubit.dart';
import 'package:school_management/presentation/screen/widgets/delet_button.dart';
import 'package:school_management/presentation/screens/student_profile_screen.dart';

class StudentTable extends StatelessWidget {
  final List students;
  final Function(int) onOpenProfile;

  const StudentTable({
    super.key,
    required this.students,
    required this.onOpenProfile,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.cardElement,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.cardBorder.withOpacity(.25),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(.15),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(14),
              ),
            ),
            child: const Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Text("#", style: _headerStyle),
                ),
                Expanded(
                  flex: 3,
                  child: Text("Student", style: _headerStyle),
                ),
                Expanded(
                  flex: 2,
                  child: Text("Username", style: _headerStyle),
                ),
                Expanded(
                  flex: 2,
                  child: Text("Gender", style: _headerStyle),
                ),
                Expanded(
                  flex: 2,
                  child: Text("DOB", style: _headerStyle),
                ),
                Expanded(
                  flex: 2,
                  child: Center(
                    child: Text("Actions", style: _headerStyle),
                  ),
                ),
              ],
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: students.length,
            separatorBuilder: (_, __) => Divider(
              height: 1,
              color: AppColors.cardBorder.withOpacity(.15),
            ),
            itemBuilder: (context, index) {
              final s = students[index];

              final male = s.gender.toLowerCase() == "male";

              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
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
                            radius: 18,
                            backgroundColor: AppColors.primary,
                            child: Text(
                              s.firstName.isNotEmpty
                                  ? s.firstName[0].toUpperCase()
                                  : "?",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              "${s.firstName} ${s.lastName}",
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        s.username,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: male
                                ? Colors.blue.withOpacity(.15)
                                : Colors.pink.withOpacity(.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            s.gender,
                            style: TextStyle(
                              color:
                                  male ? Colors.blueAccent : Colors.pinkAccent,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        s.dob,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            tooltip: "View Profile",
                            icon: const Icon(
                              Icons.visibility_outlined,
                              color: Colors.white70,
                            ),
                            onPressed: s.userId == null
                                ? null
                                : () {
                                    onOpenProfile(s.userId!);
                                  },
                          ),
                          if (s.userId != null)
                            DeleteButton(
                              id: s.userId!,
                              title: "${s.firstName} ${s.lastName}",
                              onDelete: (id) async {
                                await context
                                    .read<StudentCubit>()
                                    .deleteStudent(id);
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
        ],
      ),
    );
  }
}

const TextStyle _headerStyle = TextStyle(
  color: Colors.white,
  fontWeight: FontWeight.bold,
);
