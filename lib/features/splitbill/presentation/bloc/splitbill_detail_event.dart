import 'dart:async';

import 'package:equatable/equatable.dart';

abstract class SplitBillDetailEvent extends Equatable {
  const SplitBillDetailEvent();

  @override
  List<Object?> get props => [];
}

class SplitBillDetailRequested extends SplitBillDetailEvent {
  final int billId;
  const SplitBillDetailRequested({required this.billId});

  @override
  List<Object?> get props => [billId];
}

class SplitBillDetailRefreshed extends SplitBillDetailEvent {
  final int billId;
  final Completer<void> completer;

  SplitBillDetailRefreshed({
    required this.billId,
    Completer<void>? completer,
  }) : completer = completer ?? Completer<void>();

  @override
  List<Object?> get props => [billId];
}

class SplitBillCalculateRequested extends SplitBillDetailEvent {
  final List<({String name, bool isPayer, double paidAmount, int? userId})> participants;
  final List<({
    int participantIndex,
    List<int>? itemIds,
    double? customAmount,
    Map<String, int>? sharePortions,
  })>? shares;
  final int? accountId;

  const SplitBillCalculateRequested({
    required this.participants,
    this.shares,
    this.accountId,
  });

  @override
  List<Object?> get props => [participants, shares, accountId];
}

class SplitBillSettleRequested extends SplitBillDetailEvent {
  final int billId;
  final int debtId;
  final double amount;
  final int? accountId;

  const SplitBillSettleRequested({
    required this.billId,
    required this.debtId,
    required this.amount,
    this.accountId,
  });

  @override
  List<Object?> get props => [billId, debtId, amount, accountId];
}

class SplitBillDetailDeleteRequested extends SplitBillDetailEvent {
  final int billId;
  const SplitBillDetailDeleteRequested({required this.billId});

  @override
  List<Object?> get props => [billId];
}