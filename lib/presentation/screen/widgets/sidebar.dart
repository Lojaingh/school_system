import 'package:flutter/material.dart';
import 'package:sidebarx/sidebarx.dart';
import '../../../constants/app_colors.dart';
import '../attendance_page.dart';
import '../library_page.dart';

class Sidebar extends StatelessWidget {
  final SidebarXController controller;

  const Sidebar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SidebarX(
      controller: controller,
      theme: SidebarXTheme(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.sidebarBg,
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: const TextStyle(
          color: Colors.white70,
          fontSize: 14,
        ),
        selectedTextStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
        itemDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
        ),
        selectedItemDecoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        iconTheme: const IconThemeData(
          color: Colors.white70,
          size: 22,
        ),
        selectedIconTheme: const IconThemeData(
          color: Colors.white,
          size: 22,
        ),
      ),
      headerBuilder: (context, extended) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const CircleAvatar(
                radius: 32,
                backgroundColor: AppColors.primary,
                child: Text(
                  'أ',
                  style: TextStyle(fontSize: 24, color: Colors.white),
                ),
              ),
              const SizedBox(height: 10),
              if (extended) ...[
                const Text(
                  'أحمد محمد',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'مدير',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ),
              ],
            ],
          ),
        );
      },
      items: [
        const SidebarXItem(
          icon: Icons.dashboard_rounded,
          label: 'الرئيسية',
        ),
        const SidebarXItem(
          icon: Icons.people_rounded,
          label: 'الطلاب',
        ),
        const SidebarXItem(
          icon: Icons.school_rounded,
          label: 'الأساتذة',
        ),
        const SidebarXItem(
          icon: Icons.grid_view_rounded,
          label: 'الصفوف',
        ),
        SidebarXItem(
          icon: Icons.how_to_reg_rounded,
          label: 'الحضور',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AttendancePage()),
            );
          },
        ),
        SidebarXItem(
          icon: Icons.menu_book_rounded,
          label: 'المكتبة',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LibraryPage()),
            );
          },
        ),
        const SidebarXItem(
          icon: Icons.settings_rounded,
          label: 'الإعدادات',
        ),
      ],
      footerBuilder: (context, extended) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: InkWell(
            onTap: () {},
            child: Row(
              children: [
                const Icon(Icons.logout_rounded, color: Colors.redAccent),
                const SizedBox(width: 8),
                const Text(
                  'تسجيل الخروج',
                  style: TextStyle(color: Colors.redAccent),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
