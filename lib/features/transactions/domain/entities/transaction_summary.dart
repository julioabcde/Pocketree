import 'package:equatable/equatable.dart';

class TransactionSummary extends Equatable {
  final double totalIncome;
  final double totalExpense;
  final double net;
  final int transactionCount;

  const TransactionSummary({
    required this.totalIncome,
    required this.totalExpense,
    required this.net,
    required this.transactionCount,
  });

  @override
  List<Object?> get props => [
    totalIncome,
    totalExpense,
    net,
    transactionCount,
  ];
}