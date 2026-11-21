import 'package:fintrack/features/transactions/model/category.dart';
import 'package:fintrack/features/transactions/model/transaction_model.dart';

abstract final class SampleData {
  static List<TransactionModel> transactions(String userId, {DateTime? now}) {
    final today = now ?? DateTime.now();

    DateTime at(int daysAgo, int hour, int minute) =>
        DateTime(today.year, today.month, today.day - daysAgo, hour, minute);

    TransactionModel make(
      String id,
      Category category,
      double amount,
      String note,
      DateTime date,
    ) {
      return TransactionModel(
        id: id,
        userId: userId,
        type: category.type,
        amount: amount,
        categoryId: category.id,
        categoryName: category.name,
        date: date,
        note: note,
        createdAt: today,
        updatedAt: today,
      );
    }

    return [
      make('sample_1', DefaultCategories.food, 5.60, 'Starbucks', at(0, 10, 24)),
      make('sample_2', DefaultCategories.transport, 12.30, 'Uber Ride', at(0, 8, 15)),
      make('sample_3', DefaultCategories.salary, 2500, 'Monthly Salary', at(1, 9, 0)),
      make('sample_4', DefaultCategories.food, 142.30, 'Whole Foods', at(2, 19, 5)),
      make('sample_5', DefaultCategories.shopping, 89.99, 'Amazon', at(3, 18, 40)),
      make('sample_6', DefaultCategories.bills, 160, 'Electricity bill', at(4, 12, 0)),
      make('sample_7', DefaultCategories.health, 45, 'Pharmacy', at(5, 16, 30)),
      make('sample_8', DefaultCategories.freelance, 1000, 'Logo design project', at(5, 11, 0)),
      make('sample_9', DefaultCategories.entertainment, 38.50, 'Movie night', at(6, 21, 0)),
    ];
  }
}