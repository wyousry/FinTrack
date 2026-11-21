import 'package:equatable/equatable.dart';
import 'package:fintrack/features/transactions/model/transaction_model.dart';

class CategorySpending extends Equatable {
  const CategorySpending({
    required this.categoryId,
    required this.name,
    required this.amount,
    required this.percent,
  });

  final String categoryId;
  final String name;
  final double amount;
  final double percent;

  @override
  List<Object?> get props => [categoryId, name, amount, percent];
}

class DashboardSummary extends Equatable {
  const DashboardSummary({
    required this.totalIncome,
    required this.totalExpenses,
    required this.monthlySpending,
    required this.spendingByCategory,
    this.balanceChangePercent,
  });

  static const DashboardSummary empty = DashboardSummary(
    totalIncome: 0,
    totalExpenses: 0,
    monthlySpending: 0,
    spendingByCategory: [],
  );

  static const String othersId = '_others';
  static const int maxSlices = 5;

  final double totalIncome;
  final double totalExpenses;
  final double monthlySpending;
  final List<CategorySpending> spendingByCategory;

  final double? balanceChangePercent;

  double get balance => totalIncome - totalExpenses;

  static DashboardSummary fromTransactions(
    List<TransactionModel> transactions, {
    required DateTime selectedMonth,
    DateTime? now,
  }) {
    final today = now ?? DateTime.now();
    final currentMonthStart = DateTime(today.year, today.month);

    var income = 0.0;
    var expenses = 0.0;
    var balanceBeforeThisMonth = 0.0;
    var monthlyTotal = 0.0;
    final byCategory = <String, ({String name, double amount})>{};

    for (final t in transactions) {
      if (t.isIncome) {
        income += t.amount;
      } else {
        expenses += t.amount;
      }
      if (t.date.isBefore(currentMonthStart)) {
        balanceBeforeThisMonth += t.signedAmount;
      }

      if (t.isExpense && _isSameMonth(t.date, selectedMonth)) {
        monthlyTotal += t.amount;
        final previous = byCategory[t.categoryId];
        byCategory[t.categoryId] = (
          name: t.categoryName,
          amount: (previous?.amount ?? 0) + t.amount,
        );
      }
    }

    double percentOf(double amount) =>
        monthlyTotal == 0 ? 0 : amount / monthlyTotal * 100;

    final entries = byCategory.entries.toList()
      ..sort((a, b) => b.value.amount.compareTo(a.value.amount));

    final visibleCount =
        entries.length <= maxSlices ? entries.length : maxSlices - 1;

    final spending = <CategorySpending>[
      for (final e in entries.take(visibleCount))
        CategorySpending(
          categoryId: e.key,
          name: e.value.name,
          amount: e.value.amount,
          percent: percentOf(e.value.amount),
        ),
    ];

    final restAmount = entries
        .skip(visibleCount)
        .fold<double>(0, (sum, e) => sum + e.value.amount);
    if (restAmount > 0) {
      spending.add(CategorySpending(
        categoryId: othersId,
        name: 'Other',
        amount: restAmount,
        percent: percentOf(restAmount),
      ));
    }

    final balance = income - expenses;
    final changePercent = balanceBeforeThisMonth == 0
        ? null
        : (balance - balanceBeforeThisMonth) / balanceBeforeThisMonth.abs() * 100;

    return DashboardSummary(
      totalIncome: income,
      totalExpenses: expenses,
      monthlySpending: monthlyTotal,
      spendingByCategory: spending,
      balanceChangePercent: changePercent,
    );
  }

  static bool _isSameMonth(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month;

  @override
  List<Object?> get props => [
        totalIncome,
        totalExpenses,
        monthlySpending,
        spendingByCategory,
        balanceChangePercent,
      ];
}