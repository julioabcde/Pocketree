import 'package:equatable/equatable.dart';
import 'package:pocketree/features/transactions/domain/entities/transaction_type.dart';

class Transaction extends Equatable {
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

  const Transaction({
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

  bool get isTransfer => transferId != null;

  bool get isIncome => type == TransactionType.income;

  bool get isExpense => type == TransactionType.expense;

  @override
  List<Object?> get props => [
    id,
    accountId,
    categoryId,
    type,
    amount,
    date,
    note,
    transferId,
    createdAt,
    updatedAt,
  ];
}