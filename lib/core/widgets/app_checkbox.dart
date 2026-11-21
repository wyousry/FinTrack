import 'package:fintrack/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class AppCheckbox extends StatelessWidget {
  const AppCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.size = 20,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final double size;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: value ? AppColors.primary : AppColors.surfaceTint,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: value
                ? AppColors.primary
                : AppColors.glowBlue.withValues(alpha: 0.7),
            width: 1.5,
          ),
        ),
        child: value
            ? Icon(Icons.check, size: size * 0.65, color: Colors.white)
            : null,
      ),
    );
  }
}