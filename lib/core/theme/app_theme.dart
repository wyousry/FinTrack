import 'package:fintrack/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

abstract final class AppTheme {
  static const String fontFamily = 'PlusJakartaSans';

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      fontFamily: fontFamily,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
    );
  }
}