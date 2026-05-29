// lib/presentation/screen/library_page.dart

import 'package:flutter/material.dart';
import '../screens/main_layout.dart';

class LibraryPage extends StatelessWidget {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const MainLayout(initialIndex: 5);
  }
}
