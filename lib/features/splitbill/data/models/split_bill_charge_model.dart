import 'package:pocketree/features/splitbill/domain/entities/split_bill_charge.dart';

class SplitBillChargeModel {
  final int id;
  final String type;
  final String name;
  final double amount;
  final DateTime createdAt;

  SplitBillChargeModel({
    required this.id,
    required this.type,
    required this.name,
    required this.amount,
    required this.createdAt,
  });

  factory SplitBillChargeModel.fromJson(Map<String, dynamic> json) {
    return SplitBillChargeModel(
      id: json['id'] as int,
      type: json['type'] as String,
      name: json['name'] as String,
      amount: double.parse(json['amount'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  SplitBillCharge toEntity() => SplitBillCharge(
        id: id,
        type: type,
        name: name,
        amount: amount,
        createdAt: createdAt,
      );
}