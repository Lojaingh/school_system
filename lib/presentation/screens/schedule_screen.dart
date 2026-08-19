import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_colors.dart' as app;
import '../../cubit/schedule/schedule_cubit.dart';
import '../../data/model/schedule_model.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  int? _selectedClassId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ScheduleCubit()..loadAll(),
      child: SizedBox.expand(
        child: Container(
          decoration: const BoxDecoration(
            gradient: app.AppGradients.backgroundGradient,
          ),
          child: BlocConsumer<ScheduleCubit, ScheduleState>(
            listener: (context, state) {},
            builder: (context, state) {
              if (state is ScheduleLoading || state is ScheduleInitial) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is ScheduleError) {
                return _buildErrorState(context, state.message);
              }

              final loaded = state as ScheduleLoaded;
              final classes = loaded.classes;

              // default to first class
              if (_selectedClassId == null && classes.isNotEmpty) {
                _selectedClassId = classes.first.id;
              }

              final classSlots = loaded.slots
                  .where((s) => s.classId == _selectedClassId)
                  .toList()
                ..sort((a, b) {
                  final dayCompare = a.dayOfWeek.compareTo(b.dayOfWeek);
                  if (dayCompare != 0) return dayCompare;
                  return a.periodNumber.compareTo(b.periodNumber);
                });

              return SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context, classes, loaded),
                    const SizedBox(height: 20),
                    if (classes.isEmpty)
                      _emptyBox(
                          'No classes found. Add a class from the Classes page first.')
                    else if (classSlots.isEmpty)
                      _emptyBox('No schedule slots added for this class yet.')
                    else
                      _buildWeekGroups(context, classSlots, loaded),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
      BuildContext context, List<ClassItem> classes, ScheduleLoaded loaded) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Weekly Schedule',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        Row(
          children: [
            if (classes.isNotEmpty) _buildClassDropdown(classes),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: classes.isEmpty
                  ? null
                  : () => _openEditDialog(context, loaded, existing: null),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Add Slot'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildClassDropdown(List<ClassItem> classes) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        gradient: app.AppGradients.cardGradient,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.cardBorder.withOpacity(0.4)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: _selectedClassId,
          dropdownColor: const Color(0xFF0A0F22),
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
          icon: const Icon(Icons.keyboard_arrow_down_rounded,
              color: AppColors.textSecondary),
          items: classes
              .map((c) => DropdownMenuItem(
                    value: c.id,
                    child: Text(c.name),
                  ))
              .toList(),
          onChanged: (val) => setState(() => _selectedClassId = val),
        ),
      ),
    );
  }

  Widget _buildWeekGroups(
      BuildContext context, List<ScheduleSlot> slots, ScheduleLoaded loaded) {
    final Map<int, List<ScheduleSlot>> byDay = {};
    for (final s in slots) {
      byDay.putIfAbsent(s.dayOfWeek, () => []).add(s);
    }
    final days = byDay.keys.toList()..sort();

    return Column(
      children: days.map((day) {
        final daySlots = byDay[day]!
          ..sort((a, b) => a.periodNumber.compareTo(b.periodNumber));
        final dayLabel = daySlots.first.dayName;
        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: app.AppGradients.cardGradient,
            borderRadius: BorderRadius.circular(14),
            boxShadow: app.AppShadows.cardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                dayLabel,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              ...daySlots.map((slot) => _buildSlotTile(context, slot, loaded)),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSlotTile(
      BuildContext context, ScheduleSlot slot, ScheduleLoaded loaded) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => _openEditDialog(context, loaded, existing: slot),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${slot.periodNumber}',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        slot.subjectName ?? 'Subject #${slot.subjectId}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        slot.teacherDisplayName,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_rounded,
                      size: 18, color: AppColors.textSecondary),
                  onPressed: () =>
                      _openEditDialog(context, loaded, existing: slot),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded,
                      size: 18, color: Colors.redAccent),
                  onPressed: () => _confirmDelete(context, slot),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _emptyBox(String text) {
    return Container(
      padding: const EdgeInsets.all(24),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: app.AppGradients.cardGradient,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(text, style: const TextStyle(color: AppColors.textSecondary)),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline_rounded, color: Colors.red, size: 40),
          const SizedBox(height: 8),
          Text('Failed to load schedule: $message',
              style: const TextStyle(color: Colors.red)),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => context.read<ScheduleCubit>().loadAll(),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, ScheduleSlot slot) {
    final cubit = context.read<ScheduleCubit>();
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: const Color(0xFF0A0F22),
        title: const Text('Delete Slot',
            style: TextStyle(color: AppColors.textPrimary)),
        content: Text(
          'Delete ${slot.subjectName ?? slot.subjectId} on ${slot.dayName} - Period ${slot.periodNumber}?',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogCtx);
              final ok = await cubit.deleteSchedule(slot.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content:
                          Text(ok ? 'Deleted successfully' : 'Delete failed')),
                );
              }
            },
            child:
                const Text('Delete', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  /// فلترة مؤقتة: الأساتذة يلي سبق درّسوا هاد المادة بأي حصة موجودة بالجدول.
  /// إذا ما في أي حصة سابقة لهاد المادة، بيرجع كل الأساتذة (احتياطي).
  /// TODO: استبدالها بفلترة حقيقية لما يوصلنا شكل GET /staff/{id} وفيه subject_id.
  List<StaffMember> _teachersForSubject(
    int? subjectId,
    List<StaffMember> allTeachers,
    List<ScheduleSlot> allSlots,
  ) {
    if (subjectId == null) return allTeachers;
    final teacherIds = allSlots
        .where((s) => s.subjectId == subjectId)
        .map((s) => s.teacherId)
        .toSet();
    if (teacherIds.isEmpty) return allTeachers;
    final filtered =
        allTeachers.where((t) => teacherIds.contains(t.id)).toList();
    return filtered.isEmpty ? allTeachers : filtered;
  }

  void _openEditDialog(BuildContext context, ScheduleLoaded loaded,
      {ScheduleSlot? existing}) {
    final cubit = context.read<ScheduleCubit>();
    if (_selectedClassId == null) return;

    final subjects = loaded.subjects;
    final allTeachers = loaded.teachers;

    int selectedDay = existing?.dayOfWeek ?? 0;
    int? selectedSubjectId = existing?.subjectId;
    int? selectedTeacherId = existing?.teacherId;
    final periodController =
        TextEditingController(text: (existing?.periodNumber ?? 1).toString());
    final academicYearController = TextEditingController(text: '2');

    // إذا القيمة الحالية مش موجودة بقائمة المواد (نادراً)، خليها null
    if (selectedSubjectId != null &&
        !subjects.any((s) => s.id == selectedSubjectId)) {
      selectedSubjectId = null;
    }

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (dialogCtx, setDialogState) {
          final filteredTeachers =
              _teachersForSubject(selectedSubjectId, allTeachers, loaded.slots);

          // إذا الأستاذ المختار حالياً مش من ضمن الأساتذة المفلترين، صفّر الاختيار
          if (selectedTeacherId != null &&
              !filteredTeachers.any((t) => t.id == selectedTeacherId)) {
            selectedTeacherId = null;
          }

          return AlertDialog(
            backgroundColor: const Color(0xFF0A0F22),
            title: Text(
              existing == null ? 'Add New Slot' : 'Edit Slot',
              style: const TextStyle(color: AppColors.textPrimary),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // النظام أسبوع 5 أيام بس: الأحد -> الخميس
                  _dialogDropdown<int>(
                    label: 'Day',
                    value: selectedDay,
                    items: List.generate(
                      ScheduleSlot.dayNames.length,
                      (i) => DropdownMenuItem(
                          value: i, child: Text(ScheduleSlot.dayNames[i])),
                    ),
                    onChanged: (v) =>
                        setDialogState(() => selectedDay = v ?? 0),
                  ),
                  const SizedBox(height: 12),
                  _dialogField('Period Number', periodController),
                  const SizedBox(height: 4),
                  _dialogDropdown<int>(
                    label: 'Subject',
                    value: selectedSubjectId,
                    hint: 'Select subject',
                    items: subjects
                        .map((s) =>
                            DropdownMenuItem(value: s.id, child: Text(s.name)))
                        .toList(),
                    onChanged: (v) => setDialogState(() {
                      selectedSubjectId = v;
                      // إعادة تعيين الأستاذ لما تتغير المادة، لأن قائمة الأساتذة رح تتغير
                      selectedTeacherId = null;
                    }),
                  ),
                  const SizedBox(height: 12),
                  _dialogDropdown<int>(
                    label: 'Teacher',
                    value: selectedTeacherId,
                    hint: selectedSubjectId == null
                        ? 'Select subject first'
                        : 'Select teacher',
                    items: filteredTeachers
                        .map((t) =>
                            DropdownMenuItem(value: t.id, child: Text(t.name)))
                        .toList(),
                    onChanged: (v) =>
                        setDialogState(() => selectedTeacherId = v),
                  ),
                  if (existing == null) ...[
                    const SizedBox(height: 12),
                    _dialogField('Academic Year ID', academicYearController),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogCtx),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (selectedSubjectId == null || selectedTeacherId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content:
                              Text('Please select a subject and a teacher')),
                    );
                    return;
                  }
                  final period = int.tryParse(periodController.text) ?? 1;

                  bool ok;
                  if (existing == null) {
                    final year = int.tryParse(academicYearController.text) ?? 1;
                    ok = await cubit.addSchedule(
                      classId: _selectedClassId!,
                      subjectId: selectedSubjectId!,
                      teacherId: selectedTeacherId!,
                      academicYearId: year,
                      dayOfWeek: selectedDay,
                      periodNumber: period,
                    );
                  } else {
                    ok = await cubit.updateSchedule(
                      id: existing.id,
                      dayOfWeek: selectedDay,
                      periodNumber: period,
                      subjectId: selectedSubjectId,
                      teacherId: selectedTeacherId,
                    );
                  }

                  if (dialogCtx.mounted) Navigator.pop(dialogCtx);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(ok
                            ? 'Saved successfully'
                            : 'Save failed, try again'),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _dialogField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
      ),
    );
  }

  Widget _dialogDropdown<T>({
    required String label,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
    String? hint,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(label,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 11)),
          ),
          DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              isExpanded: true,
              hint: Text(hint ?? '',
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 13)),
              dropdownColor: const Color(0xFF0A0F22),
              style:
                  const TextStyle(color: AppColors.textPrimary, fontSize: 13),
              icon: const Icon(Icons.keyboard_arrow_down_rounded,
                  color: AppColors.textSecondary),
              items: items,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
