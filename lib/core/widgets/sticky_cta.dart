
import 'package:fintrack/core/constants/app_colors.dart';
import 'package:fintrack/core/widgets/primary_button.dart';
import 'package:flutter/material.dart';

class StickyCta extends StatelessWidget {
  const StickyCta({
    super.key,
    required this.label,
    required this.onPressed,
    this.trailingIcon,
    this.height = 52,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? trailingIcon;
  final double height;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          stops: const [0, 0.5, 1],
          colors: [
            AppColors.background,
            AppColors.background.withValues(alpha: 0.95),
            AppColors.background.withValues(alpha: 0),
          ],
        ),
      ),
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.only(bottom: 16),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(color: Color(0x1A000000), blurRadius: 6, spreadRadius: -1, offset: Offset(0, 4)),
                BoxShadow(color: Color(0x1A000000), blurRadius: 4, spreadRadius: -2, offset: Offset(0, 2)),
              ],
            ),
            child: PrimaryButton(
              label: label,
              trailingIcon: trailingIcon,
              height: height,
              isLoading: isLoading,
              onPressed: onPressed,
            ),
          ),
        ),
      ),
    );
  }
}