import 'dart:ui' as ui;

import 'package:fintrack/core/constants/app_colors.dart';
import 'package:fintrack/core/theme/app_text_styles.dart';
import 'package:fintrack/core/utils/amount_input.dart';
import 'package:flutter/material.dart';

class EditAmountCard extends StatelessWidget {
  const EditAmountCard({
    super.key,
    required this.controller,
    required this.onChanged,
    this.errorText,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String? errorText;

  static const TextStyle _amountStyle = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.7,
    height: 36 / 28,
    color: AppColors.textPrimary,
  );

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Color(0x0D000000), blurRadius: 2, offset: Offset(0, 1)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            Positioned(
              right: -24,
              bottom: -24,
              child: ImageFiltered(
                imageFilter: ui.ImageFilter.blur(sigmaX: 1, sigmaY: 1),
                child: Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.lavender.withValues(alpha: 0.6),
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
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Transaction Total', style: AppTextStyles.label),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.lavender,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text('USD', style: AppTextStyles.caption),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(bottom: 4),
                          child: Text(
                            '\$',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.64,
                              height: 40 / 32,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
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
                                cursorColor: AppColors.positive,
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