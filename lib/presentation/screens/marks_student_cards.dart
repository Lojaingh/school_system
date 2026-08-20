import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:school_management/constants/app_colors.dart';
import 'package:school_management/cubit/marks/marks_cubit.dart';
import 'package:school_management/data/model/subject_marks_model.dart';
import 'package:school_management/presentation/screen/widgets/marks_edit_dialog.dart';

class MarksStudentCard extends StatelessWidget {
  final StudentMark student;

  // الأستاذ + المدير
  final bool canEditMarks;

  const MarksStudentCard({
    super.key,
    required this.student,
    this.canEditMarks = false,
  });

  @override
  Widget build(BuildContext context) {
    final hasMarks = student.hasMarks;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppGradients.cardGradient,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: AppColors.cardBorder.withOpacity(.40),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.08),
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildAvatar(),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.studentName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      student.className ?? 'Class not assigned',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textHelper,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              _buildStatus(hasMarks),
            ],
          ),

          const SizedBox(height: 18),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.cardElement,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.cardBorder.withOpacity(.25),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calculate_outlined,
                  color: AppColors.primary,
                  size: 18,
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Total',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ),
                Text(
                  student.total == null
                      ? '—'
                      : student.total!.toStringAsFixed(1),
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          // فقط المدير والأستاذ يستطيعان إضافة / تعديل العلامات
          if (canEditMarks)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (dialogContext) {
                      return BlocProvider.value(
                        value: context.read<MarksCubit>(),
                        child: MarksEditDialog(
                          student: student,
                        ),
                      );
                    },
                  );
                },
                icon: const Icon(
                  Icons.edit_outlined,
                  size: 17,
                ),
                label: Text(
                  hasMarks ? 'Edit Marks' : 'Add Marks',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary.withOpacity(.12),
                  foregroundColor: AppColors.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(11),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    final name = student.studentName.trim();

    final letter = name.isEmpty ? '?' : name.substring(0, 1).toUpperCase();

    return Container(
      width: 44,
      height: 44,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
      ),
      child: Text(
        letter,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStatus(bool hasMarks) {
    final color = hasMarks ? Colors.green : Colors.orange;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        hasMarks ? 'Recorded' : 'Pending',
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
