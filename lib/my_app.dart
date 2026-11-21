import 'package:fintrack/core/routing/app_router.dart';
import 'package:fintrack/core/theme/app_theme.dart';
import 'package:fintrack/features/auth/repository/auth_repository.dart';
import 'package:fintrack/features/goals/repository/goal_repository.dart';
import 'package:fintrack/services/auth_service.dart';
import 'package:fintrack/services/firestore_service.dart';
import 'package:fintrack/features/transactions/repository/transaction_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FinTrackApp extends StatelessWidget {
  const FinTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>(
          create: (_) => AuthRepository(authService: AuthService()),
        ),
        RepositoryProvider<TransactionRepository>(
          create: (_) => TransactionRepository(firestoreService: FirestoreService()),
        ),
        RepositoryProvider<GoalRepository>(
  create: (_) => GoalRepository(firestoreService: FirestoreService()),
),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        routerConfig: appRouter,
      ),
    );
  }
}