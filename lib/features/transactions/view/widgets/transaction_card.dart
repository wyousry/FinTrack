import 'package:fintrack/core/constants/app_colors.dart';
import 'package:fintrack/core/theme/app_text_styles.dart';
import 'package:fintrack/core/utils/formatters.dart';
import 'package:fintrack/core/widgets/app_card.dart';
import 'package:fintrack/features/transactions/model/transaction_model.dart';
import 'package:fintrack/features/transactions/view/category_style.dart';
import 'package:flutter/material.dart';

class TransactionCard extends StatelessWidget {
  const TransactionCard({super.key, required this.transaction, this.onTap});

  final TransactionModel transaction;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = transaction;
    final style = CategoryStyle.of(t.categoryId);
    final subtitle =
        '${t.isExpense ? t.categoryName : 'Income'} • ${Formatters.transactionDate(t.date)}';

    return AppCard(
      padding: const EdgeInsets.all(16),
      radius: 12,
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: t.isIncome ? AppColors.mintStrong : AppColors.blueTintSoft,
              shape: BoxShape.circle,
            ),
            child: Icon(
              style.icon,
              size: 20,
              color: t.isIncome ? AppColors.positive : AppColors.slate,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.body,
                ),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 130),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                Formatters.signedCurrency(t.signedAmount),
                style: AppTextStyles.title.copyWith(
                  color: t.isIncome ? AppColors.positive : AppColors.negative,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}