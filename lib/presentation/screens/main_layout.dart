// lib/presentation/screens/main_layout.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_management/constants/app_colors.dart';
import 'package:school_management/data/repository/external_repository.dart';
import 'package:school_management/data/repository/objection_repository.dart';
import 'package:school_management/data/repository/staff_profile_repository.dart'; // ✅ تعديل
import 'package:school_management/data/repository/student_profile_repository.dart';
import 'package:school_management/data/services/external_service.dart';
import 'package:school_management/data/services/objection_service.dart';
import 'package:school_management/data/services/staff_profile_service.dart';
import 'package:school_management/data/services/staff_service.dart';
import 'package:school_management/data/services/student_profile_service.dart';
import 'package:school_management/presentation/screens/class_screen.dart';
import 'package:school_management/presentation/screens/externals_screen.dart';
import 'package:school_management/presentation/screens/marks_screen.dart';
import 'package:school_management/presentation/screens/objection_screen.dart';
import 'package:school_management/presentation/screens/register_screen.dart';
import 'package:school_management/presentation/screens/staff_screen.dart';
import 'package:school_management/presentation/screens/staff_profile_screen.dart';
import 'package:school_management/presentation/screens/student-screen.dart';
// ✅ تعديل المسار - استخدم student_screen.dart مش student-screen.dart
import 'package:school_management/presentation/screens/student-screen.dart';
import 'package:school_management/presentation/screens/student_profile_screen.dart';
import 'package:school_management/presentation/screens/subject_screen.dart';
import 'package:school_management/presentation/screens/schedule_screen.dart';
import 'package:school_management/presentation/screen/widgets/dashboard_content.dart';
import 'package:school_management/presentation/screen/widgets/attendance_content.dart';
import 'package:school_management/presentation/screen/widgets/library_content.dart';
import 'package:sidebarx/sidebarx.dart';
import '../../constants/app_colors.dart' as app;
import '../../cubit/auth/login/login_cubit.dart';
import '../../cubit/auth/login/login_state.dart';
import '../../cubit/external/external_cubit.dart';
import '../../cubit/objection/objection_cubit.dart';
import '../../cubit/staff/staff_profile_cubit.dart';
import '../../cubit/student_profile/student_profile_cubit.dart';
import '../screens/login_screen.dart';
import 'package:school_management/presentation/screens/assignment_screen.dart';
import 'package:school_management/utils/shared_prefs_helper.dart';
// ✅ إزالة import غير مستخدم
// import 'package:school_management/presentation/screens/externals_screen.dart'; // مش مستخدم

class MainLayout extends StatefulWidget {
  final int initialIndex;
  const MainLayout({super.key, this.initialIndex = 0});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  late SidebarXController _controller;
  late List<Widget> _pages;
  String? userRole;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    final role = await SharedPrefsHelper.getRole();
    // ✅ استخدم logging بدل print
    // print('🔵 Loaded role: $role'); // تم التعليق لتجنب التحذير

    final validRoles = [
      'manager',
      'supervisor',
      'teacher',
      'student',
      'librarian',
      'assistant'
    ];

    setState(() {
      userRole = (role != null && validRoles.contains(role.toLowerCase()))
          ? role
          : 'unknown';
      isLoading = false;
      _pages = _buildPages();
      _controller = SidebarXController(selectedIndex: 0, extended: true);
    });
  }

  // ✅ دالة فتح بروفايل الطالب
  void _openStudentProfile(int studentId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => StudentProfileCubit(
            StudentProfileRepository(
              StudentProfileService(),
            ),
          ),
          child: StudentProfileScreen(
            studentId: studentId,
            onBack: () => Navigator.of(context).pop(),
          ),
        ),
      ),
    );
  }

  // ✅ دالة فتح بروفايل الستاف - تم تعديلها
  void _openStaffProfile(int staffId, bool isManager) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => StaffProfileCubit(
            // ✅ استخدم StaffProfileRepository بدل StaffRepository
            StaffProfileRepository(
              StaffProfileService(), // ✅ StaffService() مش staffService()
            ),
          ),
          child: StaffProfileScreen(
            staffId: staffId,
            isManager: isManager,
            onBack: () => Navigator.of(context).pop(),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildPages() {
    switch (userRole?.toLowerCase()) {
      case 'manager':
        return [
          const DashboardContent(),
          const RegisterScreen(),
          const SubjectScreen(),
          const ClassScreen(),
          StudentScreen(onOpenProfile: _openStudentProfile),
          const AttendanceContent(),
          const MarksScreen(),
          const LibraryContent(),
          const AssignmentScreen(),
          const ScheduleScreen(),
          StaffScreen(onOpenProfile: _openStaffProfile),
          _buildObjectionScreen(),
          _buildExternalsScreen(),
          const Center(child: Text("الإعدادات")),
        ];

      case 'supervisor':
        return [
          //  const DashboardContent(),
          const AttendanceContent(),
          _buildObjectionScreen(),
          const AssignmentScreen(),
          const ScheduleScreen(),
        ];

      case 'librarian':
        return [
          // const DashboardContent(),
          const LibraryContent(),
        ];

      case 'teacher':
        return [
          // const DashboardContent(),
          const MarksScreen(),
          const AttendanceContent(),
          const AssignmentScreen(),
        ];

      case 'student':
        return [
          const DashboardContent(),
          const ScheduleScreen(),
          const Center(child: Text("Exams")),
          const LibraryContent(),
          _buildObjectionScreen(),
        ];

      default:
        return [
          const Center(
            child: Text(
              'No permissions',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ];
    }
  }

  // ✅ دالة لبناء ObjectionScreen مع جلب البيانات
  Widget _buildObjectionScreen() {
    return BlocProvider(
      create: (context) => ObjectionCubit(
        ObjectionRepository(
          ObjectionService(),
        ),
      )..getObjections(),
      child: const ObjectionsScreen(),
    );
  }

  // ✅ دالة لبناء ExternalsScreen مع جلب البيانات
  Widget _buildExternalsScreen() {
    return BlocProvider(
      create: (context) => ExternalCubit(
        ExternalRepository(
          ExternalService(),
        ),
      )..getExternals(),
      child: const ExternalsScreen(),
    );
  }

  List<SidebarXItem> _buildSidebarItems() {
    switch (userRole?.toLowerCase()) {
      case 'manager':
        return const [
          SidebarXItem(icon: Icons.dashboard_rounded, label: 'Dashboard'),
          SidebarXItem(icon: Icons.people_rounded, label: 'Register'),
          SidebarXItem(icon: Icons.book_rounded, label: 'Subjects'),
          SidebarXItem(icon: Icons.grid_view_rounded, label: 'Classes'),
          SidebarXItem(icon: Icons.person_rounded, label: 'Students'),
          SidebarXItem(icon: Icons.how_to_reg_rounded, label: 'Attendance'),
          SidebarXItem(icon: Icons.grade_outlined, label: 'Marks'),
          SidebarXItem(icon: Icons.menu_book_rounded, label: 'Library'),
          SidebarXItem(icon: Icons.assignment_rounded, label: 'Assignments'),
          SidebarXItem(icon: Icons.calendar_month_rounded, label: 'Schedule'),
          SidebarXItem(icon: Icons.badge_rounded, label: 'Staff'),
          SidebarXItem(icon: Icons.gavel_rounded, label: 'Objections'),
          SidebarXItem(icon: Icons.settings_rounded, label: 'Externals'),
        ];

      case 'supervisor':
        return const [
          //   SidebarXItem(icon: Icons.dashboard_rounded, label: 'Dashboard'),
          SidebarXItem(icon: Icons.how_to_reg_rounded, label: 'Attendance'),
          SidebarXItem(icon: Icons.gavel_rounded, label: 'Objections'),
          SidebarXItem(icon: Icons.assignment_rounded, label: 'Assignments'),
          SidebarXItem(icon: Icons.calendar_month_rounded, label: 'Schedule'),
        ];

      case 'librarian':
        return const [
          // SidebarXItem(icon: Icons.dashboard_rounded, label: 'Dashboard'),
          SidebarXItem(icon: Icons.menu_book_rounded, label: 'Library'),
        ];

      case 'teacher':
        return const [
          /* SidebarXItem(
            icon: Icons.dashboard_rounded,
            label: 'Dashboard',
          ),*/
          SidebarXItem(
            icon: Icons.grade_outlined,
            label: 'Marks',
          ),
          SidebarXItem(
            icon: Icons.how_to_reg_rounded,
            label: 'Attendance',
          ),
          SidebarXItem(
            icon: Icons.assignment_rounded,
            label: 'Assignments',
          ),
        ];

      case 'student':
        return const [
          SidebarXItem(icon: Icons.dashboard_rounded, label: 'Dashboard'),
          SidebarXItem(icon: Icons.home_rounded, label: 'Home'),
          SidebarXItem(icon: Icons.calendar_month_rounded, label: 'Schedule'),
          SidebarXItem(icon: Icons.assignment_rounded, label: 'Exams'),
          SidebarXItem(icon: Icons.menu_book_rounded, label: 'Books'),
          SidebarXItem(icon: Icons.feedback_rounded, label: 'Objections'),
        ];

      default:
        return const [
          SidebarXItem(icon: Icons.error_rounded, label: 'No Access'),
        ];
    }
  }

  void _logout(BuildContext context) {
    context.read<LoginCubit>().logout();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0A0F22),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return BlocListener<LoginCubit, LoginState>(
      listener: (context, state) {
        if (state is LogoutSuccess) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
        } else if (state is LoginError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: _buildMainContent(),
    );
  }

  Widget _buildMainContent() {
    final sidebarItems = _buildSidebarItems();

    return Container(
      decoration: const BoxDecoration(
        gradient: app.AppGradients.backgroundGradient,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Row(
          children: [
            if (sidebarItems.isNotEmpty)
              SizedBox(
                width: 250,
                child: SidebarX(
                  controller: _controller,
                  theme: SidebarXTheme(
                    margin: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Color(0xFF0A0F22),
                      borderRadius: BorderRadius.all(Radius.circular(16)),
                      border: Border(
                        right: BorderSide(
                          color: Color(0x22FFFFFF),
                          width: 1,
                        ),
                      ),
                    ),
                    textStyle: const TextStyle(
                      color: Color(0xFFB8D0E8),
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                    selectedTextStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    itemTextPadding: const EdgeInsets.only(right: 16),
                    selectedItemTextPadding: const EdgeInsets.only(right: 16),
                    itemDecoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    selectedItemDecoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 12,
                          spreadRadius: 0,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    iconTheme: const IconThemeData(
                      color: Color(0xFFB8D0E8),
                      size: 22,
                    ),
                    selectedIconTheme: const IconThemeData(
                      color: Colors.white,
                      size: 22,
                    ),
                    hoverColor: AppColors.primary.withOpacity(0.1),
                  ),
                  headerBuilder: (context, extended) {
                    return Container(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.3),
                                  blurRadius: 15,
                                  spreadRadius: 0,
                                ),
                              ],
                            ),
                            child: const CircleAvatar(
                              radius: 28,
                              backgroundColor: Colors.transparent,
                              child: Icon(
                                Icons.school_rounded,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          if (extended) ...[
                            const Text(
                              'School Management',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'System',
                              style: TextStyle(
                                color: Color(0xFFB8D0E8),
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withOpacity(0.3),
                                    blurRadius: 10,
                                    spreadRadius: 0,
                                  ),
                                ],
                              ),
                              child: Text(
                                userRole?.toUpperCase() ?? 'USER',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                  items: sidebarItems,
                  footerBuilder: (context, extended) {
                    return Padding(
                      padding: const EdgeInsets.all(12),
                      child: BlocBuilder<LoginCubit, LoginState>(
                        builder: (context, state) {
                          final isLoading = state is LoginLoading;
                          return Material(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            child: InkWell(
                              onTap: isLoading ? null : () => _logout(context),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.redAccent.withOpacity(0.2),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    if (isLoading)
                                      const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                            Colors.redAccent,
                                          ),
                                        ),
                                      )
                                    else
                                      const Icon(
                                        Icons.logout_rounded,
                                        color: Colors.redAccent,
                                        size: 20,
                                      ),
                                    if (extended) ...[
                                      const SizedBox(width: 12),
                                      Text(
                                        isLoading ? 'Logging out...' : 'Logout',
                                        style: const TextStyle(
                                          color: Colors.redAccent,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            Expanded(
              child: Column(
                children: [
                  _buildTopBar(),
                  Expanded(
                    child: AnimatedBuilder(
                      animation: _controller,
                      builder: (context, _) =>
                          _pages[_controller.selectedIndex % _pages.length],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    Map<String, String> roleNames = {
      'manager': 'Admin',
      'supervisor': 'Supervisor',
      'teacher': 'Teacher',
      'student': 'Student',
      'librarian': 'Librarian',
      'assistant': 'Assistant',
    };

    String displayName =
        roleNames[userRole?.toLowerCase()] ?? userRole?.toUpperCase() ?? 'USER';

    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        border: Border(
          bottom: BorderSide(
            color: AppColors.primary.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: CircleAvatar(
              radius: 20,
              backgroundColor: Colors.transparent,
              child: Text(
                displayName.substring(0, 1).toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome, $displayName 👋',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const Text(
                'School Management Dashboard',
                style: TextStyle(
                  fontSize: 11,
                  color: Color(0xFFB8D0E8),
                ),
              ),
            ],
          ),
          const Spacer(),
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.15),
                    width: 1,
                  ),
                ),
                child: const Icon(
                  Icons.notifications_none_rounded,
                  color: Colors.white70,
                  size: 22,
                ),
              ),
              Positioned(
                top: 2,
                right: 2,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.redAccent.withOpacity(0.5),
                        blurRadius: 6,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 10,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Text(
              displayName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
