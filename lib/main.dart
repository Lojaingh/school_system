import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_management/cubit/auth/register/staff_cubit.dart';
import 'package:school_management/cubit/staff/staff_profile_cubit.dart';
import 'package:school_management/cubit/student/student_cubit.dart';
import 'package:school_management/cubit/student_profile/student_profile_cubit.dart';
import 'package:school_management/data/repository/staff_profile_repository.dart';
import 'package:school_management/data/repository/staff_repository.dart';
import 'package:school_management/data/repository/student_profile_repository.dart';
import 'package:school_management/data/repository/student_repository.dart';
import 'package:school_management/data/services/staff_profile_service.dart';
import 'package:school_management/data/services/staff_service.dart';
import 'package:school_management/data/services/student_profile_service.dart';
import 'package:school_management/data/services/student_service.dart';

import 'cubit/auth/login/login_cubit.dart';
import 'cubit/auth/subject/subject_cubit.dart';

import 'data/network/dio_client.dart';

import 'data/repository/auth_repository.dart';
import 'data/repository/subject_repository.dart';

import 'data/services/auth_service.dart';
import 'data/services/subject_service.dart';

import 'presentation/screens/login_screen.dart';

void main() {
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
        theme: ThemeData(useMaterial3: true),
        home: const LoginScreen(),
      ),
    );
  }
}
