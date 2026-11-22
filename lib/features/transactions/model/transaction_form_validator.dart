
import 'package:fintrack/core/utils/validators.dart';
import 'package:fintrack/features/transactions/model/category.dart';

class TransactionFormErrors {
  const TransactionFormErrors({this.amount, this.category, this.date});

  final String? amount;
  final String? category;
  final String? date;

  bool get hasAny => amount != null || category != null || date != null;
}

abstract final class TransactionFormValidator {
  static TransactionFormErrors validate({
    required String amountText,
    required Category? category,
    required DateTime date,
    DateTime? now,
  }) {
    final current = now ?? DateTime.now();
    return TransactionFormErrors(
      amount: amountText.trim().isEmpty
          ? 'Amount is required'
          : Validators.positiveAmount(amountText),
      category: category == null ? 'Please choose a category' : null,
      date: date.isAfter(current.add(const Duration(minutes: 1)))
          ? "Date can't be in the future"
          : null,
    );
  }
}