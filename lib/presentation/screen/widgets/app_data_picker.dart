import 'package:flutter/material.dart';
import 'package:school_management/constants/app_colors.dart';

class AppDatePicker extends StatelessWidget {
  final String label;
  final DateTime? date;
  final Function(DateTime) onPick;

  const AppDatePicker({
    super.key,
    required this.label,
    required this.date,
    required this.onPick,
  });

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1990),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      onPick(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _selectDate(context),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.cardElement,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.cardBorder.withOpacity(0.3)),
        ),
        child: Text(
          date == null ? label : "${date!.year}-${date!.month}-${date!.day}",
          style: const TextStyle(color: AppColors.textPrimary),
        ),
      ),
    );
  }
}
