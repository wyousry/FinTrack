import 'package:equatable/equatable.dart';
import 'package:fintrack/features/transactions/model/transaction_type.dart';

class Category extends Equatable {
  const Category({required this.id, required this.name, required this.type});

  final String id;
  final String name;
  final TransactionType type;

  @override
  List<Object?> get props => [id, name, type];
}

abstract final class DefaultCategories {
  static const food = Category(id: 'food', name: 'Food & Drinks', type: TransactionType.expense);
  static const transport = Category(id: 'transport', name: 'Transport', type: TransactionType.expense);
  static const shopping = Category(id: 'shopping', name: 'Shopping', type: TransactionType.expense);
  static const bills = Category(id: 'bills', name: 'Bills & Utilities', type: TransactionType.expense);
  static const health = Category(id: 'health', name: 'Health', type: TransactionType.expense);
  static const education = Category(id: 'education', name: 'Education', type: TransactionType.expense);
  static const entertainment = Category(id: 'entertainment', name: 'Entertainment', type: TransactionType.expense);
  static const travel = Category(id: 'travel', name: 'Travel', type: TransactionType.expense);
  static const otherExpense = Category(id: 'other_expense', name: 'Other', type: TransactionType.expense);

  static const salary = Category(id: 'salary', name: 'Salary', type: TransactionType.income);
  static const freelance = Category(id: 'freelance', name: 'Freelance', type: TransactionType.income);
  static const business = Category(id: 'business', name: 'Business', type: TransactionType.income);
  static const investment = Category(id: 'investment', name: 'Investment', type: TransactionType.income);
  static const gift = Category(id: 'gift', name: 'Gift', type: TransactionType.income);
  static const otherIncome = Category(id: 'other_income', name: 'Other', type: TransactionType.income);

  static const List<Category> expense = [
    food, transport, shopping, bills, health, education, entertainment, travel, otherExpense,
  ];
  static const List<Category> income = [
    salary, freelance, business, investment, gift, otherIncome,
  ];
}