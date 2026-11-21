enum TransactionType {
  income,
  expense;

  String get value => name;

  static TransactionType fromValue(String? value) {
    return TransactionType.values.firstWhere(
      (type) => type.name == value,
      orElse: () => TransactionType.expense,
    );
  }
}