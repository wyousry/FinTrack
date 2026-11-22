
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

  Stream<TransactionModel?> watchTransaction(
    String userId,
    String transactionId,
  ) async* {
    try {
      await for (final row
          in _firestoreService.watchTransaction(userId, transactionId)) {
        yield row == null ? null : TransactionModel.fromMap(row);
      }
    } on FirebaseException catch (e) {
      throw DataFailure(FirestoreErrors.messageFor(e.code));
    }
  }

  Future<void> addTransaction(TransactionModel transaction) {
    return _guard(
      () => _firestoreService.addTransaction(transaction.userId, transaction.toMap()),
    );
  }

  Future<void> updateTransaction(TransactionModel transaction) {
    return _guard(
      () => _firestoreService.updateTransaction(
        transaction.userId,
        transaction.id,
        {
          'type': transaction.type.value,
          'amount': transaction.amount,
          'categoryId': transaction.categoryId,
          'categoryName': transaction.categoryName,
          'date': transaction.date,
          'note': transaction.note,
        },
      ),
    );
  }

  Future<void> deleteTransaction({required String userId, required String id}) {
    return _guard(() => _firestoreService.deleteTransaction(userId, id));
  }

  Future<void> saveTransactions(
    String userId,
    List<TransactionModel> transactions,
  ) {
    return _guard(
      () => _firestoreService.setTransactions(userId, {
        for (final t in transactions) t.id: t.toMap(),
      }),
    );
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