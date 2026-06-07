import 'package:flutter/material.dart';
import 'package:school_management/presentation/screens/register_screen.dart';
import 'package:sidebarx/sidebarx.dart';
import '../screen/widgets/dashboard_content.dart';
import '../screen/widgets/attendance_content.dart';
import '../screen/widgets/library_content.dart';
import '../../constants/app_colors.dart' as app;

class MainLayout extends StatefulWidget {
  final int initialIndex;
  const MainLayout({super.key, this.initialIndex = 0});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  late SidebarXController _controller;

  late final List<Widget> _pages = [
    const DashboardContent(),
    const RegisterScreen(),
    const Center(child: Text("الأساتذة")),
    const Center(child: Text("الصفوف")),
    const AttendanceContent(),
    const LibraryContent(),
    const Center(child: Text("التقارير")),
    const Center(child: Text("الإعدادات")),
  ];

  @override
  void initState() {
    super.initState();
    _controller =
        SidebarXController(selectedIndex: widget.initialIndex, extended: true);
  }

  @override
  Widget build(BuildContext context) {
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
                    color: Color(0xFF1E2A38),
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                  ),
                  textStyle:
                      const TextStyle(color: Colors.white70, fontSize: 14),
                  selectedTextStyle: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w500),
                  itemTextPadding: const EdgeInsets.only(right: 16),
                  selectedItemTextPadding: const EdgeInsets.only(right: 16),
                  itemDecoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(10)),
                  selectedItemDecoration: BoxDecoration(
                    color: const Color(0xFF6C4CF1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  iconTheme:
                      const IconThemeData(color: Colors.white70, size: 22),
                  selectedIconTheme:
                      const IconThemeData(color: Colors.white, size: 22),
                ),
                headerBuilder: (context, extended) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const CircleAvatar(
                          radius: 28,
                          backgroundColor: Color(0xFF6C4CF1),
                          child: Icon(Icons.school_rounded,
                              color: Colors.white, size: 30),
                        ),
                        const SizedBox(height: 10),
                        if (extended) ...[
                          const Text('نظام إدارة المدرسة',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 14)),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFF6C4CF1).withOpacity(0.3),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text('مدير',
                                style: TextStyle(
                                    color: Colors.white70, fontSize: 12)),
                          ),
                        ],
                      ],
                    ),
                  );
                },
                items: const [
                  SidebarXItem(
                      icon: Icons.dashboard_rounded, label: 'الرئيسية'),
                  SidebarXItem(icon: Icons.people_rounded, label: 'التسجيل'),
                  SidebarXItem(icon: Icons.school_rounded, label: 'الأساتذة'),
                  SidebarXItem(icon: Icons.grid_view_rounded, label: 'الصفوف'),
                  SidebarXItem(icon: Icons.how_to_reg_rounded, label: 'الحضور'),
                  SidebarXItem(icon: Icons.menu_book_rounded, label: 'المكتبة'),
                  SidebarXItem(
                      icon: Icons.bar_chart_rounded, label: 'التقارير'),
                  SidebarXItem(
                      icon: Icons.settings_rounded, label: 'الإعدادات'),
                ],
                footerBuilder: (context, extended) {
                  return Padding(
                    padding: const EdgeInsets.all(12),
                    child: InkWell(
                      onTap: () {},
                      child: Row(
                        children: [
                          const Icon(Icons.logout_rounded,
                              color: Colors.redAccent),
                          if (extended) ...[
                            const SizedBox(width: 12),
                            const Text('تسجيل الخروج',
                                style: TextStyle(color: Colors.redAccent)),
                          ],
                        ],
                      ),
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
        color: Colors.white.withOpacity(0.05),
        border:
            Border(bottom: BorderSide(color: Colors.white.withOpacity(0.1))),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 20,
            backgroundColor: Color(0xFF6C4CF1),
            child:
                Text('أ', style: TextStyle(color: Colors.white, fontSize: 16)),
          ),
          const SizedBox(width: 12),
          const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('مرحباً، المدير 👋',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white)),
              Text('لوحة إدارة المدرسة',
                  style: TextStyle(fontSize: 11, color: Colors.white70)),
            ],
          ),
          const Spacer(),
          Container(
            width: 200,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const TextField(
              style: TextStyle(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                hintText: 'بحث...',
                hintStyle: TextStyle(color: Colors.white54, fontSize: 13),
                prefixIcon: Icon(Icons.search, size: 18, color: Colors.white54),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(Icons.notifications_none_rounded,
                  color: Colors.white70, size: 24),
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                        color: Colors.redAccent, shape: BoxShape.circle)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
