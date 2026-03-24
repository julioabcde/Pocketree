enum CategoryType {
  income('income'),
  expense('expense');

  final String value;
  const CategoryType(this.value);

  static CategoryType fromString(String value) {
    return CategoryType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => throw ArgumentError('Unknown CategoryType: $value'),
    );
  }
}