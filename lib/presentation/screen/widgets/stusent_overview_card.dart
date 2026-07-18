import 'package:flutter/material.dart';
import 'package:school_management/constants/app_colors.dart';
import 'package:school_management/data/model/student_profile_model.dart';

class StudentOverviewCard extends StatelessWidget {
  final StudentProfileModel student;

  const StudentOverviewCard({
    super.key,
    required this.student,
  });

  @override
  Widget build(BuildContext context) {
    final fullName = "${student.firstName} ${student.lastName}".trim();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardElement,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.cardBorder.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 82,
            height: 82,
            decoration: const BoxDecoration(
              gradient: AppGradients.cardGradient,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              student.firstName.isNotEmpty
                  ? student.firstName[0].toUpperCase()
                  : "S",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 22),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        fullName.isEmpty ? "Student" : fullName,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    _statusBadge(),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  "Student",
                  style: TextStyle(
                    color: AppColors.textHelper,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 24,
                  runSpacing: 12,
                  children: [
                    _quickInfo(
                      Icons.wc_outlined,
                      student.gender,
                    ),
                    _quickInfo(
                      Icons.cake_outlined,
                      student.dob,
                    ),
                    _quickInfo(
                      Icons.favorite_outline,
                      student.healthStatus ?? "-",
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusBadge() {
    final status = student.status ?? "Unknown";

    Color color;

    switch (status.toLowerCase()) {
      case "enrolled":
        color = Colors.greenAccent;
        break;
      case "graduated":
        color = Colors.blueAccent;
        break;
      case "suspended":
      case "expelled":
        color = Colors.redAccent;
        break;
      default:
        color = Colors.orangeAccent;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _quickInfo(IconData icon, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: AppColors.primary,
          size: 18,
        ),
        const SizedBox(width: 7),
        Text(
          value.isEmpty ? "Not available" : value,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
