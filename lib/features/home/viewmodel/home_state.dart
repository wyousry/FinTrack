import 'package:equatable/equatable.dart';
import 'package:fintrack/features/auth/model/app_user.dart';
import 'package:fintrack/features/goals/model/savings_goal.dart';
import 'package:fintrack/features/home/model/dashboard_summary.dart';
import 'package:fintrack/features/transactions/model/transaction_model.dart';

enum HomeStatus { loading, success, failure }

class HomeState extends Equatable {
  const HomeState({
    required this.selectedMonth,
    this.status = HomeStatus.loading,
    this.user,
    this.transactions = const [],
    this.goals = const [],
    this.summary = DashboardSummary.empty,
    this.balanceHidden = false,
    this.errorMessage,
  });

  static const int recentCount = 4;

  final HomeStatus status;
  final AppUser? user;
  final List<TransactionModel> transactions;
  final List<SavingsGoal> goals;
  final DashboardSummary summary;
  final DateTime selectedMonth;
  final bool balanceHidden;
  final String? errorMessage;

  bool get isEmpty => transactions.isEmpty;

  List<TransactionModel> get recentTransactions =>
      transactions.take(recentCount).toList();

  SavingsGoal? get featuredGoal => goals.isEmpty ? null : goals.first;

  HomeState copyWith({
    HomeStatus? status,
    AppUser? user,
    List<TransactionModel>? transactions,
    List<SavingsGoal>? goals,
    DashboardSummary? summary,
    DateTime? selectedMonth,
    bool? balanceHidden,
    String? errorMessage,
  }) {
    return HomeState(
      status: status ?? this.status,
      user: user ?? this.user,
      transactions: transactions ?? this.transactions,
      goals: goals ?? this.goals,
      summary: summary ?? this.summary,
      selectedMonth: selectedMonth ?? this.selectedMonth,
      balanceHidden: balanceHidden ?? this.balanceHidden,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        user,
        transactions,
        goals,
        summary,
        selectedMonth,
        balanceHidden,
        errorMessage,
      ];
}