// lib/core/widgets/coming_soon_screen.dart

import 'package:fintrack/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class ComingSoonScreen extends StatelessWidget {
  const ComingSoonScreen({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Text(
          '$title - Coming Soon',
          style: const TextStyle(fontSize: 15, color: AppColors.textSecondary),
        ),
      ),
    );
  }
}