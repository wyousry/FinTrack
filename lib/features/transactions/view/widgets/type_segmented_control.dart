
import 'package:fintrack/core/constants/app_colors.dart';
import 'package:fintrack/core/theme/app_text_styles.dart';
import 'package:fintrack/features/transactions/model/transaction_type.dart';
import 'package:flutter/material.dart';

enum SegmentedVariant { filled, soft }

class TypeSegmentedControl extends StatelessWidget {
  const TypeSegmentedControl({
    super.key,
    required this.type,
    required this.onChanged,
    this.variant = SegmentedVariant.filled,
  });

  final TransactionType type;
  final ValueChanged<TransactionType> onChanged;
  final SegmentedVariant variant;

  static const List<TransactionType> _order = [
    TransactionType.expense,
    TransactionType.income,
  ];

  @override
  Widget build(BuildContext context) {
    final filled = variant == SegmentedVariant.filled;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: filled ? AppColors.avatarBg : AppColors.lavender,
        borderRadius: BorderRadius.circular(40),
        boxShadow: filled
            ? const [BoxShadow(color: Color(0x0D000000), blurRadius: 1, offset: Offset(0, 1))]
            : null,
      ),
      child: Row(
        children: [
          for (final t in _order)
            Expanded(
              child: _Segment(
                type: t,
                selected: t == type,
                filled: filled,
                onTap: () => onChanged(t),
              ),
            ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.type,
    required this.selected,
    required this.filled,
    required this.onTap,
  });

  final TransactionType type;
  final bool selected;
  final bool filled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isExpense = type == TransactionType.expense;
    final typeColor = isExpense ? AppColors.negative : AppColors.positive;

    final Color background;
    final Color foreground;
    final Color iconColor;
    final FontWeight weight;

    if (filled) {
      background = selected ? typeColor : Colors.transparent;
      foreground = selected ? Colors.white : AppColors.textSecondary;
      iconColor = foreground;
      weight = FontWeight.w600;
    } else {
      background = selected ? AppColors.surface : Colors.transparent;
      foreground = selected ? AppColors.textPrimary : AppColors.textSecondary;
      iconColor = typeColor;
      weight = selected ? FontWeight.w700 : FontWeight.w500;
    }

    final icon = filled
        ? (isExpense ? Icons.trending_down_rounded : Icons.trending_up_rounded)
        : (isExpense ? Icons.north_east_rounded : Icons.south_rounded);

    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(40),
            boxShadow: (!filled && selected)
                ? const [BoxShadow(color: Color(0x0D000000), blurRadius: 1, offset: Offset(0, 1))]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: filled ? 16 : 12, color: iconColor),
              const SizedBox(width: 8),
              Text(
                isExpense ? 'Expense' : 'Income',
                style: AppTextStyles.body.copyWith(color: foreground, fontWeight: weight),
              ),
            ],
          ),
        ),
      ),
    );
  }
}