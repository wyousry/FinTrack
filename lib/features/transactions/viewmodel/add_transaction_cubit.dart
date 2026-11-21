import 'package:fintrack/core/errors/failures.dart';
import 'package:fintrack/core/utils/validators.dart';
import 'package:fintrack/features/auth/repository/auth_repository.dart';
import 'package:fintrack/features/transactions/model/category.dart';
import 'package:fintrack/features/transactions/model/transaction_model.dart';
import 'package:fintrack/features/transactions/model/transaction_type.dart';
import 'package:fintrack/features/transactions/repository/transaction_repository.dart';
import 'package:fintrack/features/transactions/viewmodel/add_transaction_state.dart';
import 'package:flutter/foundation.dart' hide Category;
import 'package:flutter_bloc/flutter_bloc.dart';

class AddTransactionCubit extends Cubit<AddTransactionState> {
  AddTransactionCubit({
    required AuthRepository authRepository,
    required TransactionRepository transactionRepository,
    TransactionType initialType = TransactionType.expense,
    DateTime? now,
  })  : _authRepository = authRepository,
        _transactionRepository = transactionRepository,
        super(AddTransactionState(type: initialType, date: now ?? DateTime.now()));

  final AuthRepository _authRepository;
  final TransactionRepository _transactionRepository;

  static const String _genericError = 'Something went wrong. Please try again.';

  void typeChanged(TransactionType type) {
    if (type == state.type) return;
    // الـ category اللي من النوع التاني مبتنفعش، فبنمسحها
    final keepCategory = state.category?.type == type;
    emit(state.copyWith(type: type, clearCategory: !keepCategory));
  }

  void amountChanged(String text) {
    emit(state.copyWith(amountText: text, clearAmountError: true));
  }

  void categorySelected(Category category) {
    emit(state.copyWith(
      category: category,
      type: category.type,
      clearCategoryError: true,
    ));
  }

  void dateChanged(DateTime date) {
    emit(state.copyWith(date: date, clearDateError: true));
  }

  Future<void> save({required String note}) async {
    if (state.isSaving) return;

    final category = state.category;
    final amountError = state.amountText.trim().isEmpty
        ? 'Amount is required'
        : Validators.positiveAmount(state.amountText);
    final categoryError = category == null ? 'Please choose a category' : null;
    final dateError =
        state.date.isAfter(DateTime.now().add(const Duration(minutes: 1)))
            ? "Date can't be in the future"
            : null;

    if (amountError != null ||
        categoryError != null ||
        dateError != null ||
        category == null) {
      emit(state.withErrors(
        amountError: amountError,
        categoryError: categoryError,
        dateError: dateError,
      ));
      return;
    }

    final user = _authRepository.currentUser;
    if (user == null) {
      emit(state.copyWith(
        status: AddTransactionStatus.failure,
        errorMessage: 'Please log in again.',
      ));
      return;
    }

    // تقريب لخانتين عشريتين عشان نتجنب أخطاء الـ double
    final amount = ((Validators.parseAmount(state.amountText) ?? 0) * 100).round() / 100;
    final now = DateTime.now();

    final transaction = TransactionModel(
      id: '',
      userId: user.uid,
      type: state.type,
      amount: amount,
      categoryId: category.id,
      categoryName: category.name,
      date: state.date,
      note: note.trim(),
      createdAt: now,
      updatedAt: now,
    );

    emit(state.withErrors().copyWith(status: AddTransactionStatus.saving));
    try {
      await _transactionRepository.addTransaction(transaction);
      if (isClosed) return;
      emit(state.copyWith(status: AddTransactionStatus.success));
    } on Failure catch (e) {
      if (isClosed) return;
      emit(state.copyWith(
        status: AddTransactionStatus.failure,
        errorMessage: e.message,
      ));
    } catch (e) {
      debugPrint('Add transaction failed: $e');
      if (isClosed) return;
      emit(state.copyWith(
        status: AddTransactionStatus.failure,
        errorMessage: _genericError,
      ));
    }
  }
}