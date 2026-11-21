import 'package:fintrack/core/constants/app_colors.dart';
import 'package:fintrack/core/routing/app_router.dart';
import 'package:fintrack/core/utils/formatters.dart';
import 'package:fintrack/core/widgets/app_card.dart';
import 'package:fintrack/core/widgets/empty_state.dart';
import 'package:fintrack/core/widgets/error_state.dart';
import 'package:fintrack/features/auth/repository/auth_repository.dart';
import 'package:fintrack/features/home/view/widgets/balance_card.dart';
import 'package:fintrack/features/home/view/widgets/greeting_bar.dart';
import 'package:fintrack/features/home/view/widgets/home_app_bar.dart';
import 'package:fintrack/features/home/view/widgets/home_skeleton.dart';
import 'package:fintrack/features/home/view/widgets/quick_actions.dart';
import 'package:fintrack/features/home/view/widgets/recent_transactions_section.dart';
import 'package:fintrack/features/home/view/widgets/spending_overview_card.dart';
import 'package:fintrack/features/home/viewmodel/home_cubit.dart';
import 'package:fintrack/features/home/viewmodel/home_state.dart';
import 'package:fintrack/features/transactions/model/transaction_type.dart';
import 'package:fintrack/features/transactions/repository/transaction_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:fintrack/features/goals/repository/goal_repository.dart';
import 'package:fintrack/features/goals/view/goal_sheets.dart';
import 'package:fintrack/features/goals/view/widgets/savings_goal_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeCubit(
        goalRepository: context.read<GoalRepository>(),
        authRepository: context.read<AuthRepository>(),
        transactionRepository: context.read<TransactionRepository>(),
      )..start(),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

void _addTransaction(BuildContext context, TransactionType type) {
  context.push(AppRoutes.addTransaction, extra: type);
}

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<HomeCubit>();
    final topPadding = MediaQuery.paddingOf(context).top + HomeAppBar.height;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          final Widget body;
          if (state.status == HomeStatus.failure) {
            body = Padding(
              padding: EdgeInsets.only(top: topPadding),
              child: ErrorState(
                message: state.errorMessage ?? 'Please try again.',
                onRetry: cubit.start,
              ),
            );
          } else {
            body = SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(16, topPadding, 16, 24),
              child: Column(
                children: [
                  GreetingBar(
                    greeting:
                        '${Formatters.greeting(DateTime.now())}, ${state.user?.firstName ?? ''}',
                    initial: state.user?.initial ?? '',
                    hasUnread: true,
                    onAvatarTap: () => context.go(AppRoutes.profile),
                  ),
                  const SizedBox(height: 26),
                  if (state.status == HomeStatus.loading)
                    const HomeSkeleton()
                  else
                    ..._content(context, state, cubit),
                ],
              ),
            );
          }

          return Stack(
            children: [
              Positioned.fill(child: body),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: HomeAppBar(
                  onAvatarTap: () => context.go(AppRoutes.profile),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

 List<Widget> _content(BuildContext context, HomeState state, HomeCubit cubit) {
  final summary = state.summary;
  final goal = state.featuredGoal;

  return [
    BalanceCard(
      balance: summary.balance,
      income: summary.totalIncome,
      expenses: summary.totalExpenses,
      changePercent: summary.balanceChangePercent,
      hidden: state.balanceHidden,
      onToggleHidden: cubit.toggleBalanceVisibility,
    ),
    const SizedBox(height: 24),
   QuickActions(
  onIncome: () => _addTransaction(context, TransactionType.income),
  onExpense: () => _addTransaction(context, TransactionType.expense),
),
    const SizedBox(height: 24),
    if (state.isEmpty)
      AppCard(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: [
            EmptyState(
              icon: Icons.receipt_long_rounded,
              title: 'No transactions yet',
              message: 'Add your first transaction to start tracking your spending.',
              actionLabel: 'Add Transaction',
             onAction: () => _addTransaction(context, TransactionType.expense),
            ),
            if (kDebugMode)
              TextButton(
                onPressed: cubit.addSampleData,
                child: const Text('Load sample data (debug)'),
              ),
          ],
        ),
      )
    else ...[
      SpendingOverviewCard(
        month: state.selectedMonth,
        monthOptions: cubit.monthOptions,
        onMonthSelected: cubit.selectMonth,
        totalSpent: summary.monthlySpending,
        categories: summary.spendingByCategory,
      ),
      const SizedBox(height: 24),
      RecentTransactionsSection(
        transactions: state.recentTransactions,
        onSeeAll: () => context.go(AppRoutes.transactions),
      ),
    ],
    const SizedBox(height: 24),
    if (goal == null)
      SavingsGoalEmptyCard(onTap: () => showCreateGoalSheet(context))
    else
      SavingsGoalCard(
        goal: goal,
        onTap: () => showAddFundsSheet(context, goal),
      ),
  ];
}
}