import 'package:flutter/material.dart';
import 'package:school_management/constants/app_colors.dart';
import 'package:school_management/constants/app_colors.dart' as app;
import 'package:school_management/data/model/class_students_model.dart';
import 'package:school_management/data/network/dio_client.dart';
import 'package:school_management/data/services/attendance_service.dart';
import 'package:school_management/utils/shared_prefs_helper.dart';

class AttendanceContent extends StatefulWidget {
  final int? initialClassId;

  const AttendanceContent({
    super.key,
    this.initialClassId,
  });

  @override
  State<AttendanceContent> createState() => _AttendanceContentState();
}

class _AttendanceContentState extends State<AttendanceContent> {
  int selectedTab = 0;
  final DateTime selectedDate = DateTime.now();
  List<Map<String, dynamic>> classList = [];
  int? selectedClassId;
  bool isLoadingClasses = true;
  List<ClassStudent> students = [];
  int? currentClassId;

  String? userRole;
  bool isLoadingRole = true;

  List<Map<String, dynamic>> staffList = [];
  String selectedRole = 'All';
  List<String> roleList = ['All'];

  final AttendanceService _attendanceService = AttendanceService();

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    final role = await SharedPrefsHelper.getRole();

    if (!mounted) return;

    setState(() {
      userRole = role;
      isLoadingRole = false;
    });

    await _loadClasses();

    if (!mounted) return;

    if (_isManager) {
      await _loadStaff();
    }
  }

  bool get _isManager => userRole?.trim().toLowerCase() == 'manager';

  Future<void> _loadStaff() async {
    try {
      print('🔵 Loading staff from API...');

      final response = await _attendanceService.getStaff();

      print('📥 Staff API status: ${response.statusCode}');
      print('📥 Staff API data: ${response.data}');

      if (response.statusCode != 200) {
        print(
          '❌ Failed to load staff: ${response.statusCode}',
        );
        return;
      }

      final dynamic responseData = response.data;

      final List data = responseData is List
          ? responseData
          : responseData is Map
              ? (responseData['data'] is List
                  ? responseData['data'] as List
                  : responseData['data'] is Map &&
                          responseData['data']['data'] is List
                      ? responseData['data']['data'] as List
                      : [])
              : [];

      if (data.isEmpty) {
        print('⚠️ No staff found in the system');

        if (!mounted) return;

        setState(() {
          staffList = [];
          roleList = ['All'];
        });

        return;
      }

      final Set<String> rolesSet = {'All'};
      final List<Map<String, dynamic>> loadedStaff = [];

      for (final item in data) {
        if (item is! Map) continue;

        final profile = item['profile'] is Map
            ? Map<String, dynamic>.from(item['profile'])
            : <String, dynamic>{};

        final roles =
            item['roles'] is List ? item['roles'] as List : <dynamic>[];

        final roleTitle = roles.isNotEmpty && roles.first is Map
            ? (roles.first['title']?.toString() ?? 'Staff')
            : 'Staff';

        rolesSet.add(roleTitle);

        var firstName = profile['f_name']?.toString() ??
            profile['first_name']?.toString() ??
            profile['first name']?.toString() ??
            '';

        var lastName = profile['l_name']?.toString() ??
            profile['last_name']?.toString() ??
            profile['last name']?.toString() ??
            '';

        final name = '$firstName $lastName'.trim();

        loadedStaff.add({
          'id': item['user_id'] ?? 0,
          'name': name.isEmpty
              ? item['username']?.toString() ?? 'Unknown Staff'
              : name,
          'role': roleTitle,
          'status': 'Present',
          'time': '-',
        });
      }

      if (!mounted) return;

      setState(() {
        staffList = loadedStaff;
        roleList = rolesSet.toList();

        if (!roleList.contains(selectedRole)) {
          selectedRole = 'All';
        }
      });

      print('✅ Staff loaded: ${loadedStaff.length}');
      print('📋 Roles: $roleList');
    } catch (e) {
      print('❌ Error loading staff: $e');
    }
  }

  Future<void> _loadClasses() async {
    if (mounted) {
      setState(() {
        isLoadingClasses = true;
      });
    }

    try {
      final role = await SharedPrefsHelper.getRole();
      final isSupervisor = role?.trim().toLowerCase() == 'supervisor';

      if (isSupervisor) {
        final response = await DioClient.dio.get('/supervisor/classes');

        if (response.statusCode == 200) {
          final dynamic responseData = response.data;

          final List data = responseData is List
              ? responseData
              : responseData is Map
                  ? (responseData['data'] is List
                      ? responseData['data'] as List
                      : responseData['data'] is Map &&
                              responseData['data']['data'] is List
                          ? responseData['data']['data'] as List
                          : [])
                  : [];

          print(
            '📥 Supervisor classes response data: $data',
          );

          if (data.isNotEmpty) {
            final loadedClasses = data.map<Map<String, dynamic>>((item) {
              return {
                'id': item['id'],
                'display': item['name']?.toString() ?? 'Class ${item['id']}',
              };
            }).toList();

            if (!mounted) return;

            setState(() {
              classList = loadedClasses;
              selectedClassId =
                  widget.initialClassId ?? loadedClasses.first['id'] as int?;
              isLoadingClasses = false;
            });

            if (selectedClassId != null) {
              await _loadStudents(selectedClassId!);
            }

            return;
          }
        }

        if (!mounted) return;

        setState(() {
          isLoadingClasses = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No class assigned to you as supervisor',
            ),
            backgroundColor: AppColors.warning,
          ),
        );

        return;
      }

      final response = await DioClient.dio.get('/class/all');

      if (response.statusCode == 200) {
        final dynamic responseData = response.data;

        final List data = responseData is List
            ? responseData
            : responseData is Map
                ? (responseData['data'] is List
                    ? responseData['data'] as List
                    : responseData['data'] is Map &&
                            responseData['data']['data'] is List
                        ? responseData['data']['data'] as List
                        : [])
                : [];

        print(
          '📥 Class/all response data: $data',
        );

        final loadedClasses = data.map<Map<String, dynamic>>((item) {
          return {
            'id': item['id'],
            'year': item['year'],
            'number': item['number'],
            'display': 'Grade ${item['year']} - Section ${item['number']}',
          };
        }).toList();

        if (!mounted) return;

        setState(() {
          classList = loadedClasses;

          selectedClassId = widget.initialClassId ??
              (loadedClasses.isNotEmpty
                  ? loadedClasses.first['id'] as int?
                  : null);

          isLoadingClasses = false;
        });

        if (selectedClassId != null) {
          await _loadStudents(selectedClassId!);
        }
      } else {
        print(
          '❌ Failed to load classes: ${response.statusCode}',
        );

        if (!mounted) return;

        setState(() {
          isLoadingClasses = false;
        });
      }
    } catch (e) {
      print('❌ Error loading classes: $e');

      if (!mounted) return;

      setState(() {
        isLoadingClasses = false;
      });
    }
  }

  Future<void> _loadStudents(int classId) async {
    try {
      currentClassId = classId;

      print(
        '🔵 Loading students for class ID: $classId',
      );

      final response = await _attendanceService.getClassStudents(
        classId,
      );

      print(
        '📥 Students API status: ${response.statusCode}',
      );

      print(
        '📥 Students API data: ${response.data}',
      );

      if (response.statusCode == 200) {
        final data = ClassStudentsResponse.fromJson(
          response.data,
        );

        print(
          '👨‍🎓 Students count: ${data.students.length}',
        );

        if (!mounted) return;

        setState(() {
          students = data.students;
        });
      }
    } catch (e) {
      print(
        '❌ Error loading students: $e',
      );
    }
  }

  void _saveAttendance() async {
    if (currentClassId == null || students.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No students to save attendance for',
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final List<int> absent = [];
    final List<int> late = [];
    final List<int> excused = [];

    for (final student in students) {
      final status = student.status;
      final userId = student.userId;

      if (status == 'Absent') {
        absent.add(userId);
      } else if (status == 'Late') {
        late.add(userId);
      } else if (status == 'Excused') {
        excused.add(userId);
      }
    }

    try {
      final response = await _attendanceService.markAttendance(
        classId: currentClassId!,
        absent: absent,
        late: late,
        excused: excused,
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Attendance saved successfully!',
            ),
            backgroundColor: AppColors.cardGreen,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _saveStaffAttendance() async {
    if (staffList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No staff to save attendance for',
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final Map<int, String> statuses = {};

    for (final staff in staffList) {
      final status = staff['status'] as String;
      final id = staff['id'] as int;

      if (status != 'Present') {
        statuses[id] = status.toLowerCase();
      }
    }

    if (statuses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Everyone is marked Present — nothing to save',
          ),
          backgroundColor: AppColors.cardGreen,
        ),
      );
      return;
    }

    final formattedDate = '${selectedDate.year}-'
        '${selectedDate.month.toString().padLeft(2, '0')}-'
        '${selectedDate.day.toString().padLeft(2, '0')}';

    try {
      await _attendanceService.markStaffAttendanceBulk(
        statuses,
        date: formattedDate,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Staff attendance saved successfully!',
          ),
          backgroundColor: AppColors.cardGreen,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoadingRole) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(48),
          child: CircularProgressIndicator(),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Attendance',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _isManager
                ? 'Record and track attendance for students and staff'
                : 'Record and track attendance for your students',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          if (_isManager) ...[
            Container(
              decoration: BoxDecoration(
                color: AppColors.cardBg.withOpacity(.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildTabButton(
                      label: '👨‍🎓 Students',
                      index: 0,
                      selectedTab: selectedTab,
                      onTap: () {
                        if (!mounted) return;
                        setState(() {
                          selectedTab = 0;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: _buildTabButton(
                      label: '👩‍💼 Staff',
                      index: 1,
                      selectedTab: selectedTab,
                      onTap: () {
                        if (!mounted) return;
                        setState(() {
                          selectedTab = 1;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
          if (!_isManager || selectedTab == 0)
            _StudentsAttendanceContent(
              students: students,
              selectedDate: selectedDate,
              classList: classList,
              selectedClassId: selectedClassId,
              isLoadingClasses: isLoadingClasses,
              onClassChanged: (value) {
                if (!mounted) return;

                setState(() {
                  selectedClassId = value;
                });

                _loadStudents(value);
              },
              onSave: _saveAttendance,
            ),
          if (_isManager && selectedTab == 1)
            _StaffAttendanceContent(
              staffList: staffList,
              selectedRole: selectedRole,
              selectedDate: selectedDate,
              roleList: roleList,
              onRoleChanged: (value) {
                if (!mounted) return;

                setState(() {
                  selectedRole = value;
                });
              },
              onSave: _saveStaffAttendance,
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
        padding: const EdgeInsets.symmetric(
          vertical: 12,
        ),
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
          present: students
              .where(
                (s) => s.status == 'Present',
              )
              .length,
          absent: students
              .where(
                (s) => s.status == 'Absent',
              )
              .length,
          late: students
              .where(
                (s) => s.status == 'Late',
              )
              .length,
          excused: students
              .where(
                (s) => s.status == 'Excused',
              )
              .length,
        ),
        const SizedBox(height: 24),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: MediaQuery.of(context).size.width - 48,
            child: _StudentsTable(
              students: students,
            ),
          ),
        ),
        const SizedBox(height: 20),
        _SaveButton(
          onSave: onSave,
        ),
      ],
    );
  }
}

class _StaffAttendanceContent extends StatelessWidget {
  final List<Map<String, dynamic>> staffList;
  final String selectedRole;
  final DateTime selectedDate;
  final List<String> roleList;
  final Function(String) onRoleChanged;
  final VoidCallback onSave;

  const _StaffAttendanceContent({
    required this.staffList,
    required this.selectedRole,
    required this.selectedDate,
    required this.roleList,
    required this.onRoleChanged,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final filteredStaff = selectedRole == 'All'
        ? staffList
        : staffList
            .where(
              (s) => s['role'] == selectedRole,
            )
            .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _StaffFilterRow(
          selectedRole: selectedRole,
          selectedDate: selectedDate,
          roleList: roleList,
          onRoleChanged: onRoleChanged,
        ),
        const SizedBox(height: 24),
        _AttendanceStats(
          total: filteredStaff.length,
          present: filteredStaff
              .where(
                (t) => t['status'] == 'Present',
              )
              .length,
          absent: filteredStaff
              .where(
                (t) => t['status'] == 'Absent',
              )
              .length,
          late: filteredStaff
              .where(
                (t) => t['status'] == 'Late',
              )
              .length,
          excused: filteredStaff
              .where(
                (t) => t['status'] == 'Excused',
              )
              .length,
        ),
        const SizedBox(height: 24),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: MediaQuery.of(context).size.width - 48,
            child: _StaffTable(
              staffList: filteredStaff,
            ),
          ),
        ),
        const SizedBox(height: 20),
        _SaveButton(
          onSave: onSave,
        ),
      ],
    );
  }
}

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
                _TodayDateBadge(
                  date: selectedDate,
                ),
              ],
            );
          }

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
                child: _TodayDateBadge(
                  date: selectedDate,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StaffFilterRow extends StatelessWidget {
  final String selectedRole;
  final DateTime selectedDate;
  final List<String> roleList;
  final Function(String) onRoleChanged;

  const _StaffFilterRow({
    required this.selectedRole,
    required this.selectedDate,
    required this.roleList,
    required this.onRoleChanged,
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
                  label: 'Role',
                  value: selectedRole,
                  items: roleList,
                  onChanged: onRoleChanged,
                  icon: Icons.badge_rounded,
                ),
                const SizedBox(height: 12),
                _TodayDateBadge(
                  date: selectedDate,
                ),
              ],
            );
          }

          return Row(
            children: [
              Expanded(
                child: _FilterDropdown(
                  label: 'Role',
                  value: selectedRole,
                  items: roleList,
                  onChanged: onRoleChanged,
                  icon: Icons.badge_rounded,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _TodayDateBadge(
                  date: selectedDate,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

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
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.cardBorder.withOpacity(.3),
            ),
          ),
          child: isLoading
              ? const Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: 12,
                  ),
                  child: SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  ),
                )
              : DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: classList.any(
                      (item) => item['id'] == selectedClassId,
                    )
                        ? selectedClassId
                        : null,
                    isExpanded: true,
                    icon: const Icon(
                      Icons.class_rounded,
                      size: 18,
                      color: AppColors.textSecondary,
                    ),
                    dropdownColor: AppColors.cardBg,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                    ),
                    hint: const Text(
                      'Select class',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    items: classList
                        .map(
                          (item) => DropdownMenuItem<int>(
                            value: item['id'] as int,
                            child: Text(
                              item['display'].toString(),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        onChanged(value);
                      }
                    },
                  ),
                ),
        ),
      ],
    );
  }
}

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.cardBorder.withOpacity(.3),
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: items.contains(value) ? value : null,
              isExpanded: true,
              icon: Icon(
                icon,
                size: 18,
                color: AppColors.textSecondary,
              ),
              dropdownColor: AppColors.cardBg,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
              ),
              items: items
                  .map(
                    (item) => DropdownMenuItem<String>(
                      value: item,
                      child: Text(item),
                    ),
                  )
                  .toList(),
              onChanged: (newValue) {
                if (newValue != null) {
                  onChanged(newValue);
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _TodayDateBadge extends StatelessWidget {
  final DateTime date;

  const _TodayDateBadge({
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    final formatted = '${date.year}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Date',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(.03),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.cardBorder.withOpacity(.2),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.today_rounded,
                size: 18,
                color: AppColors.textSecondary.withOpacity(.7),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '$formatted (Today)',
                  style: TextStyle(
                    color: AppColors.textPrimary.withOpacity(.7),
                    fontSize: 14,
                  ),
                ),
              ),
              Icon(
                Icons.lock_outline_rounded,
                size: 14,
                color: AppColors.textSecondary.withOpacity(.5),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

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
          _StatChip(
            label: 'Total',
            value: '$total',
            color: AppColors.cardBlue,
          ),
          const SizedBox(width: 12),
          _StatChip(
            label: 'Present',
            value: '$present',
            color: AppColors.cardGreen,
          ),
          const SizedBox(width: 12),
          _StatChip(
            label: 'Absent',
            value: '$absent',
            color: AppColors.error,
          ),
          const SizedBox(width: 12),
          _StatChip(
            label: 'Late',
            value: '$late',
            color: AppColors.warning,
          ),
          const SizedBox(width: 12),
          _StatChip(
            label: 'Excused',
            value: '$excused',
            color: Colors.orange,
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 10,
      ),
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
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _StudentsTable extends StatelessWidget {
  final List<ClassStudent> students;

  const _StudentsTable({
    required this.students,
  });

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
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: AppColors.cardBorder.withOpacity(.3),
                ),
              ),
            ),
            child: const Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    'Student',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'Status',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'Time',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ...students.map(
            (student) => _StudentRow(
              student: student,
            ),
          ),
        ],
      ),
    );
  }
}

class _StudentRow extends StatefulWidget {
  final ClassStudent student;

  const _StudentRow({
    required this.student,
  });

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
          bottom: BorderSide(
            color: AppColors.cardBorder.withOpacity(.15),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.primary.withOpacity(.2),
                  child: Text(
                    widget.student.fullName.isNotEmpty
                        ? widget.student.fullName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.student.fullName,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: _buildStatusDropdown(),
          ),
          Expanded(
            flex: 1,
            child: Text(
              selectedStatus == 'Present'
                  ? '${DateTime.now().hour}:'
                      '${DateTime.now().minute.toString().padLeft(2, '0')}'
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
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.05),
        borderRadius: BorderRadius.circular(20),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedStatus,
          isExpanded: true,
          icon: const Icon(
            Icons.arrow_drop_down,
            size: 20,
          ),
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
            DropdownMenuItem(
              value: 'Present',
              child: Text('Present'),
            ),
            DropdownMenuItem(
              value: 'Absent',
              child: Text('Absent'),
            ),
            DropdownMenuItem(
              value: 'Late',
              child: Text('Late'),
            ),
            DropdownMenuItem(
              value: 'Excused',
              child: Text('Excused'),
            ),
          ],
          onChanged: (value) {
            if (value == null) return;

            if (!mounted) return;

            setState(() {
              selectedStatus = value;
              widget.student.status = value;
            });
          },
        ),
      ),
    );
  }
}

class _StaffTable extends StatelessWidget {
  final List<Map<String, dynamic>> staffList;

  const _StaffTable({
    required this.staffList,
  });

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
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: AppColors.cardBorder.withOpacity(.3),
                ),
              ),
            ),
            child: const Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    'Staff Member',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'Role',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'Status',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'Time',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ...staffList.map(
            (staff) => _StaffRow(
              staff: staff,
            ),
          ),
        ],
      ),
    );
  }
}

class _StaffRow extends StatefulWidget {
  final Map<String, dynamic> staff;

  const _StaffRow({
    required this.staff,
  });

  @override
  State<_StaffRow> createState() => _StaffRowState();
}

class _StaffRowState extends State<_StaffRow> {
  late String selectedStatus;

  @override
  void initState() {
    super.initState();

    selectedStatus = widget.staff['status']?.toString() ?? 'Present';
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.staff['name']?.toString() ?? 'Unknown Staff';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.cardBorder.withOpacity(.15),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.primary.withOpacity(.2),
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : '?',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    name,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              widget.staff['role']?.toString() ?? 'Staff',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 1,
            child: _buildStatusDropdown(),
          ),
          Expanded(
            flex: 1,
            child: Text(
              selectedStatus == 'Present'
                  ? widget.staff['time']?.toString() ?? '-'
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
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.05),
        borderRadius: BorderRadius.circular(20),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedStatus,
          isExpanded: true,
          icon: const Icon(
            Icons.arrow_drop_down,
            size: 20,
          ),
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
            DropdownMenuItem(
              value: 'Present',
              child: Text('Present'),
            ),
            DropdownMenuItem(
              value: 'Absent',
              child: Text('Absent'),
            ),
            DropdownMenuItem(
              value: 'Late',
              child: Text('Late'),
            ),
            DropdownMenuItem(
              value: 'Excused',
              child: Text('Excused'),
            ),
          ],
          onChanged: (value) {
            if (value == null) return;

            if (!mounted) return;

            setState(() {
              selectedStatus = value;
              widget.staff['status'] = value;
            });
          },
        ),
      ),
    );
  }
}

class _SaveButton extends StatelessWidget {
  final VoidCallback onSave;

  const _SaveButton({
    required this.onSave,
  });

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
              color: AppColors.primary.withOpacity(.4),
              blurRadius: 12,
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: onSave,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                12,
              ),
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.save_rounded,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Save Attendance',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
