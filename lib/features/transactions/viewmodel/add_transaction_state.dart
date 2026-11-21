import 'package:equatable/equatable.dart';
import 'package:fintrack/features/transactions/model/category.dart';
import 'package:fintrack/features/transactions/model/transaction_type.dart';

enum AddTransactionStatus { initial, saving, success, failure }

class AddTransactionState extends Equatable {
  const AddTransactionState({
    required this.type,
    required this.date,
    this.amountText = '',
    this.category,
    this.status = AddTransactionStatus.initial,
    this.errorMessage,
    this.amountError,
    this.categoryError,
    this.dateError,
  });

  final TransactionType type;
  final DateTime date;
  final String amountText;
  final Category? category;
  final AddTransactionStatus status;
  final String? errorMessage;
  final String? amountError;
  final String? categoryError;
  final String? dateError;

  bool get isSaving => status == AddTransactionStatus.saving;

  AddTransactionState copyWith({
    TransactionType? type,
    DateTime? date,
    String? amountText,
    Category? category,
    AddTransactionStatus? status,
    String? errorMessage,
    bool clearCategory = false,
    bool clearAmountError = false,
    bool clearCategoryError = false,
    bool clearDateError = false,
  }) {
    return AddTransactionState(
      type: type ?? this.type,
      date: date ?? this.date,
      amountText: amountText ?? this.amountText,
      category: clearCategory ? null : (category ?? this.category),
      status: status ?? this.status,
      errorMessage: errorMessage,
      amountError: clearAmountError ? null : amountError,
      categoryError: clearCategoryError ? null : categoryError,
      dateError: clearDateError ? null : dateError,
    );
  }

  AddTransactionState withErrors({
    String? amountError,
    String? categoryError,
    String? dateError,
  }) {
    return AddTransactionState(
      type: type,
      date: date,
      amountText: amountText,
      category: category,
      status: status,
      errorMessage: errorMessage,
      amountError: amountError,
      categoryError: categoryError,
      dateError: dateError,
    );
  }

  @override
  List<Object?> get props => [
    type,
    date,
    amountText,
    category,
    status,
    errorMessage,
    amountError,
    categoryError,
    dateError,
  ];
}
