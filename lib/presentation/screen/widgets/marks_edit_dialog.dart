import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_management/constants/app_colors.dart';
import 'package:school_management/cubit/marks/marks_cubit.dart';
import 'package:school_management/cubit/marks/marks_state.dart';

import 'package:school_management/data/model/subject_marks_model.dart';

class MarksEditDialog extends StatefulWidget {
  final StudentMark student;

  const MarksEditDialog({
    super.key,
    required this.student,
  });

  @override
  State<MarksEditDialog> createState() => _MarksEditDialogState();
}

class _MarksEditDialogState extends State<MarksEditDialog> {
  late final TextEditingController _participation;
  late final TextEditingController _firstQuiz;
  late final TextEditingController _midterm;
  late final TextEditingController _secondQuiz;
  late final TextEditingController _finalExam;

  @override
  void initState() {
    super.initState();

    _participation = _createController(
      widget.student.participation,
    );

    _firstQuiz = _createController(
      widget.student.firstQuiz,
    );

    _midterm = _createController(
      widget.student.midtermExam,
    );

    _secondQuiz = _createController(
      widget.student.secondQuiz,
    );

    _finalExam = _createController(
      widget.student.finalExam,
    );
  }

  TextEditingController _createController(
    double? value,
  ) {
    return TextEditingController(
      text: value?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _participation.dispose();
    _firstQuiz.dispose();
    _midterm.dispose();
    _secondQuiz.dispose();
    _finalExam.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.cardBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.edit_note_rounded,
              color: AppColors.primary,
              size: 21,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Marks — ${widget.student.studentName}',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildField(
                'Participation',
                _participation,
                Icons.forum_outlined,
              ),
              _buildField(
                'First Quiz',
                _firstQuiz,
                Icons.quiz_outlined,
              ),
              _buildField(
                'Midterm Exam',
                _midterm,
                Icons.assignment_outlined,
              ),
              _buildField(
                'Second Quiz',
                _secondQuiz,
                Icons.fact_check_outlined,
              ),
              _buildField(
                'Final Exam',
                _finalExam,
                Icons.school_outlined,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text(
            'Cancel',
          ),
        ),
        BlocBuilder<MarksCubit, MarksState>(
          builder: (context, state) {
            final isSaving = state is MarksSaving;

            return ElevatedButton.icon(
              onPressed: isSaving ? null : _save,
              icon: isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(
                      Icons.save_outlined,
                      size: 17,
                    ),
              label: const Text(
                'Save',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 12,
      ),
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(
          decimal: true,
        ),
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 13,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            color: AppColors.textSecondary,
          ),
          prefixIcon: Icon(
            icon,
            color: AppColors.primary,
            size: 20,
          ),
          filled: true,
          fillColor: AppColors.cardElement,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(11),
            borderSide: BorderSide(
              color: AppColors.cardBorder.withOpacity(.4),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(11),
            borderSide: BorderSide(
              color: AppColors.cardBorder.withOpacity(.4),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(11),
            borderSide: const BorderSide(
              color: AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }

  void _save() {
    final participation = double.tryParse(_participation.text.trim());

    final firstQuiz = double.tryParse(_firstQuiz.text.trim());

    final midterm = double.tryParse(_midterm.text.trim());

    final secondQuiz = double.tryParse(_secondQuiz.text.trim());

    final finalExam = double.tryParse(_finalExam.text.trim());

    if (participation == null ||
        firstQuiz == null ||
        midterm == null ||
        secondQuiz == null ||
        finalExam == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter valid marks for all fields.',
          ),
        ),
      );
      return;
    }

    context.read<MarksCubit>().saveStudentMarks(
          studentId: widget.student.studentId,
          participation: participation,
          firstQuiz: firstQuiz,
          midtermExam: midterm,
          secondQuiz: secondQuiz,
          finalExam: finalExam,
        );

    Navigator.pop(context);
  }
}
