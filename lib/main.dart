import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_management/presentation/screen/dashboard_page.dart';
import 'package:school_management/presentation/screen/widgets/library_content.dart';
import 'package:school_management/presentation/screens/register_screen.dart';
import 'cubit/auth/login/login_cubit.dart';
import 'data/network/dio_client.dart';
import 'data/repository/auth_repository.dart';
import 'data/services/auth_service.dart';
import 'presentation/screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DioClient.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LoginCubit(
        AuthRepository(
          AuthService(DioClient.dio),
        ),
      ),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'School Management',
        theme: ThemeData(useMaterial3: true),
        home: const LoginScreen(),
      ),
    );
  }
}
