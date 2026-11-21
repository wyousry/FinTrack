// lib/features/onboarding/model/onboarding_page_model.dart

import 'package:fintrack/features/onboarding/view/widgets/budgets_illustration.dart';
import 'package:fintrack/features/onboarding/view/widgets/expense_tracking_illustration.dart';
import 'package:fintrack/features/onboarding/view/widgets/security_illustration.dart';
import 'package:flutter/material.dart';

class OnboardingPageModel {
  final String title;
  final String description;
  final WidgetBuilder illustrationBuilder;

  const OnboardingPageModel({
    required this.title,
    required this.description,
    required this.illustrationBuilder,
  });
}

final List<OnboardingPageModel> onboardingPages = [
  OnboardingPageModel(
    title: 'Track Your Expenses Easily',
    description: 'Keep an eye on your spending and make better financial decisions.',
    illustrationBuilder: (context) => const ExpenseTrackingIllustration(),
  ),
  OnboardingPageModel(
    title: 'Your Data is Safe',
    description: 'We use industry-standard security to keep your financial information protected at all times.',
    illustrationBuilder: (context) => const SecurityIllustration(),
  ),
  OnboardingPageModel(
    title: 'Set Budgets & Reach Your Goals',
    description: 'Create budgets, get insights, and stay on track with smart automated limits.',
    illustrationBuilder: (context) => const BudgetsIllustration(),
  ),
];