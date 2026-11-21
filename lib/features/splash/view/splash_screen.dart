
import 'package:fintrack/core/routing/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../viewmodel/splash_cubit.dart';
import '../viewmodel/splash_state.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SplashCubit()..checkAppState(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: BlocConsumer<SplashCubit, SplashState>(
 listener: (context, state) {
  if (state.destination == null) return;
  switch (state.destination!) {
    case SplashDestination.onboarding:
      context.go(AppRoutes.onboarding);
      break;
    case SplashDestination.login:
      context.go(AppRoutes.login);
      break;
    case SplashDestination.home:
      context.go(AppRoutes.home);
      break;
  }
},
  builder: (context, state) {
    return SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 40),
          _buildTopBadge(),
          const Spacer(),
          _buildLogoCluster(),
          const SizedBox(height: 32),
          _buildTitle(),
          const SizedBox(height: 24),
          _buildFeaturePills(),
          const Spacer(),
          _buildProgressBar(state.progress),
          const SizedBox(height: 16),
          _buildFooter(),
          const SizedBox(height: 24),
        ],
      ),
    );
  },
),
      ),
    );
  }

  Widget _buildTopBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withOpacity(0.25),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'SECURE SYNC v2.4',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryDark,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

 Widget _buildLogoCluster() {
  return SizedBox(
    width: 180,
    height: 180,
    child: Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 170,
          height: 170,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.primary.withOpacity(0.3),
              width: 1.2,
            ),
          ),
        ),
        Positioned(
          top: 5,
          right: 5,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primaryLight.withOpacity(0.4)),
            ),
            child: const Icon(Icons.show_chart, color: AppColors.primaryDark, size: 18),
          ),
        ),
        Container(
          width: 110,
          height: 110,
          padding: const EdgeInsetsDirectional.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(color: AppColors.primaryLight, blurRadius: 14, offset: const Offset(0, 6)),
            ],
          ),
          child: Center(
            child: Image.asset(
              'assets/images/logo.png',
              fit: BoxFit.fill,
            ),
          ),
        ),
        Positioned(
          bottom: 8,
          right: 5,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(color: AppColors.shadow, blurRadius: 8, offset: const Offset(0, 4)),
              ],
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.trending_up, color: AppColors.primaryDark, size: 13),
                SizedBox(width: 4),
                Text('+18.4%',
                    style: TextStyle(
                        fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

  Widget _buildTitle() {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'FinTrack',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
            ),
          ],
        ),
        const SizedBox(height: 6),
        const Text(
          'Take control of your money',
          style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildFeaturePills() {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: AppColors.border),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.pie_chart_outline, size: 14, color: AppColors.primary),
        const SizedBox(width: 6),
        Text(
          'SMART BUDGETS',
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(width: 14),
        Container(
          width: 1,
          height: 14,
          color: AppColors.border,
        ),
        const SizedBox(width: 14),
        Icon(Icons.bolt_outlined, size: 14, color: AppColors.primary),
        const SizedBox(width: 6),
        Text(
          'LIVE INTEL',
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
            letterSpacing: 0.3,
          ),
        ),
      ],
    ),
  );
}

 
 Widget _buildProgressBar(double progress) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 60),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: progress),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        builder: (context, value, child) {
          return LinearProgressIndicator(
            value: value,
            minHeight: 4,
            backgroundColor: AppColors.border,
            valueColor: const AlwaysStoppedAnimation(AppColors.primary),
          );
        },
      ),
    ),
  );
}

  Widget _buildFooter() {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.shield_outlined, size: 14, color: AppColors.textSecondary),
            const SizedBox(width: 6),
            Text(
              'Powered by 256-bit bank-grade encryption',
              style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Regulated • Private • Self-directed',
          style: TextStyle(fontSize: 10, color: AppColors.textSecondary.withOpacity(0.7)),
        ),
      ],
    );
  }
}