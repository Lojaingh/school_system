import 'package:flutter/material.dart';
import 'package:school_management/constants/app_colors.dart';
import 'package:school_management/data/model/staff_profile_model.dart';

class StaffDetailsSection extends StatelessWidget {
  final StaffProfileModel staff;

  const StaffDetailsSection({
    super.key,
    required this.staff,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final desktop = constraints.maxWidth >= 850;

        if (!desktop) {
          return Column(
            children: [
              _personalCard(),
              const SizedBox(height: 16),
              _employmentCard(),
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
              child: _employmentCard(),
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
          _row("First Name", staff.firstName),
          _divider(),
          _row("Last Name", staff.lastName),
          _divider(),
          _row("Gender", staff.gender),
          _divider(),
          _row("Date of Birth", staff.dob),
          _divider(),
          _row("Username", staff.username ?? "-"),
        ],
      ),
    );
  }

  Widget _employmentCard() {
    return _card(
      title: "Employment Information",
      icon: Icons.work_outline_rounded,
      child: Column(
        children: [
          _row("Role", staff.role ?? "-"),
          _divider(),
          _row("Started At", staff.startedAt ?? "-"),
          _divider(),
          _row(
            "Status",
            staff.finishedAt == null ? "Active" : "Finished",
          ),
        ],
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
        gradient: AppGradients.cardGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.cardBorder,
        ),
        boxShadow: AppShadows.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 17,
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

  Widget _row(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
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
                fontWeight: FontWeight.w600,
                fontSize: 14,
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
      color: AppColors.cardBorder,
    );
  }
}
