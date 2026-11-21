
import 'package:cloud_firestore/cloud_firestore.dart' show FirebaseException;
import 'package:fintrack/core/errors/failures.dart';
import 'package:fintrack/core/errors/firestore_errors.dart';
import 'package:fintrack/features/transactions/model/transaction_model.dart';
import 'package:fintrack/services/firestore_service.dart';

class TransactionRepository {
  const TransactionRepository({required FirestoreService firestoreService})
      : _firestoreService = firestoreService;

  final FirestoreService _firestoreService;

  Stream<List<TransactionModel>> watchTransactions(String userId) async* {
    try {
      await for (final rows in _firestoreService.watchTransactions(userId)) {
        yield rows.map(TransactionModel.fromMap).toList();
      }
    } on FirebaseException catch (e) {
      throw DataFailure(FirestoreErrors.messageFor(e.code));
    }
  }

 Future<void> addTransaction(TransactionModel transaction) async {
  try {
    await _firestoreService
        .addTransaction(transaction.userId, transaction.toMap())
        .timeout(
          const Duration(seconds: 8),
          onTimeout: () {},
        );
  } on FirebaseException catch (e) {
    throw DataFailure(FirestoreErrors.messageFor(e.code));
  }
}

  Future<void> saveTransactions(
    String userId,
    List<TransactionModel> transactions,
  ) async {
    try {
      await _firestoreService.setTransactions(userId, {
        for (final t in transactions) t.id: t.toMap(),
      });
    } on FirebaseException catch (e) {
      throw DataFailure(FirestoreErrors.messageFor(e.code));
    }
  }
}