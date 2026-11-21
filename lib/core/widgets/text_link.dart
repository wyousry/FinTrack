import 'package:fintrack/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class TextLink extends StatelessWidget {
  const TextLink(this.text, {super.key, this.onTap, this.fontSize = 11.5});

  final String text;
  final VoidCallback? onTap;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: Text(
          text,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryDark,
          ),
        ),
      ),
    );
  }
}