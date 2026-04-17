class ChargeEntry {
  final String id;
  final String type;
  final String name;
  final double value;
  final bool isPercentage;

  const ChargeEntry({
    required this.id,
    required this.type,
    required this.name,
    required this.value,
    required this.isPercentage,
  });

  double computedAmount(double subtotal) =>
      isPercentage ? subtotal * (value / 100) : value;

  ChargeEntry copyWith({
    String? type,
    String? name,
    double? value,
    bool? isPercentage,
  }) {
    return ChargeEntry(
      id: id,
      type: type ?? this.type,
      name: name ?? this.name,
      value: value ?? this.value,
      isPercentage: isPercentage ?? this.isPercentage,
    );
  }
}
