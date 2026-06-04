/*import 'package:flutter/material.dart';
import 'package:sidebarx/sidebarx.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_colors.dart' as app;
<<<<<<< Updated upstream
=======
import '../attendance_page.dart';
import '../library_page.dart';
import '../dashboard_page.dart'; // 👈 أضيفي هذا الـ import
>>>>>>> Stashed changes

class Sidebar extends StatefulWidget {
  final SidebarXController controller;

  const Sidebar({
    super.key,
    required this.controller,
  });

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  @override
<<<<<<< Updated upstream
=======
  void initState() {
    super.initState();
    widget.controller.addListener(() {
      final index = widget.controller.selectedIndex;

      if (index == 0) {
        // ✅ العودة إلى الصفحة الرئيسية (Dashboard)
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DashboardPage()),
        );
      } else if (index == 4) {
        // الحضور
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AttendancePage()),
        );
      } else if (index == 5) {
        // المكتبة
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LibraryPage()),
        );
      }
    });
  }

  @override
>>>>>>> Stashed changes
  Widget build(BuildContext context) {
    return SidebarX(
      controller: widget.controller,
      theme: SidebarXTheme(
        margin: const EdgeInsets.all(8),
        decoration: const BoxDecoration(
          gradient: app.AppGradients.sidebarGradient,
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
<<<<<<< Updated upstream
        headerBuilder: (context, extended) {
          return Container(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Column(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: app.AppGradients.glowGradient,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
=======
        textStyle: const TextStyle(
          color: AppColors.sidebarText,
          fontSize: 14,
        ),
        selectedTextStyle: const TextStyle(
          color: AppColors.sidebarTextSel,
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
        itemTextPadding: const EdgeInsets.only(left: 16),
        selectedItemTextPadding: const EdgeInsets.only(left: 16),
        itemDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
        ),
        selectedItemDecoration: BoxDecoration(
          color: AppColors.sidebarSelected,
          borderRadius: BorderRadius.circular(10),
        ),
        iconTheme: const IconThemeData(
          color: AppColors.sidebarText,
          size: 22,
        ),
        selectedIconTheme: const IconThemeData(
          color: Colors.white,
          size: 22,
        ),
      ),
      headerBuilder: (context, extended) {
        return Container(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Column(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: app.AppGradients.glowGradient,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.4),
                      blurRadius: 12,
                      spreadRadius: 0,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.school_rounded,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(height: 12),
              if (extended) ...[
                const Text(
                  'نظام إدارة المدرسة',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'للإدارة والتعليم',
                  style: TextStyle(
                    color: AppColors.sidebarText,
                    fontSize: 12,
                  ),
                ),
              ],
              const SizedBox(height: 20),
              Divider(
                color: Colors.white.withOpacity(0.1),
                thickness: 1,
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
      footerBuilder: (context, extended) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
          child: Column(
            children: [
              Divider(
                color: Colors.white.withOpacity(0.1),
                thickness: 1,
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () {
                  Navigator.pushReplacementNamed(context, '/login');
                },
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.logout_rounded,
                        color: Colors.redAccent,
                        size: 20,
>>>>>>> Stashed changes
                      ),
                      if (extended) ...[
                        const SizedBox(width: 12),
                        const Text(
                          'تسجيل الخروج',
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
<<<<<<< Updated upstream
                const SizedBox(height: 12),
                if (extended) ...[
                  const Text(
                    'نظام إدارة المدرسة',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'للإدارة والتعليم',
                    style: TextStyle(
                      color: AppColors.sidebarText,
                      fontSize: 12,
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                Divider(
                  color: Colors.white.withOpacity(0.1),
                  thickness: 1,
                ),
                const SizedBox(height: 8),
              ],
            ),
          );
        },
        footerBuilder: (context, extended) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
            child: Column(
              children: [
                Divider(
                  color: Colors.white.withOpacity(0.1),
                  thickness: 1,
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () {
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    height: 44,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.logout_rounded,
                          color: Colors.redAccent,
                          size: 20,
                        ),
                        if (extended) ...[
                          const SizedBox(width: 12),
                          const Text(
                            'تسجيل الخروج',
                            style: TextStyle(
                              color: Colors.redAccent,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        items: const [
          SidebarXItem(
            icon: Icons.dashboard_rounded,
            label: 'الرئيسية',
=======
              ),
            ],
>>>>>>> Stashed changes
          ),
        );
      },
      items: const [
        SidebarXItem(
          icon: Icons.dashboard_rounded,
          label: 'الرئيسية',
        ),
        SidebarXItem(
          icon: Icons.people_rounded,
          label: 'الطلاب',
        ),
        SidebarXItem(
          icon: Icons.school_rounded,
          label: 'الأساتذة',
        ),
        SidebarXItem(
          icon: Icons.grid_view_rounded,
          label: 'الصفوف',
        ),
        SidebarXItem(
          icon: Icons.how_to_reg_rounded,
          label: 'الحضور',
        ),
        SidebarXItem(
          icon: Icons.menu_book_rounded,
          label: 'المكتبة',
        ),
        SidebarXItem(
          icon: Icons.bar_chart_rounded,
          label: 'التقارير',
        ),
        SidebarXItem(
          icon: Icons.settings_rounded,
          label: 'الإعدادات',
        ),
      ],
    );
  }
}
*/