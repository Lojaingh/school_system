// lib/presentation/screen/widgets/attendance_content.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_management/constants/app_colors.dart';
import 'package:school_management/constants/app_colors.dart' as app;
import 'package:school_management/cubit/attendance/attendance_cubit.dart';
import 'package:school_management/data/model/class_students_model.dart';
import 'package:school_management/data/network/dio_client.dart';

class AttendanceContent extends StatefulWidget {
  final int? initialClassId;

  const AttendanceContent({super.key, this.initialClassId});

  @override
  State<AttendanceContent> createState() => _AttendanceContentState();
}

class _AttendanceContentState extends State<AttendanceContent> {
  int selectedTab = 0;

  // ✅ التاريخ مقفول على اليوم الحالي فقط — الباك ما بياخد تاريخ بالـ body
  // خالص (شفنا هيك بملف الـ Postman)، فالحضور دائماً بينسجل لليوم الحالي
  // وقت الاستدعاء. لهيك حذفنا أي إمكانية لتغيير التاريخ من المستخدم.
  final DateTime selectedDate = DateTime.now();

  // ✅ قائمة الصفوف من الـ API (سنملأها لاحقاً)
  List<Map<String, dynamic>> classList = [];
  int? selectedClassId;
  bool isLoadingClasses = true;

  // ✅ بيانات الطلاب من الـ API
  List<ClassStudent> students = [];
  int? currentClassId;

  // ✅ بيانات المعلمين (وهمية مؤقتاً لأن الباك ما عنده API)
  List<Map<String, dynamic>> teachers = [
    {
      'name': 'Ahmad Mahmod',
      'id': 'T001',
      'subject': 'Math',
      'status': 'Present',
      'time': '07:45'
    },
    {
      'name': 'Soad Mohamad',
      'id': 'T002',
      'subject': 'Science',
      'status': 'Present',
      'time': '07:50'
    },
    {
      'name': 'Khaled Ali',
      'id': 'T003',
      'subject': 'Arabic',
      'status': 'Late',
      'time': '08:20'
    },
    {
      'name': 'Nawal Hasan',
      'id': 'T004',
      'subject': 'English',
      'status': 'Absent',
      'time': '-'
    },
  ];

  String selectedDepartment = 'Math';
  final List<String> departmentList = ['Math', 'Science', 'Arabic', 'English'];

  @override
  void initState() {
    super.initState();
    _loadClasses();
  }

  Future<void> _loadClasses() async {
    setState(() {
      isLoadingClasses = true;
    });

    try {
      final response = await DioClient.dio.get('/class/all');

      if (response.statusCode == 200) {
        final data = response.data as List? ?? [];
        final List<Map<String, dynamic>> loadedClasses = [];

        for (var item in data) {
          loadedClasses.add({
            'id': item['id'],
            'year': item['year'],
            'number': item['number'],
            'display': 'Grade ${item['year']} - Section ${item['number']}',
          });
        }

        setState(() {
          classList = loadedClasses;
          if (classList.isNotEmpty) {
            // ✅ اختر أول صف في القائمة
            selectedClassId = classList[0]['id'];
            _loadStudents(selectedClassId!);
          }
          isLoadingClasses = false;
        });
      } else {
        throw Exception('Failed to load classes: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error loading classes: $e');
      setState(() {
        isLoadingClasses = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load classes: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _loadStudents(int classId) async {
    try {
      currentClassId = classId;
      print('🔵 Loading students for class: $classId');
      await context.read<AttendanceCubit>().loadClassStudents(classId);
    } catch (e) {
      print('❌ Error loading students for class $classId: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load students: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  // ❌ حذفنا _selectDate بالكامل — ما عاد في داعي لها بما إنه التاريخ
  // مقفول على اليوم الحالي ومش قابل للتغيير من المستخدم.

  @override
  Widget build(BuildContext context) {
    return BlocListener<AttendanceCubit, AttendanceState>(
      listener: (context, state) {
        if (state is AttendanceSaved) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.cardGreen,
            ),
          );
        } else if (state is AttendanceError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${state.message}'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            const Text(
              'Attendance',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Record and track attendance for students and teaching staff',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),

            // ✅ Tab Bar (Students + Teachers)
            Container(
              decoration: BoxDecoration(
                color: AppColors.cardBg.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildTabButton(
                      label: '👨‍🎓 Students',
                      index: 0,
                      selectedTab: selectedTab,
                      onTap: () => setState(() => selectedTab = 0),
                    ),
                  ),
                  Expanded(
                    child: _buildTabButton(
                      label: '👩‍🏫 Teachers',
                      index: 1,
                      selectedTab: selectedTab,
                      onTap: () => setState(() => selectedTab = 1),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ✅ Students Tab
            if (selectedTab == 0)
              BlocBuilder<AttendanceCubit, AttendanceState>(
                builder: (context, state) {
                  if (state is AttendanceLoading) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  } else if (state is AttendanceLoaded) {
                    students = state.data.students;
                    currentClassId = state.classId;

                    return _StudentsAttendanceContent(
                      students: students,
                      selectedDate: selectedDate,
                      classList: classList,
                      selectedClassId: selectedClassId,
                      isLoadingClasses: isLoadingClasses,
                      onClassChanged: (value) {
                        setState(() {
                          selectedClassId = value;
                          _loadStudents(value);
                        });
                      },
                      onSave: () => _saveAttendance(context),
                    );
                  } else if (state is AttendanceError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          children: [
                            Icon(
                              Icons.error_outline_rounded,
                              size: 48,
                              color: Colors.red.shade300,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              state.message,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                if (selectedClassId != null) {
                                  _loadStudents(selectedClassId!);
                                }
                              },
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),

            // ✅ Teachers Tab (بيانات وهمية مؤقتاً)
            if (selectedTab == 1)
              _TeachersAttendanceContent(
                teachers: teachers,
                selectedDepartment: selectedDepartment,
                selectedDate: selectedDate,
                departmentList: departmentList,
                onDepartmentChanged: (value) =>
                    setState(() => selectedDepartment = value),
                onSave: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Teachers attendance saved (coming soon)'),
                      backgroundColor: AppColors.cardGreen,
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton({
    required String label,
    required int index,
    required int selectedTab,
    required VoidCallback onTap,
  }) {
    final isSelected = selectedTab == index;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          gradient: isSelected ? app.AppGradients.primaryGradient : null,
          color: isSelected ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  // ── حفظ الحضور للطلاب ──
  void _saveAttendance(BuildContext context) {
    if (currentClassId == null || students.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No students to save attendance for'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // ✅ بناء المصفوفات
    final List<int> absent = [];
    final List<int> late = [];
    final List<int> excused = [];

    for (var student in students) {
      final status = student.status;
      final userId = student.userId;

      if (status == 'Absent') {
        absent.add(userId);
      } else if (status == 'Late') {
        late.add(userId);
      } else if (status == 'Excused') {
        excused.add(userId);
      }
      // ✅ Present لا نضيفه للمصفوفات — تلقائياً بيعتبر حاضر لأنه مش
      // موجود بأي وحدة من المصفوفات التلاتة، تماماً متل ما الباك متوقع.
    }

    print('📊 Absent: $absent');
    print('📊 Late: $late');
    print('📊 Excused: $excused');

    context.read<AttendanceCubit>().markAttendance(
          classId: currentClassId!,
          absent: absent,
          late: late,
          excused: excused,
        );
  }
}

// ── Students Attendance Content ─────────────────────────────────
class _StudentsAttendanceContent extends StatelessWidget {
  final List<ClassStudent> students;
  final DateTime selectedDate;
  final List<Map<String, dynamic>> classList;
  final int? selectedClassId;
  final bool isLoadingClasses;
  final Function(int) onClassChanged;
  final VoidCallback onSave;

  const _StudentsAttendanceContent({
    required this.students,
    required this.selectedDate,
    required this.classList,
    required this.selectedClassId,
    required this.isLoadingClasses,
    required this.onClassChanged,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _StudentsFilterRow(
          selectedDate: selectedDate,
          classList: classList,
          selectedClassId: selectedClassId,
          isLoadingClasses: isLoadingClasses,
          onClassChanged: onClassChanged,
        ),
        const SizedBox(height: 24),
        _AttendanceStats(
          total: students.length,
          present: students.where((s) => s.status == 'Present').length,
          absent: students.where((s) => s.status == 'Absent').length,
          late: students.where((s) => s.status == 'Late').length,
          excused: students.where((s) => s.status == 'Excused').length,
        ),
        const SizedBox(height: 24),
        const SizedBox(height: 24),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: MediaQuery.of(context).size.width - 48,
            child: _StudentsTable(students: students),
          ),
        ),
        const SizedBox(height: 20),
        _SaveButton(onSave: onSave),
      ],
    );
  }
}

// ── Teachers Attendance Content ─────────────────────────────────
class _TeachersAttendanceContent extends StatelessWidget {
  final List<Map<String, dynamic>> teachers;
  final String selectedDepartment;
  final DateTime selectedDate;
  final List<String> departmentList;
  final Function(String) onDepartmentChanged;
  final VoidCallback onSave;

  const _TeachersAttendanceContent({
    required this.teachers,
    required this.selectedDepartment,
    required this.selectedDate,
    required this.departmentList,
    required this.onDepartmentChanged,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _TeachersFilterRow(
          selectedDepartment: selectedDepartment,
          selectedDate: selectedDate,
          departmentList: departmentList,
          onDepartmentChanged: onDepartmentChanged,
        ),
        const SizedBox(height: 24),
        _AttendanceStats(
          total: teachers.length,
          present: teachers.where((t) => t['status'] == 'Present').length,
          absent: teachers.where((t) => t['status'] == 'Absent').length,
          late: teachers.where((t) => t['status'] == 'Late').length,
          excused: teachers.where((t) => t['status'] == 'Excused').length,
        ),
        const SizedBox(height: 24),
        const SizedBox(height: 24),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: MediaQuery.of(context).size.width - 48,
            child: _TeachersTable(teachers: teachers),
          ),
        ),
        const SizedBox(height: 20),
        _SaveButton(onSave: onSave),
      ],
    );
  }
}

// ── Students Filters Row ─────────────────────────────────────────
class _StudentsFilterRow extends StatelessWidget {
  final DateTime selectedDate;
  final List<Map<String, dynamic>> classList;
  final int? selectedClassId;
  final bool isLoadingClasses;
  final Function(int) onClassChanged;

  const _StudentsFilterRow({
    required this.selectedDate,
    required this.classList,
    required this.selectedClassId,
    required this.isLoadingClasses,
    required this.onClassChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: app.AppGradients.cardGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.cardShadow,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 500) {
            return Column(
              children: [
                _ClassDropdown(
                  classList: classList,
                  selectedClassId: selectedClassId,
                  isLoading: isLoadingClasses,
                  onChanged: onClassChanged,
                ),
                const SizedBox(height: 12),
                _TodayDateBadge(date: selectedDate),
              ],
            );
          } else {
            return Row(
              children: [
                Expanded(
                  child: _ClassDropdown(
                    classList: classList,
                    selectedClassId: selectedClassId,
                    isLoading: isLoadingClasses,
                    onChanged: onClassChanged,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _TodayDateBadge(date: selectedDate),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}

// ── Teachers Filters Row ─────────────────────────────────────────
class _TeachersFilterRow extends StatelessWidget {
  final String selectedDepartment;
  final DateTime selectedDate;
  final List<String> departmentList;
  final Function(String) onDepartmentChanged;

  const _TeachersFilterRow({
    required this.selectedDepartment,
    required this.selectedDate,
    required this.departmentList,
    required this.onDepartmentChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: app.AppGradients.cardGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.cardShadow,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 500) {
            return Column(
              children: [
                _FilterDropdown(
                  label: 'Department',
                  value: selectedDepartment,
                  items: departmentList,
                  onChanged: onDepartmentChanged,
                  icon: Icons.business_center_rounded,
                ),
                const SizedBox(height: 12),
                _TodayDateBadge(date: selectedDate),
              ],
            );
          } else {
            return Row(
              children: [
                Expanded(
                    child: _FilterDropdown(
                  label: 'Department',
                  value: selectedDepartment,
                  items: departmentList,
                  onChanged: onDepartmentChanged,
                  icon: Icons.business_center_rounded,
                )),
                const SizedBox(width: 16),
                Expanded(
                  child: _TodayDateBadge(date: selectedDate),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}

// ── Class Dropdown ─────────────────────────────────────────────
class _ClassDropdown extends StatelessWidget {
  final List<Map<String, dynamic>> classList;
  final int? selectedClassId;
  final bool isLoading;
  final Function(int) onChanged;

  const _ClassDropdown({
    required this.classList,
    required this.selectedClassId,
    required this.isLoading,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Class',
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.cardBorder.withOpacity(0.3)),
          ),
          child: isLoading
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: selectedClassId,
                    isExpanded: true,
                    icon: const Icon(Icons.class_rounded,
                        size: 18, color: AppColors.textSecondary),
                    dropdownColor: AppColors.cardBg,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                    ),
                    items: classList
                        .map((item) => DropdownMenuItem<int>(
                              value: item['id'],
                              child: Text(item['display']),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) onChanged(value);
                    },
                  ),
                ),
        ),
      ],
    );
  }
}

// ── Custom Dropdown ─────────────────────────────────────────────
class _FilterDropdown extends StatelessWidget {
  final String label;
  final String value;
  final List<String> items;
  final Function(String) onChanged;
  final IconData icon;

  const _FilterDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style:
                const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.cardBorder.withOpacity(0.3)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isExpanded: true,
                icon: Icon(icon, size: 18, color: AppColors.textSecondary),
                dropdownColor: AppColors.cardBg,
                style:
                    const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                items: items
                    .map((item) =>
                        DropdownMenuItem(value: item, child: Text(item)))
                    .toList(),
                onChanged: (newValue) {
                  if (newValue != null) onChanged(newValue);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── ✅ جديد: Badge للتاريخ الحالي (غير قابل للتعديل) ──
// حل مكان _DatePickerWidget القديم. بما إنه الباك بيسجل الحضور دائماً
// لليوم الحالي بس، خلينا هالودجت للعرض فقط بدون أي تفاعل (بدون onTap
// وبدون DatePicker) حتى ما يوهم المستخدم إنه فيه خيار لتغيير التاريخ.
class _TodayDateBadge extends StatelessWidget {
  final DateTime date;

  const _TodayDateBadge({required this.date});

  @override
  Widget build(BuildContext context) {
    final formatted =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Date',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.cardBorder.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Icon(Icons.today_rounded,
                  size: 18, color: AppColors.textSecondary.withOpacity(0.7)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '$formatted (Today)',
                  style: TextStyle(
                    color: AppColors.textPrimary.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ),
              Icon(Icons.lock_outline_rounded,
                  size: 14, color: AppColors.textSecondary.withOpacity(0.5)),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Attendance Statistics ─────────────────────────────────────────
class _AttendanceStats extends StatelessWidget {
  final int total;
  final int present;
  final int absent;
  final int late;
  final int excused;

  const _AttendanceStats({
    required this.total,
    required this.present,
    required this.absent,
    required this.late,
    required this.excused,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _StatChip(label: 'Total', value: '$total', color: AppColors.cardBlue),
          const SizedBox(width: 12),
          _StatChip(
              label: 'Present', value: '$present', color: AppColors.cardGreen),
          const SizedBox(width: 12),
          _StatChip(label: 'Absent', value: '$absent', color: AppColors.error),
          const SizedBox(width: 12),
          _StatChip(label: 'Late', value: '$late', color: AppColors.warning),
          const SizedBox(width: 12),
          _StatChip(label: 'Excused', value: '$excused', color: Colors.orange),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatChip(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        gradient: app.AppGradients.cardGradient,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppShadows.cardShadow,
      ),
      child: Row(
        children: [
          Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Text(label,
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(width: 8),
          Text(value,
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}

// ── Students Table ─────────────────────────────────────────────
class _StudentsTable extends StatelessWidget {
  final List<ClassStudent> students;

  const _StudentsTable({required this.students});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: app.AppGradients.cardGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.cardShadow,
      ),
      child: Column(
        children: [
          // Table Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                  bottom:
                      BorderSide(color: AppColors.cardBorder.withOpacity(0.3))),
            ),
            child: const Row(
              children: [
                Expanded(
                    flex: 2,
                    child: Text('Student',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary))),
                Expanded(
                    flex: 1,
                    child: Text('Status',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary))),
                Expanded(
                    flex: 1,
                    child: Text('Time',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary))),
              ],
            ),
          ),
          // Table Rows
          ...students.map((student) => _StudentRow(student: student)),
        ],
      ),
    );
  }
}

// ── Teachers Table ─────────────────────────────────────────────
class _TeachersTable extends StatelessWidget {
  final List<Map<String, dynamic>> teachers;

  const _TeachersTable({required this.teachers});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: app.AppGradients.cardGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.cardShadow,
      ),
      child: Column(
        children: [
          // Table Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                  bottom:
                      BorderSide(color: AppColors.cardBorder.withOpacity(0.3))),
            ),
            child: const Row(
              children: [
                Expanded(
                    flex: 2,
                    child: Text('Teacher',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary))),
                Expanded(
                    flex: 1,
                    child: Text('Subject',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary))),
                Expanded(
                    flex: 1,
                    child: Text('Status',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary))),
                Expanded(
                    flex: 1,
                    child: Text('Time',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary))),
              ],
            ),
          ),
          // Table Rows
          ...teachers.map((teacher) => _TeacherRow(teacher: teacher)),
        ],
      ),
    );
  }
}

// ── Student Row ─────────────────────────────────────
// ✅ ملاحظة مهمة: قائمة الحالة (Present/Absent/Late/Excused) هون هي
// حالة محلية بالواجهة بس، وما بتنبعت حرفياً "Present" للباك. لما تختار
// "Present" لطالب، الكود بـ _saveAttendance ببساطة ما بضيفه لأي مصفوفة
// (absent/late/excused)، وهيك تلقائياً بيعتبره الباك حاضر. فمنطقياً
// صحيح نبقيها موجودة — هي أداة توضيح لحالة كل طالب للمستخدم بس.
class _StudentRow extends StatefulWidget {
  final ClassStudent student;

  const _StudentRow({required this.student});

  @override
  State<_StudentRow> createState() => _StudentRowState();
}

class _StudentRowState extends State<_StudentRow> {
  late String selectedStatus;

  @override
  void initState() {
    super.initState();
    selectedStatus = widget.student.status;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
            bottom: BorderSide(color: AppColors.cardBorder.withOpacity(0.15))),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.primary.withOpacity(0.2),
                  child: Text(
                    widget.student.fullName.isNotEmpty
                        ? widget.student.fullName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.student.fullName,
                    style: const TextStyle(
                        fontSize: 14, color: AppColors.textPrimary),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Expanded(flex: 1, child: _buildStatusDropdown()),
          Expanded(
            flex: 1,
            child: Text(
              selectedStatus == 'Present'
                  ? '${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}'
                  : '-',
              style: TextStyle(
                fontSize: 13,
                color: selectedStatus == 'Present'
                    ? AppColors.cardGreen
                    : AppColors.textHelper,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedStatus,
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down, size: 20),
          dropdownColor: AppColors.cardBg,
          style: TextStyle(
            fontSize: 13,
            color: selectedStatus == 'Present'
                ? AppColors.cardGreen
                : selectedStatus == 'Absent'
                    ? AppColors.error
                    : selectedStatus == 'Late'
                        ? AppColors.warning
                        : Colors.orange,
          ),
          items: const [
            DropdownMenuItem(value: 'Present', child: Text('Present')),
            DropdownMenuItem(value: 'Absent', child: Text('Absent')),
            DropdownMenuItem(value: 'Late', child: Text('Late')),
            DropdownMenuItem(value: 'Excused', child: Text('Excused')),
          ],
          onChanged: (value) {
            setState(() {
              selectedStatus = value!;
              widget.student.status = value;
            });
          },
        ),
      ),
    );
  }
}

// ── Teacher Row ─────────────────────────────────────
class _TeacherRow extends StatefulWidget {
  final Map<String, dynamic> teacher;

  const _TeacherRow({required this.teacher});

  @override
  State<_TeacherRow> createState() => _TeacherRowState();
}

class _TeacherRowState extends State<_TeacherRow> {
  late String selectedStatus;

  @override
  void initState() {
    super.initState();
    selectedStatus = widget.teacher['status'];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
            bottom: BorderSide(color: AppColors.cardBorder.withOpacity(0.15))),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.primary.withOpacity(0.2),
                  child: Text(
                    widget.teacher['name'][0],
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.teacher['name'],
                    style: const TextStyle(
                        fontSize: 14, color: AppColors.textPrimary),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              widget.teacher['subject'],
              style:
                  const TextStyle(fontSize: 13, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(flex: 1, child: _buildStatusDropdown()),
          Expanded(
            flex: 1,
            child: Text(
              selectedStatus == 'Present' ? widget.teacher['time'] : '-',
              style: TextStyle(
                fontSize: 13,
                color: selectedStatus == 'Present'
                    ? AppColors.cardGreen
                    : AppColors.textHelper,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedStatus,
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down, size: 20),
          dropdownColor: AppColors.cardBg,
          style: TextStyle(
            fontSize: 13,
            color: selectedStatus == 'Present'
                ? AppColors.cardGreen
                : selectedStatus == 'Absent'
                    ? AppColors.error
                    : selectedStatus == 'Late'
                        ? AppColors.warning
                        : Colors.orange,
          ),
          items: const [
            DropdownMenuItem(value: 'Present', child: Text('Present')),
            DropdownMenuItem(value: 'Absent', child: Text('Absent')),
            DropdownMenuItem(value: 'Late', child: Text('Late')),
            DropdownMenuItem(value: 'Excused', child: Text('Excused')),
          ],
          onChanged: (value) => setState(() => selectedStatus = value!),
        ),
      ),
    );
  }
}

// ── Save Button ─────────────────────────────────────────────────
class _SaveButton extends StatelessWidget {
  final VoidCallback onSave;

  const _SaveButton({required this.onSave});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 200,
        height: 48,
        decoration: BoxDecoration(
          gradient: app.AppGradients.primaryGradient,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
                color: AppColors.primary.withOpacity(0.4), blurRadius: 12),
          ],
        ),
        child: ElevatedButton(
          onPressed: onSave,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.save_rounded, size: 20),
              SizedBox(width: 8),
              Text('Save Attendance',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Shadows ──────────────────────────────────────────────────
class AppShadows {
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x336C4CF1),
      blurRadius: 20,
      spreadRadius: 0,
      offset: Offset(0, 8),
    ),
  ];
}
