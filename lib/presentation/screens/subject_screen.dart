import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_management/constants/app_colors.dart';
import 'package:school_management/cubit/auth/subject/subject_cubit.dart';
import 'package:school_management/cubit/auth/subject/subject_state.dart';
import 'package:school_management/data/model/subject_model.dart';
import 'package:school_management/presentation/screen/widgets/delet_button.dart';

class SubjectScreen extends StatefulWidget {
  const SubjectScreen({super.key});

  @override
  State<SubjectScreen> createState() => _SubjectScreenState();
}

class _SubjectScreenState extends State<SubjectScreen> {
  final searchController = TextEditingController();
  final nameController = TextEditingController();

  String? partition;
  int? editingId;

  final Map<String, String> partitions = {
    "0": "Full Semester",
    "1": "First Semester",
    "2": "Second Semester",
  };

  List<dynamic> allSubjects = [];
  List<dynamic> filteredSubjects = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SubjectCubit>().getSubjects();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    nameController.dispose();
    super.dispose();
  }

  void _filter(String value) {
    setState(() {
      filteredSubjects = allSubjects.where((s) {
        final name = (s['name'] ?? '').toString().toLowerCase();
        return name.contains(value.toLowerCase());
      }).toList();
    });
  }

  void _openForm({Map? subject}) {
    if (subject != null) {
      nameController.text = subject['name'] ?? '';
      partition = subject['partition']?.toString();
      editingId = subject['id'];
    } else {
      nameController.clear();
      partition = null;
      editingId = null;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.65,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          builder: (_, controller) {
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: AppGradients.cardGradient,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  )
                ],
              ),
              child: SingleChildScrollView(
                controller: controller,
                child: Column(
                  children: [
                    Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      editingId == null ? "Add Subject" : "Update Subject",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _inputField(nameController, "Subject Name"),
                    const SizedBox(height: 12),
                    _dropdown(),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.all(14),
                        ),
                        onPressed: () {
                          if (nameController.text.isEmpty || partition == null)
                            return;

                          final subject = SubjectModel(
                            name: nameController.text,
                            partition: partition!,
                          );

                          if (editingId == null) {
                            context.read<SubjectCubit>().addSubject(subject);
                          } else {
                            context
                                .read<SubjectCubit>()
                                .updateSubject(editingId!, subject);
                          }

                          Navigator.pop(ctx);
                        },
                        child: Text(editingId == null ? "Add" : "Update",style: TextStyle(color:Colors.white),),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _inputField(TextEditingController c, String hint) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: TextField(
        controller: c,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white54),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(12),
        ),
      ),
    );
  }

  Widget _dropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: DropdownButton<String>(
        value: partition,
        isExpanded: true,
        underline: const SizedBox(),
        dropdownColor: const Color(0xFF1E1E2E),
        hint: const Text(
          "Partition",
          style: TextStyle(color: Colors.white70),
        ),
        iconEnabledColor: Colors.white,
        style: const TextStyle(color: Colors.white),
        items: partitions.entries.map((e) {
          return DropdownMenuItem(
            value: e.key,
            child: Text(
              e.value,
              style: const TextStyle(color: Colors.white),
            ),
          );
        }).toList(),
        onChanged: (v) {
          setState(() {
            partition = v;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cardBg,
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => _openForm(),
        child: const Icon(Icons.add),
      ),
      body: BlocListener<SubjectCubit, SubjectState>(
        listener: (context, state) {
          if (state is SubjectsLoaded) {
            allSubjects = state.subjects;
            filteredSubjects = state.subjects;
            setState(() {});
          }

          if (state is SubjectAdded ||
              state is SubjectUpdated ||
              state is SubjectDeleted) {
            context.read<SubjectCubit>().getSubjects();
          }
        },
        child: Column(
          children: [
            // HEADER
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: AppGradients.cardGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Subjects",
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  SizedBox(height: 4),
                  Text("Manage school subjects",
                      style: TextStyle(color: Colors.white70)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _statBox("Full", _count("0"), Colors.blue),
                  const SizedBox(width: 10),
                  _statBox("First", _count("1"), Colors.green),
                  const SizedBox(width: 10),
                  _statBox("Second", _count("2"), Colors.orange),
                ],
              ),
            ),

            const SizedBox(height: 10),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: searchController,
                onChanged: _filter,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  icon: Icon(Icons.search, color: Colors.white54),
                  hintText: "Search...",
                  border: InputBorder.none,
                ),
              ),
            ),

            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: filteredSubjects.length,
                itemBuilder: (context, i) {
                  final s = filteredSubjects[i];
                  return Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: AppGradients.cardGradient,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.book, color: AppColors.primary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                s['name'] ?? '',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                partitions[s['partition'].toString()] ?? '',
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.white70),
                          onPressed: () => _openForm(subject: s),
                        ),
                        DeleteButton(
                          id: s['id'],
                          title: s['name'] ?? "subject",
                          onDelete: (id) async {
                            await context
                                .read<SubjectCubit>()
                                .deleteSubject(id);
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statBox(String title, int count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: AppGradients.cardGradient,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Column(
          children: [
            Text(
              "$count",
              style: TextStyle(
                  color: color, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(title,
                style: const TextStyle(color: Colors.white70, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  int _count(String p) {
    return allSubjects.where((e) => e['partition'].toString() == p).length;
  }
}
