import 'dart:async';

import 'package:fintrack/core/dev/sample_data.dart';
import 'package:fintrack/core/errors/failures.dart';
import 'package:fintrack/features/auth/repository/auth_repository.dart';
import 'package:fintrack/features/goals/model/savings_goal.dart';
import 'package:fintrack/features/goals/repository/goal_repository.dart';
import 'package:fintrack/features/home/model/dashboard_summary.dart';
import 'package:fintrack/features/home/viewmodel/home_state.dart';
import 'package:fintrack/features/transactions/model/transaction_model.dart';
import 'package:fintrack/features/transactions/repository/transaction_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit({
    required AuthRepository authRepository,
    required TransactionRepository transactionRepository,
    required GoalRepository goalRepository,
  })  : _authRepository = authRepository,
        _transactionRepository = transactionRepository,
        _goalRepository = goalRepository,
        super(HomeState(selectedMonth: _monthStart(DateTime.now())));

  final AuthRepository _authRepository;
  final TransactionRepository _transactionRepository;
  final GoalRepository _goalRepository;
  StreamSubscription<List<TransactionModel>>? _transactionsSubscription;
  StreamSubscription<List<SavingsGoal>>? _goalsSubscription;

  static const String _genericError = 'Something went wrong. Please try again.';

  late final List<DateTime> monthOptions = List.generate(12, (i) {
    final now = DateTime.now();
    return DateTime(now.year, now.month - i);
  });

  static DateTime _monthStart(DateTime d) => DateTime(d.year, d.month);

  void start() {
    final user = _authRepository.currentUser;
    if (user == null) {
      emit(state.copyWith(
        status: HomeStatus.failure,
        errorMessage: 'Please log in to see your dashboard.',
      ));
      return;
    }

    _transactionsSubscription?.cancel();
    _goalsSubscription?.cancel();
    emit(state.copyWith(status: HomeStatus.loading, user: user));

    _transactionsSubscription = _transactionRepository
        .watchTransactions(user.uid)
        .listen(_onTransactions, onError: _onError);

    _goalsSubscription = _goalRepository
        .watchGoals(user.uid)
        .listen(_onGoals, onError: _onGoalsError);
  }

  void _onTransactions(List<TransactionModel> transactions) {
    emit(state.copyWith(
      status: HomeStatus.success,
      transactions: transactions,
      summary: DashboardSummary.fromTransactions(
        transactions,
        selectedMonth: state.selectedMonth,
      ),
    ));
  }

  void _onGoals(List<SavingsGoal> goals) {
    emit(state.copyWith(goals: goals, errorMessage: state.errorMessage));
  }

  void _onError(Object error, StackTrace stackTrace) {
    debugPrint('Home stream error: $error');
    emit(state.copyWith(
      status: HomeStatus.failure,
      errorMessage: error is Failure ? error.message : _genericError,
    ));
  }

  void _onGoalsError(Object error, StackTrace stackTrace) {
    debugPrint('Goals stream error: $error');
  }

  void selectMonth(DateTime month) {
    emit(state.copyWith(
      selectedMonth: month,
      summary: DashboardSummary.fromTransactions(
        state.transactions,
        selectedMonth: month,
      ),
    ));
  }

  void toggleBalanceVisibility() {
    emit(state.copyWith(balanceHidden: !state.balanceHidden));
  }

  Future<void> addSampleData() async {
    if (!kDebugMode) return;
    final user = _authRepository.currentUser;
    if (user == null) return;

    try {
      await _transactionRepository.saveTransactions(
        user.uid,
        SampleData.transactions(user.uid),
      );
      debugPrint('Sample data saved');
    } on Failure catch (e) {
      debugPrint('Sample data failed: ${e.message}');
      if (isClosed) return;
      emit(state.copyWith(status: HomeStatus.failure, errorMessage: e.message));
    } catch (e) {
      debugPrint('Sample data failed: $e');
    }
  }

  @override
  Future<void> close() {
    _transactionsSubscription?.cancel();
    _goalsSubscription?.cancel();
    return super.close();
  }
}