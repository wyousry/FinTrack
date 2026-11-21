import 'package:cloud_firestore/cloud_firestore.dart' show FirebaseException;
import 'package:fintrack/core/errors/failures.dart';
import 'package:fintrack/core/errors/firestore_errors.dart';
import 'package:fintrack/features/goals/model/savings_goal.dart';
import 'package:fintrack/services/firestore_service.dart';

class GoalRepository {
  const GoalRepository({required FirestoreService firestoreService})
      : _firestoreService = firestoreService;

  final FirestoreService _firestoreService;

  Stream<List<SavingsGoal>> watchGoals(String userId) async* {
    try {
      await for (final rows in _firestoreService.watchGoals(userId)) {
        yield rows.map(SavingsGoal.fromMap).toList();
      }
    } on FirebaseException catch (e) {
      throw DataFailure(FirestoreErrors.messageFor(e.code));
    }
  }

  Future<void> createGoal({
    required String userId,
    required String name,
    required double targetAmount,
    double savedAmount = 0,
  }) {
    return _guard(() {
      final now = DateTime.now();
      final goal = SavingsGoal(
        id: '',
        userId: userId,
        name: name.trim(),
        targetAmount: targetAmount,
        savedAmount: savedAmount,
        createdAt: now,
        updatedAt: now,
      );
      return _firestoreService.addGoal(userId, goal.toMap());
    });
  }

  Future<void> addFunds({
    required String userId,
    required String goalId,
    required double amount,
  }) {
    return _guard(() => _firestoreService.addToGoal(userId, goalId, amount));
  }

  Future<void> deleteGoal({required String userId, required String goalId}) {
    return _guard(() => _firestoreService.deleteGoal(userId, goalId));
  }

  Future<void> _guard(Future<void> Function() action) async {
    try {
      await action().timeout(
        const Duration(seconds: 8),
        onTimeout: () {},
      );
    } on FirebaseException catch (e) {
      throw DataFailure(FirestoreErrors.messageFor(e.code));
    }
  }
}