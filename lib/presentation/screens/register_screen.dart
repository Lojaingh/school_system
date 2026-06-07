import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_management/constants/app_colors.dart';
import 'package:school_management/constants/app_colors.dart' as app;
import 'package:school_management/cubit/auth/register/staff_cubit.dart';
import 'package:school_management/presentation/screen/widgets/staff_form.dart';
import 'package:school_management/presentation/screen/widgets/student_form.dart';
import 'package:school_management/cubit/auth/register/register_cubit.dart';
import 'package:school_management/data/repository/register_repository.dart';
import 'package:school_management/data/services/register_service.dart';
import 'package:school_management/data/repository/staff_repository.dart';
import 'package:school_management/data/services/staff_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool isStaff = false;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => RegisterCubit(
            RegisterRepository(RegisterService()),
          ),
        ),
        BlocProvider(
          create: (_) => StaffCubit(
            StaffRepository(StaffService()),
          ),
        ),
      ],
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppGradients.backgroundGradient,
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text(
              "Create Account",
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              "Register as Student or Staff",
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 30),
            // TOGGLE
            Container(
              decoration: BoxDecoration(
                gradient: app.AppGradients.cardGradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: app.AppShadows.cardShadow,
              ),
              child: Row(
                children: [
                  _tab("Student", !isStaff, () {
                    setState(() => isStaff = false);
                  }),
                  _tab("Staff", isStaff, () {
                    setState(() => isStaff = true);
                  }),
                ],
              ),
            ),
            const SizedBox(height: 30),
            // FORM
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: app.AppGradients.cardGradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: app.AppShadows.cardShadow,
                ),
                child: isStaff ? const StaffForm() : const StudentForm(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tab(String title, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: active ? app.AppGradients.primaryGradient : null,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: active ? Colors.white : AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
