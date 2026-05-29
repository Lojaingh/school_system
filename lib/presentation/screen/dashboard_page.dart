// lib/presentation/screen/dashboard_page.dart

import 'package:flutter/material.dart';
import '../screens/main_layout.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const MainLayout(initialIndex: 0);
  }
}
