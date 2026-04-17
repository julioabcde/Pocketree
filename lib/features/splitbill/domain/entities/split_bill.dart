import 'package:equatable/equatable.dart';

class SplitBill extends Equatable {
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

  const SplitBill({
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

  @override
  List<Object?> get props => [
        id, title, subtotal, totalAmount,
        date, note, receiptImageUrl, createdAt, updatedAt, transactionId,
      ];
}