import 'package:fintrack/core/constants/app_colors.dart';
import 'package:fintrack/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

class QuickActions extends StatelessWidget {
  const QuickActions({
    super.key,
    this.onIncome,
    this.onExpense,
    this.onTransfer,
    this.onMore,
  });

  final VoidCallback? onIncome;
  final VoidCallback? onExpense;
  final VoidCallback? onTransfer;
  final VoidCallback? onMore;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _QuickAction(
            label: 'Income',
            icon: Icons.add_rounded,
            iconSize: 24,
            background: AppColors.mintStrong,
            foreground: AppColors.positive,
            onTap: onIncome,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _QuickAction(
            label: 'Expense',
            icon: Icons.remove_rounded,
            iconSize: 24,
            background: AppColors.expenseTint,
            foreground: AppColors.negative,
            onTap: onExpense,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _QuickAction(
            label: 'Transfer',
            icon: Icons.swap_horiz_rounded,
            iconSize: 24,
            background: AppColors.blueTint,
            foreground: AppColors.slate,
            onTap: onTransfer,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _QuickAction(
            label: 'More',
            icon: Icons.grid_view_rounded,
            iconSize: 22,
            background: AppColors.lavender,
            foreground: AppColors.textSecondary,
            onTap: onMore,
          ),
        ),
      ],
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.label,
    required this.icon,
    required this.iconSize,
    required this.background,
    required this.foreground,
    this.onTap,
  });

  final String label;
  final IconData icon;
  final double iconSize;
  final Color background;
  final Color foreground;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          color: background,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: SizedBox(
              width: 56,
              height: 56,
              child: Icon(icon, size: iconSize, color: foreground),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: AppTextStyles.label.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}