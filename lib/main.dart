import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'cubit/auth/login/login_cubit.dart';
import 'data/network/dio_client.dart';
import 'data/repository/auth_repository.dart';
import 'data/services/auth_service.dart';
import 'presentation/screens/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'School Management',
      theme: ThemeData(useMaterial3: true),
      home: BlocProvider(
        create: (_) => LoginCubit(
          AuthRepository(
            AuthService(DioClient.dio),
          ),
        ),
        child: const LoginScreen(),
      ),
    );
  }
}
