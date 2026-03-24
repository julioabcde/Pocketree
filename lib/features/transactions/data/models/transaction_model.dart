import 'package:pocketree/features/transactions/domain/entities/transaction.dart';
import 'package:pocketree/features/transactions/domain/entities/transaction_type.dart';

class TransactionModel {
  final int id;
  final int accountId;
  final int? categoryId;
  final TransactionType type;
  final double amount;
  final DateTime date;
  final String? note;
  final int? transferId;
  final DateTime createdAt;
  final DateTime updatedAt;

  TransactionModel({
    required this.id,
    required this.accountId,
    required this.categoryId,
    required this.type,
    required this.amount,
    required this.date,
    required this.note,
    required this.transferId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as int,
      accountId: json['account_id'] as int,
      categoryId: json['category_id'] as int?,
      type: TransactionType.fromString(json['type'] as String),
      amount: double.parse(json['amount'] as String),
      date: DateTime.parse(json['date'] as String),
      note: json['note'] as String?,
      transferId: json['transfer_id'] as int?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Transaction toEntity() {
    return Transaction(
      id: id,
      accountId: accountId,
      categoryId: categoryId,
      type: type,
      amount: amount,
      date: date,
      note: note,
      transferId: transferId,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
