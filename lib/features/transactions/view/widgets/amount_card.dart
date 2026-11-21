import 'dart:ui' as ui;

import 'package:fintrack/core/constants/app_colors.dart';
import 'package:fintrack/core/theme/app_text_styles.dart';
import 'package:fintrack/core/utils/amount_input.dart';
import 'package:fintrack/features/transactions/model/transaction_type.dart';
import 'package:flutter/material.dart';

class AmountCard extends StatelessWidget {
  const AmountCard({
    super.key,
    required this.type,
    required this.controller,
    required this.onChanged,
    required this.onQuickAdd,
    required this.onBackspace,
    this.errorText,
  });

  final TransactionType type;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final ValueChanged<double> onQuickAdd;
  final VoidCallback onBackspace;
  final String? errorText;

  static const List<double> _quickAmounts = [15, 25, 50];

  static const TextStyle _amountStyle = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.9,
    height: 44 / 36,
    color: AppColors.textPrimary,
  );

  @override
  Widget build(BuildContext context) {
    final isIncome = type == TransactionType.income;
    final accent = isIncome ? AppColors.positive : AppColors.negative;
    final glow = isIncome ? AppColors.mintStrong : AppColors.expenseTint;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Color(0x0D000000), blurRadius: 2, offset: Offset(0, 1)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Positioned(
              right: -24,
              bottom: -24,
              child: ImageFiltered(
                imageFilter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: glow.withValues(alpha: 0.4),
                  ),
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isIncome ? 'AMOUNT RECEIVED' : 'AMOUNT SPENT',
                      style: AppTextStyles.label.copyWith(letterSpacing: 0.6),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Text(
                            '\$',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.36,
                              height: 32 / 24,
                              color: accent,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(minWidth: 56),
                            child: IntrinsicWidth(
                              child: TextField(
                                controller: controller,
                                onChanged: onChanged,
                                textAlign: TextAlign.center,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                inputFormatters: [AmountInputFormatter()],
                                cursorColor: accent,
                                style: _amountStyle,
                                decoration: InputDecoration(
                                  isCollapsed: true,
                                  border: InputBorder.none,
                                  hintText: '0.00',
                                  hintStyle: _amountStyle.copyWith(
                                    color: AppColors.textSecondary.withValues(alpha: 0.35),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (errorText != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          errorText!,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.label.copyWith(color: AppColors.negative),
                        ),
                      ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (final amount in _quickAmounts) ...[
                          _Chip(
                            label: '+${amount.toInt()}',
                            onTap: () => onQuickAdd(amount),
                          ),
                          const SizedBox(width: 8),
                        ],
                        _Chip(icon: Icons.backspace_outlined, onTap: onBackspace),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({this.label, this.icon, required this.onTap});

  final String? label;
  final IconData? icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.lavender,
      shape: const StadiumBorder(),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: label != null
              ? Text(
                  label!,
                  style: AppTextStyles.label.copyWith(color: AppColors.textPrimary),
                )
              : Icon(icon, size: 16, color: AppColors.textPrimary),
        ),
      ),
    );
  }
}