import 'package:pocketree/features/splitbill/domain/entities/receipt_scan_result.dart';

class ReceiptScanItemModel {
  final String name;
  final int qty;
  final double unitPrice;

  ReceiptScanItemModel({
    required this.name,
    required this.qty,
    required this.unitPrice,
  });

  factory ReceiptScanItemModel.fromJson(Map<String, dynamic> json) {
    return ReceiptScanItemModel(
      name: json['name'] as String,
      qty: (json['qty'] as num).toInt(),
      unitPrice: _parseNumber(json['unit_price']),
    );
  }

  ReceiptScanItem toEntity() =>
      ReceiptScanItem(name: name, qty: qty, unitPrice: unitPrice);
}

class ReceiptScanChargeModel {
  final String type;
  final String name;
  final double amount;

  ReceiptScanChargeModel({
    required this.type,
    required this.name,
    required this.amount,
  });

  factory ReceiptScanChargeModel.fromJson(Map<String, dynamic> json) {
    return ReceiptScanChargeModel(
      type: json['type'] as String,
      name: json['name'] as String,
      amount: _parseNumber(json['amount']),
    );
  }

  ReceiptScanCharge toEntity() =>
      ReceiptScanCharge(type: type, name: name, amount: amount);
}

class ReceiptScanResultModel {
  final List<ReceiptScanItemModel> items;
  final List<ReceiptScanChargeModel> charges;

  ReceiptScanResultModel({required this.items, required this.charges});

  factory ReceiptScanResultModel.fromJson(Map<String, dynamic> json) {
    final items = (json['items'] as List<dynamic>? ?? [])
        .map((e) => ReceiptScanItemModel.fromJson(e as Map<String, dynamic>))
        .toList();
    final charges = (json['charges'] as List<dynamic>? ?? [])
        .map((e) => ReceiptScanChargeModel.fromJson(e as Map<String, dynamic>))
        .toList();
    return ReceiptScanResultModel(items: items, charges: charges);
  }

  ReceiptScanResult toEntity() => ReceiptScanResult(
    items: items.map((m) => m.toEntity()).toList(),
    charges: charges.map((m) => m.toEntity()).toList(),
  );
}

double _parseNumber(dynamic value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.parse(value);
  throw FormatException('Expected number or numeric string, got $value');
}
