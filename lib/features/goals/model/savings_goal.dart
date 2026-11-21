import 'package:equatable/equatable.dart';

class SavingsGoal extends Equatable {
  const SavingsGoal({
    required this.id,
    required this.userId,
    required this.name,
    required this.targetAmount,
    required this.savedAmount,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String userId;
  final String name;
  final double targetAmount;
  final double savedAmount;
  final DateTime createdAt;
  final DateTime updatedAt;

  double get progress => targetAmount <= 0
      ? 0
      : (savedAmount / targetAmount).clamp(0.0, 1.0).toDouble();

  int get percent => (progress * 100).round();

  factory SavingsGoal.fromMap(Map<String, dynamic> map) {
    final createdAt = map['createdAt'] as DateTime? ?? DateTime.now();
    return SavingsGoal(
      id: map['id'] as String,
      userId: map['userId'] as String? ?? '',
      name: map['name'] as String? ?? '',
      targetAmount: (map['targetAmount'] as num?)?.toDouble() ?? 0,
      savedAmount: (map['savedAmount'] as num?)?.toDouble() ?? 0,
      createdAt: createdAt,
      updatedAt: map['updatedAt'] as DateTime? ?? createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'targetAmount': targetAmount,
      'savedAmount': savedAmount,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  @override
  List<Object?> get props =>
      [id, userId, name, targetAmount, savedAmount, createdAt, updatedAt];
}