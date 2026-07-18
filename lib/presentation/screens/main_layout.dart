import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_management/constants/app_colors.dart';
import 'package:school_management/presentation/screens/register_screen.dart';
import 'package:school_management/presentation/screens/staff_screen.dart';
import 'package:school_management/presentation/screens/staff_profile_screen.dart';
import 'package:school_management/presentation/screens/student-screen.dart';
import 'package:school_management/presentation/screens/student_profile_screen.dart';
import 'package:school_management/presentation/screens/subject_screen.dart';

import 'package:sidebarx/sidebarx.dart';
import '../screen/widgets/dashboard_content.dart';
import '../screen/widgets/attendance_content.dart';
import '../screen/widgets/library_content.dart';
import '../../constants/app_colors.dart' as app;
import '../../cubit/auth/login/login_cubit.dart';
import '../../cubit/auth/login/login_state.dart';
import '../screens/login_screen.dart';
import 'package:school_management/presentation/screens/assignment_screen.dart';

class MainLayout extends StatefulWidget {
  final int initialIndex;
  const MainLayout({super.key, this.initialIndex = 0});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  late SidebarXController _controller;

  late List<Widget> _pages;
  @override
  void initState() {
    super.initState();

    _controller = SidebarXController(
      selectedIndex: widget.initialIndex,
      extended: true,
    );

    _pages = [
      const DashboardContent(),
      const RegisterScreen(),
      const SubjectScreen(),
      StudentScreen(
        onOpenProfile: (id) {
          setState(() {
            _pages[3] = StudentProfileScreen(
              studentId: id,
              onBack: () {
                setState(() {
                  _pages[3] = StudentScreen(
                    onOpenProfile: (id) {
                      setState(() {
                        _pages[3] = StudentProfileScreen(
                          studentId: id,
                          onBack: () {
                            setState(() {
                              _pages[3] = StudentScreen(
                                onOpenProfile: (id) {},
                              );
                            });
                          },
                        );
                      });
                    },
                  );
                });
              },
            );
          });
        },
      ),
      const AttendanceContent(),
      const LibraryContent(),
      StaffScreen(
        onOpenProfile: (id, isManager) {
          setState(() {
            _pages[6] = StaffProfileScreen(
              staffId: id,
              isManager: isManager,
              onBack: () {
                setState(() {
                  _pages[6] = StaffScreen(
                    onOpenProfile: (id, isManager) {
                      setState(() {
                        _pages[6] = StaffProfileScreen(
                          staffId: id,
                          isManager: isManager,
                          onBack: () {
                            setState(() {
                              _pages[6] = StaffScreen(
                                onOpenProfile: (id, isManager) {},
                              );
                            });
                          },
                        );
                      });
                    },
                  );
                });
              },
            );
          });
        },
      ),
      const Center(child: Text("الإعدادات")),
    ];
  }

  void _logout(BuildContext context) {
    context.read<LoginCubit>().logout();
  }

  @override
  Widget build(BuildContext context) {
    // ✅ الحصول على LoginCubit من الأعلى (أو إنشاء واحد إذا لم يوجد)
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
    return Container(
      decoration: const BoxDecoration(
        gradient: app.AppGradients.backgroundGradient,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Row(
          children: [
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
                  // ✅ نفس لون زر Login بالضبط: #1E88E5 (ثابت بدون تدرج)
                  selectedItemDecoration: BoxDecoration(
                    color: AppColors.primary, // #1E88E5
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
                            color: AppColors.primary, // #1E88E5
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
                              color: AppColors.primary, // #1E88E5
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.3),
                                  blurRadius: 10,
                                  spreadRadius: 0,
                                ),
                              ],
                            ),
                            child: const Text(
                              'Admin',
                              style: TextStyle(
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
                items: const [
                  SidebarXItem(
                    icon: Icons.dashboard_rounded,
                    label: 'Dashboard',
                  ),
                  SidebarXItem(
                    icon: Icons.people_rounded,
                    label: 'Register',
                  ),
                  SidebarXItem(
                    icon: Icons.school_rounded,
                    label: 'Teachers',
                  ),
                  SidebarXItem(
                    icon: Icons.grid_view_rounded,
                    label: 'Classes',
                  ),
                  SidebarXItem(
                    icon: Icons.how_to_reg_rounded,
                    label: 'Attendance',
                  ),
                  SidebarXItem(
                    icon: Icons.menu_book_rounded,
                    label: 'Library',
                  ),
                  SidebarXItem(
                    icon: Icons.assignment_rounded,
                    label: 'Assignments',
                  ),
                  SidebarXItem(
                    icon: Icons.bar_chart_rounded,
                    label: 'Reports',
                  ),
                  SidebarXItem(
                    icon: Icons.settings_rounded,
                    label: 'Settings',
                  ),
                ],
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
                          _pages[_controller.selectedIndex],
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
              color: AppColors.primary, // #1E88E5
              borderRadius: BorderRadius.circular(20),
            ),
            child: const CircleAvatar(
              radius: 20,
              backgroundColor: Colors.transparent,
              child: Text(
                'A',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome, Admin 👋',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              Text(
                'School Management Dashboard',
                style: TextStyle(
                  fontSize: 11,
                  color: Color(0xFFB8D0E8),
                ),
              ),
            ],
          ),
          const Spacer(),
          Container(
            width: 200,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.15),
                width: 1,
              ),
            ),
            child: const TextField(
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
              ),
              decoration: InputDecoration(
                hintText: 'Search...',
                hintStyle: TextStyle(
                  color: Color(0xFF8A9CB0),
                  fontSize: 13,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  size: 18,
                  color: Color(0xFF8A9CB0),
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  vertical: 10,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
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
              color: AppColors.primary, // #1E88E5
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 10,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: const Text(
              'Admin',
              style: TextStyle(
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
