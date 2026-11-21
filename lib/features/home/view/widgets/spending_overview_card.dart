import 'package:fintrack/core/constants/app_colors.dart';
import 'package:fintrack/core/theme/app_text_styles.dart';
import 'package:fintrack/core/utils/formatters.dart';
import 'package:fintrack/core/widgets/app_card.dart';
import 'package:fintrack/core/widgets/donut_chart.dart';
import 'package:fintrack/features/home/model/dashboard_summary.dart';
import 'package:fintrack/features/transactions/view/category_style.dart';
import 'package:flutter/material.dart';

class SpendingOverviewCard extends StatelessWidget {
  const SpendingOverviewCard({
    super.key,
    required this.month,
    required this.monthOptions,
    required this.onMonthSelected,
    required this.totalSpent,
    required this.categories,
  });

  final DateTime month;
  final List<DateTime> monthOptions;
  final ValueChanged<DateTime> onMonthSelected;
  final double totalSpent;
  final List<CategorySpending> categories;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text('Spending Overview', style: AppTextStyles.heading),
            ),
            PopupMenuButton<DateTime>(
              initialValue: month,
              onSelected: onMonthSelected,
              position: PopupMenuPosition.under,
              color: AppColors.surface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              itemBuilder: (context) => [
                for (final option in monthOptions)
                  PopupMenuItem(
                    value: option,
                    child: Text(Formatters.monthYear(option)),
                  ),
              ],
              child: _MonthPill(label: Formatters.monthYear(month)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        AppCard(
          padding: const EdgeInsets.all(24),
          child: categories.isEmpty
              ? const SizedBox(
                  height: 144,
                  child: Center(
                    child: Text(
                      'No spending in this month',
                      style: AppTextStyles.label,
                    ),
                  ),
                )
              : Row(
                  children: [
                    SizedBox(
                      width: 144,
                      height: 144,
                      child: Center(
                        child: DonutChart(
                          size: 127,
                          strokeWidth: 17,
                          segments: [
                            for (final c in categories)
                              DonutSegment(
                                value: c.amount,
                                color: CategoryStyle.of(c.categoryId).color,
                              ),
                          ],
                          center: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('Total Spent', style: AppTextStyles.caption),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  Formatters.currencyShort(totalSpent),
                                  style: AppTextStyles.heading.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          for (var i = 0; i < categories.length; i++) ...[
                            if (i > 0) const SizedBox(height: 8),
                            _LegendRow(category: categories[i]),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}

class _MonthPill extends StatelessWidget {
  const _MonthPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    const textColor = Color(0xFF3C4A42);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.lavender,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: AppTextStyles.label.copyWith(color: textColor)),
          const SizedBox(width: 4),
          const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: textColor),
        ],
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({required this.category});

  final CategorySpending category;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: CategoryStyle.of(category.categoryId).color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            category.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.caption.copyWith(color: AppColors.textPrimary),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '${category.percent.round()}%',
          style: AppTextStyles.label.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}