import 'package:pocketree/features/splitbill/domain/entities/split_bill_item.dart';

class SplitBillItemModel {
  final int id;
  final String name;
  final double price;
  final int quantity;
  final double subtotal;
  final DateTime createdAt;

  SplitBillItemModel({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    required this.subtotal,
    required this.createdAt,
  });

  factory SplitBillItemModel.fromJson(Map<String, dynamic> json) {
    return SplitBillItemModel(
      id: json['id'] as int,
      name: json['name'] as String,
      price: double.parse(json['price'] as String),
      quantity: json['quantity'] as int,
      subtotal: double.parse(json['subtotal'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  SplitBillItem toEntity() => SplitBillItem(
        id: id,
        name: name,
        price: price,
        quantity: quantity,
        subtotal: subtotal,
        createdAt: createdAt,
      );
}