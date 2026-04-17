import 'package:pocketree/features/splitbill/domain/entities/split_bill.dart';

class SplitBillModel {
  final int id;
  final String title;
  final double subtotal;
  final double totalAmount;
  final DateTime date;
  final String? note;
  final String? receiptImageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int? transactionId;

  SplitBillModel({
    required this.id,
    required this.title,
    required this.subtotal,
    required this.totalAmount,
    required this.date,
    this.note,
    this.receiptImageUrl,
    required this.createdAt,
    required this.updatedAt,
    this.transactionId,
  });

  factory SplitBillModel.fromJson(Map<String, dynamic> json) {
    return SplitBillModel(
      id: json['id'] as int,
      title: json['title'] as String,
      subtotal: double.parse(json['subtotal'] as String),
      totalAmount: double.parse(json['total_amount'] as String),
      date: DateTime.parse(json['date'] as String),
      note: json['note'] as String?,
      receiptImageUrl: json['receipt_image_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      transactionId: json['transaction_id'] as int?,
    );
  }

  SplitBill toEntity() => SplitBill(
        id: id,
        title: title,
        subtotal: subtotal,
        totalAmount: totalAmount,
        date: date,
        note: note,
        receiptImageUrl: receiptImageUrl,
        createdAt: createdAt,
        updatedAt: updatedAt,
        transactionId: transactionId,
      );
}