import 'package:flutter/material.dart';
import 'package:school_management/presentation/screen/widgets/sidebar.dart';
import 'package:school_management/presentation/screen/widgets/topbar.dart';
import 'package:sidebarx/sidebarx.dart';

import '../../constants/app_colors.dart' as app;

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  final SidebarXController controller =
      SidebarXController(selectedIndex: 0, extended: true);

  final List<Widget> pages = const [
    Center(child: Text("الرئيسية")),
    Center(child: Text("الطلاب")),
    Center(child: Text("الأساتذة")),
    Center(child: Text("الصفوف")),
    Center(child: Text("الحضور")),
    Center(child: Text("المكتبة")),
    Center(child: Text("التقارير")),
    Center(child: Text("الإعدادات")),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: app.AppGradients.backgroundGradient,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 250,
              child: Sidebar(controller: controller),
            ),
            Expanded(
              child: Column(
                children: [
                  const TopBar(),
                  Expanded(
                    child: AnimatedBuilder(
                      animation: controller,
                      builder: (context, _) {
                        return pages[controller.selectedIndex];
                      },
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
}
