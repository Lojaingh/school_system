import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:school_management/cubit/assignment/assignment_cubit.dart';
import 'package:school_management/cubit/auth/login/login_cubit.dart';
import 'package:school_management/cubit/auth/subject/subject_cubit.dart';
import 'package:school_management/cubit/dashboard/dashboard_cubit.dart';
import 'package:school_management/cubit/staff/staff_profile_cubit.dart';
import 'package:school_management/cubit/student/student_cubit.dart';
import 'package:school_management/cubit/student_profile/student_profile_cubit.dart';

import 'package:school_management/data/network/dio_client.dart';

import 'package:school_management/data/repository/auth_repository.dart';
import 'package:school_management/data/repository/subject_repository.dart';
import 'package:school_management/data/repository/student_repository.dart';
import 'package:school_management/data/repository/student_profile_repository.dart';
import 'package:school_management/data/repository/staff_profile_repository.dart';

import 'package:school_management/data/services/auth_service.dart';
import 'package:school_management/data/services/subject_service.dart';
import 'package:school_management/data/services/student_service.dart';
import 'package:school_management/data/services/student_profile_service.dart';
import 'package:school_management/data/services/staff_profile_service.dart';

import 'package:school_management/presentation/screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await DioClient.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => LoginCubit(
            AuthRepository(
              AuthService(DioClient.dio),
            ),
          ),
        ),
        BlocProvider(
          create: (_) => AssignmentCubit()..getAssignments(),
        ),
        BlocProvider(
          create: (_) => DashboardCubit()..loadStats(),
        ),
        BlocProvider(
          create: (_) => SubjectCubit(
            SubjectRepository(
              SubjectService(),
            ),
          ),
        ),
        BlocProvider(
          create: (_) => StudentCubit(
            StudentRepository(
              StudentService(),
            ),
          ),
        ),
        BlocProvider(
          create: (_) => StudentProfileCubit(
            StudentProfileRepository(
              StudentProfileService(),
            ),
          ),
        ),
        BlocProvider(
          create: (_) => StaffProfileCubit(
            StaffProfileRepository(
              StaffProfileService(),
            ),
          ),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'School Management',
        theme: ThemeData(
          useMaterial3: true,
        ),
        home: const LoginScreen(),
      ),
    );
  }
}
