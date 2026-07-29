import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_management/cubit/assignment/assignment_cubit.dart';
import 'package:school_management/cubit/attendance/attendance_cubit.dart';
import 'package:school_management/cubit/auth/subject/subject_cubit.dart';
import 'package:school_management/cubit/class/class_cubit.dart';
import 'package:school_management/cubit/dashboard/dashboard_cubit.dart';
import 'package:school_management/data/repository/assignment_repository.dart';
import 'package:school_management/data/repository/subject_repository.dart';
import 'package:school_management/data/services/attendance_service.dart';
import 'package:school_management/data/services/class_service.dart';
import 'package:school_management/data/services/subject_service.dart';
import 'package:school_management/presentation/screen/dashboard_page.dart';
import 'package:school_management/presentation/screen/widgets/library_content.dart';
import 'package:school_management/presentation/screens/register_screen.dart';
import 'cubit/auth/login/login_cubit.dart';
import 'data/network/dio_client.dart';
import 'data/repository/auth_repository.dart';
import 'data/services/auth_service.dart';
import 'presentation/screens/login_screen.dart';
import 'package:school_management/data/repository/class_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DioClient.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final dio = DioClient.dio;
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
          create: (_) => AssignmentCubit(
            AssignmentRepository(),
          ),
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
          create: (_) => ClassCubit(
            ClassRepository(
              ClassService(), // ✅ ClassService يستخدم DioClient.dio داخلياً
            ),
          )..loadClasses(),
        ),
        BlocProvider(
          create: (_) => AttendanceCubit(
            AttendanceService(),
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
