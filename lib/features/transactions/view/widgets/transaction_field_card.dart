import 'package:fintrack/core/constants/app_colors.dart';
import 'package:fintrack/core/theme/app_text_styles.dart';
import 'package:fintrack/core/widgets/app_card.dart';
import 'package:flutter/material.dart';

class TransactionFieldCard extends StatelessWidget {
  const TransactionFieldCard({
    super.key,
    required this.icon,
    required this.iconBackground,
    required this.iconColor,
    required this.label,
    required this.value,
    this.valueColor,
    this.trailing,
    this.onTap,
    this.errorText,
  });

  final IconData icon;
  final Color iconBackground;
  final Color iconColor;
  final String label;
  final String value;
  final Color? valueColor;
  final Widget? trailing;
  final VoidCallback? onTap;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      radius: 16,
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.caption),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.body.copyWith(
                    color: valueColor ?? AppColors.textPrimary,
                  ),
                ),
                if (errorText != null)
                  Text(
                    errorText!,
                    style: AppTextStyles.caption.copyWith(color: AppColors.negative),
                  ),
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 8),
            trailing!,
          ],
        ],
      ),
    );
  }
}