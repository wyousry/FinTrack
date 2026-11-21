import 'package:fintrack/core/constants/app_colors.dart';
import 'package:flutter/material.dart';


abstract final class AppTextStyles {
  static const TextStyle title = TextStyle(
    fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: -0.2,
    height: 26 / 20, color: AppColors.textPrimary,
  );

 
  static const TextStyle heading = TextStyle(
    fontSize: 18, fontWeight: FontWeight.w600, letterSpacing: -0.18,
    height: 24 / 18, color: AppColors.textPrimary,
  );


  static const TextStyle body = TextStyle(
    fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.14,
    height: 20 / 14, color: AppColors.textPrimary,
  );

  static const TextStyle label = TextStyle(
    fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 0.24,
    height: 16 / 12, color: AppColors.textSecondary,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 0.33,
    height: 14 / 11, color: AppColors.textSecondary,
  );
}