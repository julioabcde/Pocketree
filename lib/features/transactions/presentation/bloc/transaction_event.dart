import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:pocketree/features/transactions/domain/entities/transaction_filter.dart';
import 'package:pocketree/features/transactions/domain/entities/transaction_type.dart';

abstract class TransactionEvent extends Equatable {
  const TransactionEvent();

  @override
  List<Object?> get props => [];
}

class TransactionDataRequested extends TransactionEvent {
  final TransactionFilter filter;

  const TransactionDataRequested({this.filter = const TransactionFilter()});

  @override
  List<Object?> get props => [filter];
}

class TransactionDataRefreshed extends TransactionEvent {
  final TransactionFilter? filter;
  final Completer<void> completer;

  TransactionDataRefreshed({this.filter, Completer<void>? completer})
      : completer = completer ?? Completer<void>();

  @override
  List<Object?> get props => [filter];
}

class TransactionNextPageRequested extends TransactionEvent {
  const TransactionNextPageRequested();
}

class TransactionCreateRequested extends TransactionEvent {
  final int accountId;
  final TransactionType type;
  final double amount;
  final DateTime date;
  final int? categoryId;
  final String? note;

  const TransactionCreateRequested({
    required this.accountId,
    required this.type,
    required this.amount,
    required this.date,
    this.categoryId,
    this.note,
  });

  @override
  List<Object?> get props => [accountId, type, amount, date, categoryId, note];
}

class TransactionUpdateRequested extends TransactionEvent {
  final int transactionId;
  final int? accountId;
  final int? categoryId;
  final double? amount;
  final DateTime? date;
  final String? note;

  const TransactionUpdateRequested({
    required this.transactionId,
    this.accountId,
    this.categoryId,
    this.amount,
    this.date,
    this.note,
  });

  @override
  List<Object?> get props => [
    transactionId,
    accountId,
    categoryId,
    amount,
    date,
    note,
  ];
}

class TransactionDeleteRequested extends TransactionEvent {
  final int transactionId;

  const TransactionDeleteRequested({required this.transactionId});

  @override
  List<Object?> get props => [transactionId];
}

class TransactionTransferRequested extends TransactionEvent {
  final int fromAccountId;
  final int toAccountId;
  final double amount;
  final DateTime date;
  final String? note;

  const TransactionTransferRequested({
    required this.fromAccountId,
    required this.toAccountId,
    required this.amount,
    required this.date,
    this.note,
  });

  @override
  List<Object?> get props => [fromAccountId, toAccountId, amount, date, note];
}
