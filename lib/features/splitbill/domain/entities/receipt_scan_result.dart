import 'package:equatable/equatable.dart';

class ReceiptScanItem extends Equatable {
  final String name;
  final int qty;
  final double unitPrice;

  const ReceiptScanItem({
    required this.name,
    required this.qty,
    required this.unitPrice,
  });

  @override
  List<Object?> get props => [name, qty, unitPrice];
}

class ReceiptScanCharge extends Equatable {
  final String type;
  final String name;
  final double amount;

  const ReceiptScanCharge({
    required this.type,
    required this.name,
    required this.amount,
  });

  @override
  List<Object?> get props => [type, name, amount];
}

class ReceiptScanResult extends Equatable {
  final List<ReceiptScanItem> items;
  final List<ReceiptScanCharge> charges;

  const ReceiptScanResult({required this.items, required this.charges});

  bool get isEmpty => items.isEmpty && charges.isEmpty;

  @override
  List<Object?> get props => [items, charges];
}
