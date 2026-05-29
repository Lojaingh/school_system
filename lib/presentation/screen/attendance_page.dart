// lib/presentation/screen/attendance_page.dart

import 'package:flutter/material.dart';
import '../screens/main_layout.dart';

class AttendancePage extends StatelessWidget {
  const AttendancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const MainLayout(initialIndex: 4);
  }
}
