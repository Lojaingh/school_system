import 'package:flutter/material.dart';
import 'package:school_management/constants/app_colors.dart';
import 'package:school_management/data/model/external_model.dart';

class ExternalCard extends StatelessWidget {
  final ExternalModel external;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool canManage;

  const ExternalCard({
    super.key,
    required this.external,
    this.onEdit,
    this.onDelete,
    this.canManage = false,
  });

  IconData _fileIcon() {
    switch (external.extension.toLowerCase()) {
      case "pdf":
        return Icons.picture_as_pdf_rounded;
      case "doc":
      case "docx":
        return Icons.article_rounded;
      case "jpg":
      case "jpeg":
      case "png":
      case "webp":
        return Icons.image_rounded;
      case "xls":
      case "xlsx":
        return Icons.table_chart_rounded;
      case "ppt":
      case "pptx":
        return Icons.slideshow_rounded;
      default:
        return Icons.insert_drive_file_rounded;
    }
  }

  Color _fileColor() {
    switch (external.extension.toLowerCase()) {
      case "pdf":
        return Colors.redAccent;
      case "doc":
      case "docx":
        return Colors.blueAccent;
      case "jpg":
      case "jpeg":
      case "png":
      case "webp":
        return Colors.tealAccent.shade400;
      case "xls":
      case "xlsx":
        return Colors.greenAccent.shade400;
      case "ppt":
      case "pptx":
        return Colors.orangeAccent;
      default:
        return AppColors.primary;
    }
  }

  String _academicYear() {
    return "Academic Year ${external.academicId}";
  }

  String _createdDate() {
    if (external.createdAt == null || external.createdAt!.trim().isEmpty) {
      return "Unknown date";
    }
    final value = external.createdAt!;
    if (value.length >= 10) {
      final date = value.substring(0, 10);
      final parts = date.split('-');
      if (parts.length == 3) {
        return "${parts[2]}/${parts[1]}/${parts[0]}";
      }
    }
    return value;
  }

  Widget _infoRow({
    required IconData icon,
    required String text,
  }) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(.10),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(
            icon,
            size: 17,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final fileColor = _fileColor();
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppGradients.cardGradient,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.cardBorder,
        ),
        boxShadow: AppShadows.cardShadow,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: fileColor.withOpacity(.10),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: fileColor.withOpacity(.18),
                  ),
                ),
                child: Icon(
                  _fileIcon(),
                  color: fileColor,
                  size: 27,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ".${external.extension.toUpperCase()}",
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      "External File",
                      style: TextStyle(
                        color: AppColors.textHelper,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              if (canManage)
                PopupMenuButton<String>(
                  color: AppColors.cardBg,
                  padding: EdgeInsets.zero,
                  icon: const Icon(
                    Icons.more_horiz_rounded,
                    color: AppColors.textSecondary,
                    size: 25,
                  ),
                  onSelected: (value) {
                    if (value == "edit") {
                      onEdit?.call();
                    } else if (value == "delete") {
                      onDelete?.call();
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(
                      value: "edit",
                      child: Row(
                        children: [
                          Icon(
                            Icons.edit_rounded,
                            color: AppColors.primary,
                          ),
                          SizedBox(width: 10),
                          Text(
                            "Edit",
                            style: TextStyle(
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: "delete",
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete_outline_rounded,
                            color: Colors.redAccent,
                          ),
                          SizedBox(width: 10),
                          Text(
                            "Delete",
                            style: TextStyle(
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 17),
          _infoRow(
            icon: Icons.school_rounded,
            text: external.classLabel ?? "Class ${external.schoolClassId}",
          ),
          const SizedBox(height: 9),
          if (external.teacherName != null &&
              external.teacherName!.isNotEmpty) ...[
            _infoRow(
              icon: Icons.person_rounded,
              text: external.teacherName!,
            ),
            const SizedBox(height: 9),
          ],
          _infoRow(
            icon: Icons.calendar_month_rounded,
            text: _academicYear(),
          ),
          const SizedBox(height: 9),
          _infoRow(
            icon: Icons.schedule_rounded,
            text: "Added ${_createdDate()}",
          ),
          const SizedBox(height: 13),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 11,
            ),
            decoration: BoxDecoration(
              color: AppColors.cardElement.withOpacity(.55),
              borderRadius: BorderRadius.circular(11),
              border: Border.all(
                color: AppColors.cardBorder.withOpacity(.25),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.notes_rounded,
                  size: 19,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    external.notes?.isNotEmpty == true
                        ? external.notes!
                        : "No notes",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (canManage) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(
                      Icons.edit_rounded,
                      size: 19,
                    ),
                    label: const Text(
                      "Edit",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: BorderSide(
                        color: AppColors.primary.withOpacity(.65),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 13,
                      ),
                      minimumSize: const Size(
                        0,
                        46,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(11),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  onPressed: onDelete,
                  tooltip: "Delete",
                  padding: const EdgeInsets.all(10),
                  constraints: const BoxConstraints(
                    minWidth: 46,
                    minHeight: 46,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.redAccent.withOpacity(.10),
                    foregroundColor: Colors.redAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(11),
                    ),
                  ),
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    size: 22,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
