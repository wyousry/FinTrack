
import 'dart:ui' show ImageFilter;

import 'package:fintrack/core/constants/app_colors.dart';
import 'package:fintrack/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

class AppHeaderBar extends StatelessWidget {
  const AppHeaderBar({
    super.key,
    required this.title,
    required this.onBack,
    this.trailing,
  });

  static const double height = 64;

  final String title;
  final VoidCallback onBack;
  final Widget? trailing;

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
                  Transform.translate(
                    offset: const Offset(-8, 0),
                    child: IconButton(
                      onPressed: onBack,
                      tooltip: 'Back',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints.tightFor(width: 44, height: 44),
                      icon: const Icon(
                        Icons.arrow_back_rounded,
                        size: 20,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.heading,
                    ),
                  ),
                  if (trailing != null) trailing!,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}