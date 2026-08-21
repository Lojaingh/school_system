import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:school_management/constants/app_colors.dart';
import 'package:school_management/cubit/marks/marks_cubit.dart';
import 'package:school_management/cubit/marks/marks_state.dart';
import 'package:school_management/data/model/subject_marks_model.dart';
import 'package:school_management/presentation/screens/marks_student_cards.dart';
import 'package:school_management/utils/shared_prefs_helper.dart';

class MarksScreen extends StatefulWidget {
  const MarksScreen({
    super.key,
  });

  @override
  State<MarksScreen> createState() => _MarksScreenState();
}

class _MarksScreenState extends State<MarksScreen> {
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';
  String _userRole = '';

  int? _selectedClassId;
  int? _selectedSubjectId;

  @override
  void initState() {
    super.initState();

    _loadUserRole();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<MarksCubit>().getSubjectMarks();
      }
    });

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  Future<void> _loadUserRole() async {
    final role = await SharedPrefsHelper.getRole();

    if (!mounted) return;

    setState(() {
      _userRole = role?.trim().toLowerCase() ?? '';
    });
  }

  bool get _isTeacher => _userRole == 'teacher';

  bool get _isManager => _userRole == 'manager';

  bool get _isSupervisor => _userRole == 'supervisor';

  bool get _canEditMarks {
    return _isTeacher || _isManager || _isSupervisor;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<StudentMark> _filterStudents(
    List<StudentMark> students,
  ) {
    if (_searchQuery.isEmpty) {
      return students;
    }

    return students.where((student) {
      final name = student.studentName.toLowerCase();

      final className = student.className?.toLowerCase() ?? '';

      return name.contains(_searchQuery) || className.contains(_searchQuery);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppGradients.backgroundGradient,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: BlocConsumer<MarksCubit, MarksState>(
          listener: (context, state) {
            if (state is MarksSaved) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    state.response.message,
                  ),
                  backgroundColor: Colors.green,
                ),
              );

              context.read<MarksCubit>().getSubjectMarks();
            }

            if (state is MarksError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.redAccent,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is MarksInitial || state is MarksLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                ),
              );
            }

            if (state is MarksError) {
              return _buildError(context);
            }

            if (state is MarksLoaded) {
              return _buildContent(
                context,
                state.data,
              );
            }

            if (state is MarksSaving) {
              return _buildSaving();
            }

            if (state is MarksSaved) {
              return _buildSavedFallback();
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    SubjectMarksData data,
  ) {
    // ==========================================================
    // TEACHER
    // ==========================================================
    if (_isTeacher || !data.isGrouped) {
      final students = _filterStudents(data.students);

      final recordedCount = data.students
          .where(
            (student) => student.hasMarks,
          )
          .length;

      final pendingCount = data.students.length - recordedCount;

      final totals = data.students
          .map(
            (student) => student.total,
          )
          .whereType<double>()
          .toList();

      final double? average = totals.isEmpty
          ? null
          : totals.reduce(
                (a, b) => a + b,
              ) /
              totals.length;

      final subjectTitle = data.subjectName?.trim().isNotEmpty == true
          ? data.subjectName!
          : 'Subject #${data.subjectId}';

      return _buildStudentList(
        context: context,
        students: students,
        subjectTitle: subjectTitle,
        total: data.students.length,
        recorded: recordedCount,
        pending: pendingCount,
        average: average,
      );
    }

    // ==========================================================
    // MANAGER / SUPERVISOR
    // ==========================================================

    final classes = data.availableClasses;

    final subjects = data.availableSubjects;

    // أول تحميل:
    if (_selectedClassId == null && classes.isNotEmpty) {
      _selectedClassId = classes.first.classId;
    }

    if (_selectedSubjectId == null && subjects.isNotEmpty) {
      _selectedSubjectId = subjects.first.id;
    }

    final selectedClass = classes
        .where(
          (item) => item.classId == _selectedClassId,
        )
        .toList();

    final selectedClassName = selectedClass.isNotEmpty
        ? selectedClass.first.className
        : 'All Classes';

    final selectedSubject = subjects
        .where(
          (item) => item.id == _selectedSubjectId,
        )
        .toList();

    final selectedSubjectName = selectedSubject.isNotEmpty
        ? selectedSubject.first.name
        : 'Select Subject';

    final students = _selectedSubjectId == null
        ? <StudentMark>[]
        : _filterStudents(
            data.studentsForSubject(
              subjectId: _selectedSubjectId!,
              classId: _selectedClassId,
            ),
          );

    final allStudentsForStats = _selectedSubjectId == null
        ? <StudentMark>[]
        : data.studentsForSubject(
            subjectId: _selectedSubjectId!,
            classId: _selectedClassId,
          );

    final recordedCount = allStudentsForStats
        .where(
          (student) => student.hasMarks,
        )
        .length;

    final pendingCount = allStudentsForStats.length - recordedCount;

    final totals = allStudentsForStats
        .map(
          (student) => student.total,
        )
        .whereType<double>()
        .toList();

    final double? average = totals.isEmpty
        ? null
        : totals.reduce(
              (a, b) => a + b,
            ) /
            totals.length;

    return Column(
      children: [
        _buildGroupedHeader(
          context,
          className: selectedClassName,
          subjectName: selectedSubjectName,
          classes: classes,
          subjects: subjects,
        ),
        _buildStats(
          total: allStudentsForStats.length,
          recorded: recordedCount,
          pending: pendingCount,
          average: average,
        ),
        _buildSearch(),
        Expanded(
          child: students.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () async {
                    await context.read<MarksCubit>().getSubjectMarks();
                  },
                  child: GridView.builder(
                    padding: const EdgeInsets.fromLTRB(
                      24,
                      12,
                      24,
                      24,
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 430,
                      mainAxisExtent: 255,
                      crossAxisSpacing: 18,
                      mainAxisSpacing: 18,
                    ),
                    itemCount: students.length,
                    itemBuilder: (context, index) {
                      return MarksStudentCard(
                        student: students[index],
                        canEditMarks: _canEditMarks,
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildStudentList({
    required BuildContext context,
    required List<StudentMark> students,
    required String subjectTitle,
    required int total,
    required int recorded,
    required int pending,
    required double? average,
  }) {
    return Column(
      children: [
        _buildHeader(subjectTitle),
        _buildStats(
          total: total,
          recorded: recorded,
          pending: pending,
          average: average,
        ),
        _buildSearch(),
        Expanded(
          child: students.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () async {
                    await context.read<MarksCubit>().getSubjectMarks();
                  },
                  child: GridView.builder(
                    padding: const EdgeInsets.fromLTRB(
                      24,
                      12,
                      24,
                      24,
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 430,
                      mainAxisExtent: 235,
                      crossAxisSpacing: 18,
                      mainAxisSpacing: 18,
                    ),
                    itemCount: students.length,
                    itemBuilder: (context, index) {
                      return MarksStudentCard(
                        student: students[index],
                        canEditMarks: _canEditMarks,
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildGroupedHeader(
    BuildContext context, {
    required String className,
    required String subjectName,
    required List<MarksClass> classes,
    required List<SubjectInfo> subjects,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        gradient: AppGradients.cardGradient,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(.12),
                  borderRadius: BorderRadius.circular(
                    12,
                  ),
                ),
                child: const Icon(
                  Icons.grade_outlined,
                  color: AppColors.primary,
                  size: 25,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Text(
                  'Student Marks',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Refresh',
                onPressed: () {
                  context.read<MarksCubit>().getSubjectMarks();
                },
                icon: const Icon(
                  Icons.refresh_rounded,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _buildDropdownContainer<int>(
                  label: 'Class',
                  value: _selectedClassId,
                  items: classes
                      .map(
                        (item) => DropdownMenuItem<int>(
                          value: item.classId,
                          child: Text(
                            item.className,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedClassId = value;
                    });
                  },
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _buildDropdownContainer<int>(
                  label: 'Subject',
                  value: _selectedSubjectId,
                  items: subjects
                      .map(
                        (item) => DropdownMenuItem<int>(
                          value: item.id,
                          child: Text(
                            item.name,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedSubjectId = value;
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '$className • $subjectName',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownContainer<T>({
    required String label,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
      ),
      decoration: BoxDecoration(
        color: AppColors.cardElement,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.cardBorder.withOpacity(
            .35,
          ),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          dropdownColor: AppColors.cardBg,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 13,
          ),
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildHeader(
    String subjectTitle,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        gradient: AppGradients.cardGradient,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(.12),
              borderRadius: BorderRadius.circular(
                12,
              ),
            ),
            child: const Icon(
              Icons.grade_outlined,
              color: AppColors.primary,
              size: 25,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Student Marks',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subjectTitle,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Refresh',
            onPressed: () {
              context.read<MarksCubit>().getSubjectMarks();
            },
            icon: const Icon(
              Icons.refresh_rounded,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats({
    required int total,
    required int recorded,
    required int pending,
    required double? average,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        24,
        20,
        24,
        0,
      ),
      child: Row(
        children: [
          Expanded(
            child: _StatItem(
              title: 'Students',
              value: total.toString(),
              icon: Icons.groups_outlined,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _StatItem(
              title: 'Recorded',
              value: recorded.toString(),
              icon: Icons.check_circle_outline_rounded,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _StatItem(
              title: 'Pending',
              value: pending.toString(),
              icon: Icons.access_time_rounded,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _StatItem(
              title: 'Average',
              value: average == null ? '—' : average.toStringAsFixed(1),
              icon: Icons.analytics_outlined,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearch() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        24,
        18,
        24,
        6,
      ),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 13,
        ),
        decoration: InputDecoration(
          hintText: 'Search student or class...',
          hintStyle: const TextStyle(
            color: AppColors.textHelper,
            fontSize: 12,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppColors.textSecondary,
            size: 20,
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  onPressed: _searchController.clear,
                  icon: const Icon(
                    Icons.close_rounded,
                    color: AppColors.textSecondary,
                  ),
                )
              : null,
          filled: true,
          fillColor: AppColors.cardElement,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              13,
            ),
            borderSide: BorderSide(
              color: AppColors.cardBorder.withOpacity(.35),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              13,
            ),
            borderSide: BorderSide(
              color: AppColors.cardBorder.withOpacity(.35),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              13,
            ),
            borderSide: BorderSide(
              color: AppColors.primary.withOpacity(.55),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.person_search_rounded,
            color: AppColors.textHelper,
            size: 46,
          ),
          SizedBox(height: 12),
          Text(
            'No students found',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 5),
          Text(
            'Try a different selection or search term.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(
    BuildContext context,
  ) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: Colors.redAccent,
            size: 46,
          ),
          const SizedBox(height: 12),
          const Text(
            'Something went wrong',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              context.read<MarksCubit>().getSubjectMarks();
            },
            icon: const Icon(
              Icons.refresh_rounded,
            ),
            label: const Text(
              'Try Again',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaving() {
    return Stack(
      children: [
        Positioned.fill(
          child: Container(
            color: Colors.black.withOpacity(.08),
          ),
        ),
        const Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildSavedFallback() {
    return const Center(
      child: CircularProgressIndicator(
        color: AppColors.primary,
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _StatItem({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: AppColors.cardElement,
        borderRadius: BorderRadius.circular(
          13,
        ),
        border: Border.all(
          color: AppColors.cardBorder.withOpacity(.35),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppColors.primary,
            size: 19,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textHelper,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(
                  height: 2,
                ),
                Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
