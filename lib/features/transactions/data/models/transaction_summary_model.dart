import 'package:pocketree/features/transactions/domain/entities/transaction_summary.dart';

class TransactionSummaryModel {
  final double totalIncome;
  final double totalExpense;
  final double net;
  final int transactionCount;

  TransactionSummaryModel({
    required this.totalIncome,
    required this.totalExpense,
    required this.net,
    required this.transactionCount,
  });

  factory TransactionSummaryModel.fromJson(Map<String, dynamic> json) {
    return TransactionSummaryModel(
      totalIncome: double.parse(json['total_income'] as String),
      totalExpense: double.parse(json['total_expense'] as String),
      net: double.parse(json['net'] as String),
      transactionCount: json['transaction_count'] as int,
    );
  }

  TransactionSummary toEntity() {
    return TransactionSummary(
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      net: net,
      transactionCount: transactionCount,
    );
  }
}
