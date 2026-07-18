import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_management/constants/app_colors.dart';
import 'package:school_management/cubit/student/student_cubit.dart';
import 'package:school_management/cubit/student/student_state.dart';
import 'package:school_management/presentation/screen/widgets/stats_row.dart';
import 'package:school_management/presentation/screen/widgets/student_table.dart';

class StudentScreen extends StatefulWidget {
  final Function(int) onOpenProfile;

  const StudentScreen({
    super.key,
    required this.onOpenProfile,
  });

  @override
  State<StudentScreen> createState() => _StudentScreenState();
}

class _StudentScreenState extends State<StudentScreen> {
  final searchController = TextEditingController();

  List students = [];
  List filteredStudents = [];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StudentCubit>().getStudents(6);
    });
  }

  void _filter(String value) {
    setState(() {
      filteredStudents = students.where((s) {
        final name = (s.firstName + " " + s.lastName).toLowerCase();
        return name.contains(value.toLowerCase());
      }).toList();
    });
  }

  void _setData(List data) {
    setState(() {
      students = data;
      filteredStudents = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cardBg,
      body: BlocConsumer<StudentCubit, StudentState>(
        listener: (context, state) {
          if (state is StudentLoaded) {
            _setData(state.students);
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AppGradients.cardGradient,
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Students Management",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Manage all students in your school",
                      style: TextStyle(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              StatsRow(students: filteredStudents),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColors.cardElement,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: TextField(
                    controller: searchController,
                    onChanged: _filter,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      icon: Icon(
                        Icons.search,
                        color: Colors.white54,
                      ),
                      hintText: "Search student...",
                      hintStyle: TextStyle(
                        color: Colors.white54,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: StudentTable(
                  students: filteredStudents,
                  onOpenProfile: widget.onOpenProfile,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
