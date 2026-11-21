import 'package:equatable/equatable.dart';
import 'package:fintrack/features/transactions/model/transaction_type.dart';

class Category extends Equatable {
  const Category({
    required this.id,
    required this.name,
    required this.type,
    this.description = '',
  });

  final String id;
  final String name;
  final TransactionType type;
  final String description;

  @override
  List<Object?> get props => [id, name, type, description];
}

abstract final class DefaultCategories {
  static const food = Category(id: 'food', name: 'Food & Drinks', type: TransactionType.expense, description: 'Dining & coffee');
  static const shopping = Category(id: 'shopping', name: 'Shopping', type: TransactionType.expense, description: 'Retail & fashion');
  static const transport = Category(id: 'transport', name: 'Transport', type: TransactionType.expense, description: 'Rides, fuel & transit');
  static const bills = Category(id: 'bills', name: 'Bills & Utilities', type: TransactionType.expense, description: 'Electric, water, net');
  static const entertainment = Category(id: 'entertainment', name: 'Entertainment', type: TransactionType.expense, description: 'Cinema, games, gigs');
  static const health = Category(id: 'health', name: 'Health & Wellness', type: TransactionType.expense, description: 'Medical & gym');
  static const education = Category(id: 'education', name: 'Education', type: TransactionType.expense, description: 'Courses & books');
  static const travel = Category(id: 'travel', name: 'Travel & Holiday', type: TransactionType.expense, description: 'Flights & hotels');
  static const groceries = Category(id: 'groceries', name: 'Groceries', type: TransactionType.expense, description: 'Supermarkets');
  static const personalCare = Category(id: 'personal_care', name: 'Personal Care', type: TransactionType.expense, description: 'Barber & skincare');
  static const savingsInvestment = Category(id: 'savings_investment', name: 'Investment', type: TransactionType.expense, description: 'Stocks & assets');
  static const otherExpense = Category(id: 'other_expense', name: 'Other', type: TransactionType.expense, description: 'Miscellaneous');
  static const salary = Category(id: 'salary', name: 'Salary', type: TransactionType.income, description: 'Monthly pay');
  static const freelance = Category(id: 'freelance', name: 'Freelance', type: TransactionType.income, description: 'Side projects');
  static const business = Category(id: 'business', name: 'Business', type: TransactionType.income, description: 'Sales & profit');
  static const investment = Category(id: 'investment', name: 'Investment', type: TransactionType.income, description: 'Returns & dividends');
  static const gift = Category(id: 'gift', name: 'Gift', type: TransactionType.income, description: 'Presents & transfers');
  static const otherIncome = Category(id: 'other_income', name: 'Other', type: TransactionType.income, description: 'Miscellaneous');

  static const List<Category> expense = [
    food, shopping, transport, bills, entertainment, health,
    education, travel, groceries, personalCare, savingsInvestment, otherExpense,
  ];

  static const List<Category> income = [
    salary, freelance, business, investment, gift, otherIncome,
  ];

  static List<Category> forType(TransactionType type) =>
      type == TransactionType.income ? income : expense;
}