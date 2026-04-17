class ItemEntry {
  final String id;
  final String name;
  final double price;
  final int quantity;
  final bool isFromOCR;
  final String? scanSource;

  const ItemEntry({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    this.isFromOCR = false,
    this.scanSource,
  });

  double get subtotal => price * quantity;
  bool get isValid => name.trim().isNotEmpty && price > 0;

  ItemEntry copyWith({
    String? name,
    double? price,
    int? quantity,
    bool? isFromOCR,
    String? scanSource,
  }) {
    return ItemEntry(
      id: id,
      name: name ?? this.name,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      isFromOCR: isFromOCR ?? this.isFromOCR,
      scanSource: scanSource ?? this.scanSource,
    );
  }
}
