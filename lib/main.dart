import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:school_management/utils/shared_prefs_helper.dart';

// --- Cubits ---

import 'package:school_management/cubit/assignment/assignment_cubit.dart';
import 'package:school_management/cubit/auth/login/login_cubit.dart';
import 'package:school_management/cubit/auth/subject/subject_cubit.dart';
import 'package:school_management/cubit/dashboard/dashboard_cubit.dart';
import 'package:school_management/cubit/external/external_cubit.dart';
import 'package:school_management/cubit/library/book_cubit.dart';
import 'package:school_management/cubit/marks/marks_cubit.dart';
import 'package:school_management/cubit/objection/objection_cubit.dart';
import 'package:school_management/cubit/staff/staff_profile_cubit.dart';
import 'package:school_management/cubit/student/student_cubit.dart';
import 'package:school_management/cubit/student_profile/student_profile_cubit.dart';
import 'package:school_management/cubit/attendance/attendance_cubit.dart';
import 'package:school_management/cubit/class/class_cubit.dart';

// --- Repositories ---

import 'package:school_management/data/repository/auth_repository.dart';
import 'package:school_management/data/repository/book_repository.dart';
import 'package:school_management/data/repository/external_repository.dart';
import 'package:school_management/data/repository/marks_repository.dart';
import 'package:school_management/data/repository/objection_repository.dart';
import 'package:school_management/data/repository/subject_repository.dart';
import 'package:school_management/data/repository/student_repository.dart';
import 'package:school_management/data/repository/student_profile_repository.dart';
import 'package:school_management/data/repository/staff_profile_repository.dart';
import 'package:school_management/data/repository/assignment_repository.dart';
import 'package:school_management/data/repository/class_repository.dart';

// --- Services ---

import 'package:school_management/data/services/auth_service.dart';
import 'package:school_management/data/services/book_service.dart';
import 'package:school_management/data/services/external_service.dart';
import 'package:school_management/data/services/marks_service.dart';
import 'package:school_management/data/services/objection_service.dart';
import 'package:school_management/data/services/subject_service.dart';
import 'package:school_management/data/services/student_service.dart';
import 'package:school_management/data/services/student_profile_service.dart';
import 'package:school_management/data/services/staff_profile_service.dart';
import 'package:school_management/data/services/attendance_service.dart';
import 'package:school_management/data/services/class_service.dart';

// --- Network ---

import 'package:school_management/data/network/dio_client.dart';

// --- Screens ---

import 'package:school_management/presentation/screens/login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final savedLanguage = await SharedPrefsHelper.getLanguage();

  await DioClient.init();

  runApp(
    MyApp(
      initialLocale:
          savedLanguage == 'ar' ? const Locale('ar') : const Locale('en'),
    ),
  );
}

class MyApp extends StatelessWidget {
  final Locale initialLocale;

  const MyApp({
    super.key,
    required this.initialLocale,
  });

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
        BlocProvider(
          create: (_) => ClassCubit(
            ClassRepository(
              ClassService(),
            ),
          )..loadClasses(),
        ),
        BlocProvider(
          create: (_) => AttendanceCubit(
            AttendanceService(),
          ),
        ),
        BlocProvider(
          create: (_) => BookCubit(
            BookRepository(
              BookService(),
            ),
          )..loadBooks(),
        ),
        BlocProvider(
          create: (_) => ExternalCubit(
            ExternalRepository(
              ExternalService(),
            ),
          ),
        ),
        BlocProvider(
          create: (_) => ObjectionCubit(
            ObjectionRepository(
              ObjectionService(),
            ),
          ),
        ),
        BlocProvider(
          create: (_) => MarksCubit(
            MarksRepository(
              MarksService(),
            ),
            role: '',
          ),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'School Management',
        locale: initialLocale,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en'),
          Locale('ar'),
        ],
        theme: ThemeData(
          useMaterial3: true,
        ),
        home: const LoginScreen(),
      ),
    );
  }
}
