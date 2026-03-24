enum TransactionType {
  income('income'),
  expense('expense');

  final String value;
  const TransactionType(this.value);

  static TransactionType fromString(String value) {
    return TransactionType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => throw ArgumentError('Unknown TransactionType: $value'),
    );
  }
}