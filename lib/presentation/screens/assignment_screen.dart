import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:school_management/cubit/assignment/assignment_cubit.dart';
import '../screen/widgets/assignment_content.dart';

class AssignmentScreen extends StatelessWidget {
  const AssignmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AssignmentCubit(),
      child: const Scaffold(
        body: AssignmentContent(),
      ),
    );
  }
}
