import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:school_management/constants/app_colors.dart';
import 'package:school_management/cubit/assignment/assignment_cubit.dart';
import 'package:school_management/cubit/assignment/assignment_state.dart';

class AssignmentContent extends StatefulWidget {
  const AssignmentContent({super.key});

  @override
  State<AssignmentContent> createState() => _AssignmentContentState();
}

class _AssignmentContentState extends State<AssignmentContent> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<AssignmentCubit>().getAssignments();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Assignments",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  // سنضيفه لاحقاً
                },
                icon: const Icon(Icons.add),
                label: const Text("Add Assignment"),
              ),
            ],
          ),

          const SizedBox(height: 24),

          Expanded(
            child: BlocBuilder<AssignmentCubit, AssignmentState>(
              builder: (context, state) {
                if (state is AssignmentLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (state is AssignmentError) {
                  return Center(
                    child: Text(state.message),
                  );
                }

                if (state is AssignmentLoaded) {
                  if (state.assignments.isEmpty) {
                    return const Center(
                      child: Text("No Assignments"),
                    );
                  }

                  return ListView.builder(
                    itemCount: state.assignments.length,
                    itemBuilder: (context, index) {
                      final assignment = state.assignments[index];

                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: ListTile(
                          leading: const CircleAvatar(
                            child: Icon(Icons.assignment_rounded),
                          ),
                          title: Text(
                            assignment.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(assignment.subjectName),
                              const SizedBox(height: 4),
                              Text(
                                "Due Date: ${assignment.dueDate}",
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () {},
                                icon: const Icon(Icons.edit),
                              ),
                              IconButton(
                                onPressed: () {},
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }

                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }
}
