import 'package:equatable/equatable.dart';
import 'package:fintrack/features/transactions/model/transaction_type.dart';

class TransactionModel extends Equatable {
  const TransactionModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.amount,
    required this.categoryId,
    required this.categoryName,
    required this.date,
    required this.createdAt,
    required this.updatedAt,
    this.note = '',
  });

  final String id;
  final String userId;
  final TransactionType type;
  final double amount;
  final String categoryId;
  final String categoryName;
  final DateTime date;
  final String note;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isIncome => type == TransactionType.income;
  bool get isExpense => type == TransactionType.expense;
  double get signedAmount => isIncome ? amount : -amount;

  String get title => note.trim().isNotEmpty ? note.trim() : categoryName;

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    final date = map['date'] as DateTime? ?? DateTime.now();
    return TransactionModel(
      id: map['id'] as String,
      userId: map['userId'] as String? ?? '',
      type: TransactionType.fromValue(map['type'] as String?),
      amount: (map['amount'] as num?)?.toDouble() ?? 0,
      categoryId: map['categoryId'] as String? ?? '',
      categoryName: map['categoryName'] as String? ?? '',
      date: date,
      note: map['note'] as String? ?? '',
      createdAt: map['createdAt'] as DateTime? ?? date,
      updatedAt: map['updatedAt'] as DateTime? ?? date,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'type': type.value,
      'amount': amount,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'date': date,
      'note': note,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        type,
        amount,
        categoryId,
        categoryName,
        date,
        note,
        createdAt,
        updatedAt,
      ];
}