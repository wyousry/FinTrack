import 'package:fintrack/core/errors/failures.dart';
import 'package:fintrack/features/auth/repository/auth_repository.dart';
import 'package:fintrack/features/goals/repository/goal_repository.dart';
import 'package:fintrack/features/goals/viewmodel/goal_actions_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GoalActionsCubit extends Cubit<GoalActionsState> {
  GoalActionsCubit({
    required AuthRepository authRepository,
    required GoalRepository goalRepository,
  })  : _authRepository = authRepository,
        _goalRepository = goalRepository,
        super(const GoalActionsState());

  final AuthRepository _authRepository;
  final GoalRepository _goalRepository;

  static const String _genericError = 'Something went wrong. Please try again.';

  Future<void> createGoal({
    required String name,
    required double targetAmount,
    double savedAmount = 0,
  }) {
    return _run((userId) => _goalRepository.createGoal(
          userId: userId,
          name: name,
          targetAmount: targetAmount,
          savedAmount: savedAmount,
        ));
  }

  Future<void> addFunds({required String goalId, required double amount}) {
    return _run((userId) => _goalRepository.addFunds(
          userId: userId,
          goalId: goalId,
          amount: amount,
        ));
  }

  Future<void> deleteGoal(String goalId) {
    return _run((userId) => _goalRepository.deleteGoal(userId: userId, goalId: goalId));
  }

  Future<void> _run(Future<void> Function(String userId) action) async {
    if (state.isSaving) return;

    final user = _authRepository.currentUser;
    if (user == null) {
      emit(const GoalActionsState(
        status: GoalActionStatus.failure,
        errorMessage: 'Please log in again.',
      ));
      return;
    }

    emit(const GoalActionsState(status: GoalActionStatus.saving));
    try {
      await action(user.uid);
      if (isClosed) return;
      emit(const GoalActionsState(status: GoalActionStatus.success));
    } on Failure catch (e) {
      if (isClosed) return;
      emit(GoalActionsState(status: GoalActionStatus.failure, errorMessage: e.message));
    } catch (e) {
      debugPrint('Goal action failed: $e');
      if (isClosed) return;
      emit(const GoalActionsState(
        status: GoalActionStatus.failure,
        errorMessage: _genericError,
      ));
    }
  }
}