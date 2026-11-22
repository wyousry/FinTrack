import 'package:fintrack/core/errors/failures.dart';
import 'package:fintrack/core/utils/validators.dart';
import 'package:fintrack/features/auth/repository/auth_repository.dart';
import 'package:fintrack/features/transactions/model/category.dart';
import 'package:fintrack/features/transactions/model/transaction_form_validator.dart';
import 'package:fintrack/features/transactions/model/transaction_model.dart';
import 'package:fintrack/features/transactions/model/transaction_type.dart';
import 'package:fintrack/features/transactions/repository/transaction_repository.dart';
import 'package:fintrack/features/transactions/viewmodel/transaction_form_state.dart';
import 'package:flutter/foundation.dart' hide Category;
import 'package:flutter_bloc/flutter_bloc.dart';


class TransactionFormCubit extends Cubit<TransactionFormState> {
  TransactionFormCubit({
    required AuthRepository authRepository,
    required TransactionRepository transactionRepository,
    TransactionType initialType = TransactionType.expense,
    TransactionModel? template,
    TransactionModel? editing,
    DateTime? now,
  })  : _authRepository = authRepository,
        _transactionRepository = transactionRepository,
        _editing = editing,
        initialNote = (editing ?? template)?.note ?? '',
        super(_initialState(initialType, template, editing, now ?? DateTime.now()));

  final AuthRepository _authRepository;
  final TransactionRepository _transactionRepository;
  final TransactionModel? _editing;
  final String initialNote;

  static const String _genericError = 'Something went wrong. Please try again.';

  static TransactionFormState _initialState(
    TransactionType type,
    TransactionModel? template,
    TransactionModel? editing,
    DateTime now,
  ) {
    final source = editing ?? template;
    if (source == null) return TransactionFormState(type: type, date: now);

    return TransactionFormState(
      type: source.type,
      date: editing?.date ?? now,
      amountText: source.amount.toStringAsFixed(2),
      category: DefaultCategories.byId(source.categoryId) ??
          Category(
            id: source.categoryId,
            name: source.categoryName,
            type: source.type,
          ),
    );
  }

  void typeChanged(TransactionType type) {
    if (type == state.type) return;
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

  double _parsedAmount() =>
      ((Validators.parseAmount(state.amountText) ?? 0) * 100).round() / 100;

  bool hasChanges({required String note}) {
    final original = _editing;
    if (original == null) return true;
    return state.type != original.type ||
        _parsedAmount() != original.amount ||
        state.category?.id != original.categoryId ||
        state.date != original.date ||
        note.trim() != original.note.trim();
  }

  Future<void> save({required String note}) async {
    if (state.isSaving) return;

    final category = state.category;
    final errors = TransactionFormValidator.validate(
      amountText: state.amountText,
      category: category,
      date: state.date,
    );

    if (errors.hasAny || category == null) {
      emit(state.withErrors(
        amountError: errors.amount,
        categoryError: errors.category,
        dateError: errors.date,
      ));
      return;
    }

    final original = _editing;
    if (original != null && !hasChanges(note: note)) {
      emit(state.copyWith(status: TransactionFormStatus.success));
      return;
    }

    final user = _authRepository.currentUser;
    if (user == null) {
      emit(state.copyWith(
        status: TransactionFormStatus.failure,
        errorMessage: 'Please log in again.',
      ));
      return;
    }

    final now = DateTime.now();
    final transaction = TransactionModel(
      id: original?.id ?? '',
      userId: user.uid,
      type: state.type,
      amount: _parsedAmount(),
      categoryId: category.id,
      categoryName: category.name,
      date: state.date,
      note: note.trim(),
      createdAt: original?.createdAt ?? now,
      updatedAt: now,
    );

    emit(state.withErrors().copyWith(status: TransactionFormStatus.saving));
    try {
      if (original == null) {
        await _transactionRepository.addTransaction(transaction);
      } else {
        await _transactionRepository.updateTransaction(transaction);
      }
      if (isClosed) return;
      emit(state.copyWith(status: TransactionFormStatus.success));
    } on Failure catch (e) {
      if (isClosed) return;
      emit(state.copyWith(
        status: TransactionFormStatus.failure,
        errorMessage: e.message,
      ));
    } catch (e) {
      debugPrint('Save transaction failed: $e');
      if (isClosed) return;
      emit(state.copyWith(
        status: TransactionFormStatus.failure,
        errorMessage: _genericError,
      ));
    }
  }
}