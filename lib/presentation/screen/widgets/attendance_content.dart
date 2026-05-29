// lib/presentation/widgets/attendance_content.dart

import 'package:flutter/material.dart';
import 'package:school_management/constants/app_colors.dart';
import 'package:school_management/constants/app_colors.dart' as app;

class AttendanceContent extends StatefulWidget {
  const AttendanceContent({super.key});

  @override
  State<AttendanceContent> createState() => _AttendanceContentState();
}

class _AttendanceContentState extends State<AttendanceContent> {
  // Tab index (0 = Students, 1 = Teachers)
  int selectedTab = 0;

  // Common filters
  String selectedClass = 'Grade 7';
  String selectedSection = 'A';
  DateTime selectedDate = DateTime.now();

  // Teachers data
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

  // Teachers filters
  String selectedDepartment = 'Math';
  final List<String> departmentList = ['Math', 'Science', 'Arabic', 'English'];

  // Students data
  List<Map<String, dynamic>> students = [
    {
      'name': 'Mohamad Ahmad',
      'id': '001',
      'status': 'Present',
      'time': '07:45'
    },
    {'name': 'Sara Khaled', 'id': '002', 'status': 'Absent', 'time': '-'},
    {'name': 'Ali Mahmod', 'id': '003', 'status': 'Present', 'time': '08:15'},
    {'name': 'Nour Hasan', 'id': '004', 'status': 'Present', 'time': '07:50'},
    {'name': 'Lili Omar', 'id': '005', 'status': 'Late', 'time': '08:30'},
    {'name': 'Khaled Waleed', 'id': '006', 'status': 'Absent', 'time': '-'},
    {'name': 'Sana Ali', 'id': '007', 'status': 'Present', 'time': '07:55'},
    {'name': 'Kareem Samir', 'id': '008', 'status': 'Present', 'time': '07:48'},
  ];

  final List<String> classList = ['Grade 7', 'Grade 8', 'Grade 9'];
  final List<String> sectionList = ['A', 'B', 'C', 'D'];

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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

          // Tab Bar
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

          // Content based on selected tab
          selectedTab == 0
              ? _StudentsAttendanceContent(
                  students: students,
                  selectedClass: selectedClass,
                  selectedSection: selectedSection,
                  selectedDate: selectedDate,
                  classList: classList,
                  sectionList: sectionList,
                  onClassChanged: (value) =>
                      setState(() => selectedClass = value),
                  onSectionChanged: (value) =>
                      setState(() => selectedSection = value),
                  onDateTap: () => _selectDate(context),
                )
              : _TeachersAttendanceContent(
                  teachers: teachers,
                  selectedDepartment: selectedDepartment,
                  selectedDate: selectedDate,
                  departmentList: departmentList,
                  onDepartmentChanged: (value) =>
                      setState(() => selectedDepartment = value),
                  onDateTap: () => _selectDate(context),
                ),
        ],
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
}

// ── Students Attendance Content ─────────────────────────────────
class _StudentsAttendanceContent extends StatelessWidget {
  final List<Map<String, dynamic>> students;
  final String selectedClass;
  final String selectedSection;
  final DateTime selectedDate;
  final List<String> classList;
  final List<String> sectionList;
  final Function(String) onClassChanged;
  final Function(String) onSectionChanged;
  final VoidCallback onDateTap;

  const _StudentsAttendanceContent({
    required this.students,
    required this.selectedClass,
    required this.selectedSection,
    required this.selectedDate,
    required this.classList,
    required this.sectionList,
    required this.onClassChanged,
    required this.onSectionChanged,
    required this.onDateTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _StudentsFilterRow(
          selectedClass: selectedClass,
          selectedSection: selectedSection,
          selectedDate: selectedDate,
          classList: classList,
          sectionList: sectionList,
          onClassChanged: onClassChanged,
          onSectionChanged: onSectionChanged,
          onDateTap: onDateTap,
        ),
        const SizedBox(height: 24),
        _AttendanceStats(
          total: students.length,
          present: students.where((s) => s['status'] == 'Present').length,
          absent: students.where((s) => s['status'] == 'Absent').length,
          late: students.where((s) => s['status'] == 'Late').length,
        ),
        const SizedBox(height: 24),
        const _ActionButtons(),
        const SizedBox(height: 24),
        // Wrap table in SingleChildScrollView horizontally to fix overflow
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: MediaQuery.of(context).size.width - 48,
            child: _StudentsTable(students: students),
          ),
        ),
        const SizedBox(height: 20),
        const _SaveButton(),
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
  final VoidCallback onDateTap;

  const _TeachersAttendanceContent({
    required this.teachers,
    required this.selectedDepartment,
    required this.selectedDate,
    required this.departmentList,
    required this.onDepartmentChanged,
    required this.onDateTap,
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
          onDateTap: onDateTap,
        ),
        const SizedBox(height: 24),
        _AttendanceStats(
          total: teachers.length,
          present: teachers.where((t) => t['status'] == 'Present').length,
          absent: teachers.where((t) => t['status'] == 'Absent').length,
          late: teachers.where((t) => t['status'] == 'Late').length,
        ),
        const SizedBox(height: 24),
        const _ActionButtons(),
        const SizedBox(height: 24),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: MediaQuery.of(context).size.width - 48,
            child: _TeachersTable(teachers: teachers),
          ),
        ),
        const SizedBox(height: 20),
        const _SaveButton(),
      ],
    );
  }
}

// ── Students Filters Row ─────────────────────────────────────────
class _StudentsFilterRow extends StatelessWidget {
  final String selectedClass;
  final String selectedSection;
  final DateTime selectedDate;
  final List<String> classList;
  final List<String> sectionList;
  final Function(String) onClassChanged;
  final Function(String) onSectionChanged;
  final VoidCallback onDateTap;

  const _StudentsFilterRow({
    required this.selectedClass,
    required this.selectedSection,
    required this.selectedDate,
    required this.classList,
    required this.sectionList,
    required this.onClassChanged,
    required this.onSectionChanged,
    required this.onDateTap,
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
          if (constraints.maxWidth < 600) {
            return Column(
              children: [
                _FilterDropdown(
                  label: 'Class / Grade',
                  value: selectedClass,
                  items: classList,
                  onChanged: onClassChanged,
                  icon: Icons.class_rounded,
                ),
                const SizedBox(height: 12),
                _FilterDropdown(
                  label: 'Section',
                  value: selectedSection,
                  items: sectionList,
                  onChanged: onSectionChanged,
                  icon: Icons.group_rounded,
                ),
                const SizedBox(height: 12),
                _DatePickerWidget(
                  date: selectedDate,
                  onTap: onDateTap,
                ),
              ],
            );
          } else {
            return Row(
              children: [
                Expanded(
                    child: _FilterDropdown(
                  label: 'Class / Grade',
                  value: selectedClass,
                  items: classList,
                  onChanged: onClassChanged,
                  icon: Icons.class_rounded,
                )),
                const SizedBox(width: 16),
                Expanded(
                    child: _FilterDropdown(
                  label: 'Section',
                  value: selectedSection,
                  items: sectionList,
                  onChanged: onSectionChanged,
                  icon: Icons.group_rounded,
                )),
                const SizedBox(width: 16),
                Expanded(
                    child: _DatePickerWidget(
                  date: selectedDate,
                  onTap: onDateTap,
                )),
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
  final VoidCallback onDateTap;

  const _TeachersFilterRow({
    required this.selectedDepartment,
    required this.selectedDate,
    required this.departmentList,
    required this.onDepartmentChanged,
    required this.onDateTap,
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
                _DatePickerWidget(
                  date: selectedDate,
                  onTap: onDateTap,
                ),
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
                    child: _DatePickerWidget(
                  date: selectedDate,
                  onTap: onDateTap,
                )),
              ],
            );
          }
        },
      ),
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

// ── Date Picker ─────────────────────────────────────────────
class _DatePickerWidget extends StatelessWidget {
  final DateTime date;
  final VoidCallback onTap;

  const _DatePickerWidget({required this.date, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Date',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          InkWell(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: AppColors.cardBorder.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today_rounded,
                      size: 18, color: AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Text(
                    '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
                    style: const TextStyle(
                        color: AppColors.textPrimary, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Attendance Statistics ─────────────────────────────────────────
class _AttendanceStats extends StatelessWidget {
  final int total;
  final int present;
  final int absent;
  final int late;

  const _AttendanceStats({
    required this.total,
    required this.present,
    required this.absent,
    required this.late,
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

// ── Action Buttons ─────────────────────────────────────────────────
class _ActionButtons extends StatelessWidget {
  const _ActionButtons();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _ActionButton(
            label: 'Bulk Attendance',
            icon: Icons.checklist_rounded,
            color: AppColors.cardGreen,
            onTap: () {},
          ),
          const SizedBox(width: 12),
          _ActionButton(
            label: 'Export Report',
            icon: Icons.download_rounded,
            color: AppColors.cardBlue,
            onTap: () {},
          ),
          const SizedBox(width: 12),
          _ActionButton(
            label: 'Send Absence Notice',
            icon: Icons.notifications_rounded,
            color: AppColors.warning,
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: app.AppGradients.cardGradient,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
          boxShadow: AppShadows.cardShadow,
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(fontSize: 12, color: color)),
          ],
        ),
      ),
    );
  }
}

// ── Students Table ─────────────────────────────────────────────
class _StudentsTable extends StatelessWidget {
  final List<Map<String, dynamic>> students;

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
class _StudentRow extends StatefulWidget {
  final Map<String, dynamic> student;

  const _StudentRow({required this.student});

  @override
  State<_StudentRow> createState() => _StudentRowState();
}

class _StudentRowState extends State<_StudentRow> {
  late String selectedStatus;

  @override
  void initState() {
    super.initState();
    selectedStatus = widget.student['status'];
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
                    widget.student['name'][0],
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.student['name'],
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
              selectedStatus == 'Present' ? widget.student['time'] : '-',
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
                    : AppColors.warning,
          ),
          items: const [
            DropdownMenuItem(value: 'Present', child: Text('Present')),
            DropdownMenuItem(value: 'Absent', child: Text('Absent')),
            DropdownMenuItem(value: 'Late', child: Text('Late')),
          ],
          onChanged: (value) => setState(() => selectedStatus = value!),
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
                    : AppColors.warning,
          ),
          items: const [
            DropdownMenuItem(value: 'Present', child: Text('Present')),
            DropdownMenuItem(value: 'Absent', child: Text('Absent')),
            DropdownMenuItem(value: 'Late', child: Text('Late')),
          ],
          onChanged: (value) => setState(() => selectedStatus = value!),
        ),
      ),
    );
  }
}

// ── Save Button ─────────────────────────────────────────────────
class _SaveButton extends StatelessWidget {
  const _SaveButton();

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
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Attendance data saved successfully'),
                backgroundColor: AppColors.cardGreen,
              ),
            );
          },
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
