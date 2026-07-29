import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_management/presentation/screen/widgets/class_content.dart';

import '../../cubit/class/class_cubit.dart';

import '../../constants/app_colors.dart' as app;

class ClassScreen extends StatelessWidget {
  const ClassScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: app.AppGradients.backgroundGradient,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text(
            'Classes Management',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Colors.white,
          actions: [
            // ✅ زر توزيع الطلاب (جديد)
            IconButton(
              icon: const Icon(Icons.auto_awesome_rounded),
              onPressed: () {
                _showDistributeDialog(context);
              },
              tooltip: 'Distribute Students',
            ),
            // زر التحديث
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: () {
                context.read<ClassCubit>().refreshClasses();
              },
            ),
          ],
        ),
        body: const ClassContent(),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            _showAddClassDialog(context);
          },
          backgroundColor: app.AppColors.primary,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add_rounded),
          label: const Text(
            'New Class',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  void _showAddClassDialog(BuildContext context) {
    final yearController = TextEditingController();
    final numberController = TextEditingController();
    final supervisorController = TextEditingController();

    InputDecoration darkField(String label, String hint) => InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.35)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: app.AppColors.primary),
          ),
        );

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1E2746),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title:
            const Text('Add New Class', style: TextStyle(color: Colors.white)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: yearController,
                style: const TextStyle(color: Colors.white),
                decoration: darkField('Grade Year (1-12)', 'e.g., 11'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: numberController,
                style: const TextStyle(color: Colors.white),
                decoration: darkField('Section Number', 'e.g., 1'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: supervisorController,
                style: const TextStyle(color: Colors.white),
                decoration: darkField(
                    'Supervisor ID (Optional)', 'Leave empty if none'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cancel',
                style: TextStyle(color: Colors.white.withOpacity(0.7))),
          ),
          ElevatedButton(
            onPressed: () {
              final year = int.tryParse(yearController.text.trim());
              final number = int.tryParse(numberController.text.trim());
              final supervisorId =
                  int.tryParse(supervisorController.text.trim());

              if (year != null && number != null && year >= 1 && year <= 12) {
                context.read<ClassCubit>().addClass(
                      year: year,
                      number: number,
                      supervisorId: supervisorId,
                    );
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Class added successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter valid year (1-12) and number'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: app.AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Add Class'),
          ),
        ],
      ),
    );
  }

  // ── ✅ نافذة توزيع الطلاب (جديد) ──
  void _showDistributeDialog(BuildContext context) {
    final capacityController = TextEditingController();

    InputDecoration darkField(String label, String hint) => InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.35)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: app.AppColors.primary),
          ),
        );

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1E2746),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Distribute Students',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Enter the maximum number of students per class',
              style: TextStyle(color: Colors.white.withOpacity(0.7)),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: capacityController,
              style: const TextStyle(color: Colors.white),
              decoration: darkField('Capacity per Class', 'e.g., 20'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cancel',
                style: TextStyle(color: Colors.white.withOpacity(0.7))),
          ),
          ElevatedButton(
            onPressed: () {
              final capacity = int.tryParse(capacityController.text.trim());
              if (capacity != null && capacity > 0) {
                context.read<ClassCubit>().distributeStudents(capacity);
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Students distributed successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a valid capacity'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: app.AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Distribute'),
          ),
        ],
      ),
    );
  }
}
