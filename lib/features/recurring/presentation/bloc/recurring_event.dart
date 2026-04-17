import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:pocketree/features/recurring/domain/entities/recurring_transaction.dart';
import 'package:pocketree/features/transactions/domain/entities/transaction_type.dart';

abstract class RecurringEvent extends Equatable {
  const RecurringEvent();
  @override
  List<Object?> get props => [];
}

class RecurringDataRequested extends RecurringEvent {
  const RecurringDataRequested();
}

class RecurringDataRefreshed extends RecurringEvent {
  final Completer<void> completer;

  RecurringDataRefreshed({Completer<void>? completer})
      : completer = completer ?? Completer<void>();

  @override
  List<Object?> get props => [];
}

class RecurringDeleteRequested extends RecurringEvent {
  final int recurringId;
  const RecurringDeleteRequested({required this.recurringId});
  @override
  List<Object?> get props => [recurringId];
}

class RecurringCreateRequested extends RecurringEvent {
  final int accountId;
  final TransactionType type;
  final double amount;
  final RecurringFrequency frequency;
  final DateTime startDate;
  final int? categoryId;
  final DateTime? endDate;
  final String timezone;
  final bool autoCreate;
  final String? note;

  const RecurringCreateRequested({
    required this.accountId,
    required this.type,
    required this.amount,
    required this.frequency,
    required this.startDate,
    this.categoryId,
    this.endDate,
    this.timezone = 'UTC',
    this.autoCreate = true,
    this.note,
  });

  @override
  List<Object?> get props => [
        accountId, type, amount, frequency, startDate,
        categoryId, endDate, timezone, autoCreate, note,
      ];
}

class RecurringExecuteRequested extends RecurringEvent {
  final int recurringId;
  const RecurringExecuteRequested({required this.recurringId});
  @override
  List<Object?> get props => [recurringId];
}

class RecurringActivateRequested extends RecurringEvent {
  final int recurringId;
  const RecurringActivateRequested({required this.recurringId});
  @override
  List<Object?> get props => [recurringId];
}

class RecurringUpdateRequested extends RecurringEvent {
  final int recurringId;
  final double? amount;
  final String? note;
  const RecurringUpdateRequested({
    required this.recurringId,
    this.amount,
    this.note,
  });
  @override
  List<Object?> get props => [recurringId, amount, note];
}