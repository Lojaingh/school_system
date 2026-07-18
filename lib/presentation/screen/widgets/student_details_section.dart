import 'package:flutter/material.dart';
import 'package:school_management/constants/app_colors.dart';
import 'package:school_management/data/model/student_profile_model.dart';

class StudentDetailsSection extends StatelessWidget {
  final StudentProfileModel student;

  const StudentDetailsSection({
    super.key,
    required this.student,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 850;

        if (!isDesktop) {
          return Column(
            children: [
              _personalCard(),
              const SizedBox(height: 16),
              _academicCard(),
              const SizedBox(height: 16),
              _healthCard(),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: _personalCard(),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  _academicCard(),
                  const SizedBox(height: 16),
                  _healthCard(),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _personalCard() {
    return _card(
      title: "Personal Information",
      icon: Icons.person_outline_rounded,
      child: Column(
        children: [
          _infoRow("First Name", student.firstName),
          _divider(),
          _infoRow("Last Name", student.lastName),
          _divider(),
          _infoRow("Gender", student.gender),
          _divider(),
          _infoRow("Date of Birth", student.dob),
        ],
      ),
    );
  }

  Widget _academicCard() {
    return _card(
      title: "Academic Information",
      icon: Icons.school_outlined,
      child: Column(
        children: [
          _infoRow(
            "Class",
            "Class ${student.classId ?? '-'}",
          ),
          _divider(),
          _infoRow(
            "Status",
            student.status ?? "Not available",
          ),
          _divider(),
          _infoRow("Role", "Student"),
        ],
      ),
    );
  }

  Widget _healthCard() {
    return _card(
      title: "Health Status",
      icon: Icons.favorite_border_rounded,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.redAccent.withOpacity(0.06),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Colors.redAccent.withOpacity(0.15),
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.health_and_safety_outlined,
              color: Colors.redAccent,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                student.healthStatus?.isNotEmpty == true
                    ? student.healthStatus!
                    : "No health information available",
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _card({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardElement,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.cardBorder.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: AppColors.primary,
                size: 21,
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: AppColors.textHelper,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? "Not available" : value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Divider(
      height: 1,
      color: AppColors.cardBorder.withOpacity(0.2),
    );
  }
}
