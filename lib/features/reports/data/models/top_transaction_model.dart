import 'package:pocketree/features/reports/domain/entities/top_transaction.dart';

class TopTransactionModel {
  final int transactionId;
  final DateTime date;
  final double amount;
  final String account;
  final String category;
  final String? note;

  TopTransactionModel({
    required this.transactionId,
    required this.date,
    required this.amount,
    required this.account,
    required this.category,
    this.note,
  });

  factory TopTransactionModel.fromJson(Map<String, dynamic> json) {
    return TopTransactionModel(
      transactionId: json['transaction_id'] as int,
      date: DateTime.parse(json['date'] as String),
      amount: double.parse(json['amount'] as String),
      account: json['account'] as String,
      category: (json['category'] as String?) ?? 'Uncategorized',
      note: json['note'] as String?,
    );
  }

  TopTransaction toEntity() => TopTransaction(
        transactionId: transactionId,
        date: date,
        amount: amount,
        account: account,
        category: category,
        note: note,
      );
}
