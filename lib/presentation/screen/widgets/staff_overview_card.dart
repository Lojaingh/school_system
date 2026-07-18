import 'package:flutter/material.dart';
import 'package:school_management/constants/app_colors.dart';
import 'package:school_management/data/model/staff_profile_model.dart';

class StaffOverviewCard extends StatelessWidget {
  final StaffProfileModel staff;

  const StaffOverviewCard({
    super.key,
    required this.staff,
  });

  @override
  Widget build(BuildContext context) {
    final fullName = "${staff.firstName} ${staff.lastName}".trim();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardElement,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.cardBorder.withOpacity(.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 82,
            height: 82,
            decoration: BoxDecoration(
              gradient: AppGradients.cardGradient,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              staff.firstName.isNotEmpty
                  ? staff.firstName[0].toUpperCase()
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
                        fullName.isEmpty ? "Staff" : fullName,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    _roleBadge(),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  "Staff Member",
                  style: TextStyle(
                    color: AppColors.textHelper,
                  ),
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 24,
                  runSpacing: 12,
                  children: [
                    _info(
                      Icons.badge_outlined,
                      staff.role ?? "No Role",
                    ),
                    _info(
                      Icons.wc_outlined,
                      staff.gender,
                    ),
                    _info(
                      Icons.cake_outlined,
                      staff.dob,
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

  Widget _roleBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        staff.role ?? "Unknown",
        style: const TextStyle(
          color: Colors.blue,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _info(IconData icon, String value) {
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
