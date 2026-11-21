import 'dart:ui' as ui;

import 'package:fintrack/core/constants/app_colors.dart';
import 'package:fintrack/core/theme/app_text_styles.dart';
import 'package:fintrack/core/utils/formatters.dart';
import 'package:flutter/material.dart';

class BalanceCard extends StatelessWidget {
  const BalanceCard({
    super.key,
    required this.balance,
    required this.income,
    required this.expenses,
    required this.hidden,
    required this.onToggleHidden,
    this.changePercent,
  });

  final double balance;
  final double income;
  final double expenses;
  final bool hidden;
  final VoidCallback onToggleHidden;
  final double? changePercent;

  static const String _mask = '••••••';

  @override
  Widget build(BuildContext context) {
    final change = changePercent;
    final white80 = Colors.white.withValues(alpha: 0.8);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Color(0x1A000000), blurRadius: 15, spreadRadius: -3, offset: Offset(0, 10)),
          BoxShadow(color: Color(0x1A000000), blurRadius: 6, spreadRadius: -4, offset: Offset(0, 4)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(-0.5, -1),
              end: Alignment(0.5, 1),
              colors: [AppColors.positive, AppColors.primary],
            ),
          ),
          child: Stack(
            children: [
              const Positioned(right: -32, top: -32, child: _BlurredCircle(size: 144, sigma: 12)),
              const Positioned(left: -24, bottom: -24, child: _BlurredCircle(size: 128, sigma: 8)),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'TOTAL BALANCE',
                          style: AppTextStyles.label.copyWith(color: white80, letterSpacing: 0.6),
                        ),
                        const Spacer(),
                        _HidePill(hidden: hidden, onTap: onToggleHidden),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              hidden ? _mask : Formatters.currency(balance),
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.7,
                                height: 36 / 28,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        if (change != null) ...[
                          const SizedBox(width: 12),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 1),
                            child: _ChangeBadge(percent: change),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 24),
                    _FlowSummary(
                      income: hidden ? _mask : '+${Formatters.currency(income)}',
                      expenses: hidden ? _mask : '-${Formatters.currency(expenses)}',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BlurredCircle extends StatelessWidget {
  const _BlurredCircle({required this.size, required this.sigma});

  final double size;
  final double sigma;

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ui.ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.1),
        ),
      ),
    );
  }
}

class _HidePill extends StatelessWidget {
  const _HidePill({required this.hidden, required this.onTap});

  final bool hidden;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              hidden ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              size: 14,
              color: Colors.white,
            ),
            const SizedBox(width: 4),
            Text(
              hidden ? 'Show' : 'Hide',
              style: AppTextStyles.caption.copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChangeBadge extends StatelessWidget {
  const _ChangeBadge({required this.percent});

  final double percent;

  @override
  Widget build(BuildContext context) {
    final sign = percent >= 0 ? '+' : '';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$sign${percent.toStringAsFixed(1)}%',
        style: AppTextStyles.label.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}

class _FlowSummary extends StatelessWidget {
  const _FlowSummary({required this.income, required this.expenses});

  final String income;
  final String expenses;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _Flow(
              label: 'Income',
              amount: income,
              icon: Icons.arrow_downward_rounded,
              alignEnd: false,
            ),
          ),
          Container(
            width: 1,
            height: 28,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            color: Colors.white.withValues(alpha: 0.25),
          ),
          Expanded(
            child: _Flow(
              label: 'Expenses',
              amount: expenses,
              icon: Icons.arrow_upward_rounded,
              alignEnd: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _Flow extends StatelessWidget {
  const _Flow({
    required this.label,
    required this.amount,
    required this.icon,
    required this.alignEnd,
  });

  final String label;
  final String amount;
  final IconData icon;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    final iconCircle = Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.25),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 12, color: Colors.white),
    );

    final texts = Flexible(
      child: Column(
        crossAxisAlignment: alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: Colors.white.withValues(alpha: 0.8),
              height: 1,
            ),
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              amount,
              style: AppTextStyles.body.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );

    return Row(
      mainAxisAlignment: alignEnd ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: alignEnd
          ? [texts, const SizedBox(width: 8), iconCircle]
          : [iconCircle, const SizedBox(width: 8), texts],
    );
  }
}