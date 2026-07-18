import 'package:flutter/material.dart';
import 'package:school_management/data/model/student_profile_model.dart';

class StatsRow extends StatelessWidget {
  final List students;

  const StatsRow({super.key, required this.students});

  int get total => students.length;

  int get male =>
      students.where((e) => e.gender.toLowerCase() == "male").length;

  int get female =>
      students.where((e) => e.gender.toLowerCase() == "female").length;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildCard("Total", total.toString(), Colors.blue),
          const SizedBox(width: 10),
          _buildCard("Male", male.toString(), Colors.green),
          const SizedBox(width: 10),
          _buildCard("Female", female.toString(), Colors.pink),
        ],
      ),
    );
  }

  Widget _buildCard(String title, String count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(
              count,
              style: TextStyle(
                color: color,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
