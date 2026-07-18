// lib/presentation/screen/dashboard_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../screens/main_layout.dart';
import '../../cubit/dashboard/dashboard_cubit.dart';
import '../../data/network/dio_client.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DashboardCubit()..loadStats(),
      child: const MainLayout(initialIndex: 0),
    );
  }
}
