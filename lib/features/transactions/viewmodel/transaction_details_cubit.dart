
import 'dart:async';

import 'package:fintrack/core/errors/failures.dart';
import 'package:fintrack/features/auth/repository/auth_repository.dart';
import 'package:fintrack/features/transactions/model/transaction_model.dart';
import 'package:fintrack/features/transactions/repository/transaction_repository.dart';
import 'package:fintrack/features/transactions/viewmodel/transaction_details_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TransactionDetailsCubit extends Cubit<TransactionDetailsState> {
  TransactionDetailsCubit({
    required AuthRepository authRepository,
    required TransactionRepository transactionRepository,
  })  : _authRepository = authRepository,
        _transactionRepository = transactionRepository,
        super(const TransactionDetailsState());

  final AuthRepository _authRepository;
  final TransactionRepository _transactionRepository;

  StreamSubscription<TransactionModel?>? _subscription;
  String? _transactionId;
  String? _userId;

  static const String _genericError = 'Something went wrong. Please try again.';

  void start(String transactionId) {
    final user = _authRepository.currentUser;
    if (user == null) {
      emit(const TransactionDetailsState(
        status: TransactionDetailsStatus.failure,
        errorMessage: 'Please log in again.',
      ));
      return;
    }

    _transactionId = transactionId;
    _userId = user.uid;
    _subscription?.cancel();
    emit(const TransactionDetailsState());

    _subscription = _transactionRepository
        .watchTransaction(user.uid, transactionId)
        .listen(_onData, onError: _onError);
  }

  void retry() {
    final id = _transactionId;
    if (id != null) start(id);
  }

  void _onData(TransactionModel? transaction) {
    if (transaction == null) {
      emit(state.copyWith(status: TransactionDetailsStatus.notFound));
      return;
    }
    emit(state.copyWith(
      status: TransactionDetailsStatus.loaded,
      transaction: transaction,
    ));
  }

  void _onError(Object error, StackTrace stackTrace) {
    debugPrint('Transaction stream error: $error');
    emit(state.copyWith(
      status: TransactionDetailsStatus.failure,
      errorMessage: error is Failure ? error.message : _genericError,
    ));
  }

  Future<void> delete() async {
    final transaction = state.transaction;
    final userId = _userId;
    if (transaction == null || userId == null || state.isDeleting) return;

    emit(state.copyWith(isDeleting: true));
    try {
      await _transactionRepository.deleteTransaction(
        userId: userId,
        id: transaction.id,
      );
    } on Failure catch (e) {
      if (isClosed) return;
      emit(state.copyWith(isDeleting: false, errorMessage: e.message));
    } catch (e) {
      debugPrint('Delete transaction failed: $e');
      if (isClosed) return;
      emit(state.copyWith(isDeleting: false, errorMessage: _genericError));
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}