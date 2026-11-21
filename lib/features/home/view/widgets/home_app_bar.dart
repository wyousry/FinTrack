import 'dart:ui' show ImageFilter;
import 'package:fintrack/core/constants/app_colors.dart';
import 'package:fintrack/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

class HomeAppBar extends StatelessWidget {
  const HomeAppBar({super.key, this.onNotificationsTap, this.onAvatarTap});

  static const double height = 64;

  final VoidCallback? onNotificationsTap;
  final VoidCallback? onAvatarTap;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          color: const Color(0xCCFAF8FF),
          padding: EdgeInsets.only(top: MediaQuery.paddingOf(context).top),
          child: SizedBox(
            height: height,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Icon(
                    Icons.account_balance_wallet_outlined,
                    size: 22,
                    color: AppColors.positive,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Home',
                    style: AppTextStyles.heading.copyWith(letterSpacing: -0.45),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: onNotificationsTap,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints.tightFor(width: 44, height: 44),
                    icon: const Icon(
                      Icons.notifications_none_rounded,
                      size: 22,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Material(
                    color: AppColors.positive,
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: onAvatarTap,
                      child: const SizedBox(
                        width: 32,
                        height: 32,
                        child: Icon(Icons.person_rounded, size: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}