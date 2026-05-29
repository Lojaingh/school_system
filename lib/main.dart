import 'package:flutter/material.dart';
import 'package:school_management/presentation/screen/attendance_page.dart';
import 'package:school_management/presentation/screen/library_page.dart';
import 'package:school_management/presentation/screen/widgets/sidebar.dart';
import 'package:school_management/presentation/screen/widgets/topbar.dart';
import 'package:school_management/presentation/screens/main_layout.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
        debugShowCheckedModeBanner: false,
         home: MainLayout());
  }
}
