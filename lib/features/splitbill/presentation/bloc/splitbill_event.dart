import 'dart:async';

import 'package:equatable/equatable.dart';

abstract class SplitBillEvent extends Equatable {
  const SplitBillEvent();

  @override
  List<Object?> get props => [];
}

class SplitBillDataRefreshed extends SplitBillEvent {
  final Completer<void> completer;

  SplitBillDataRefreshed({Completer<void>? completer})
      : completer = completer ?? Completer<void>();

  @override
  List<Object?> get props => [];
}

class SplitBillCreateRequested extends SplitBillEvent {
  final String title;
  final DateTime date;
  final List<({String name, double price, int quantity})> items;
  final List<({String type, String name, double amount})> charges;
  final String? note;

  const SplitBillCreateRequested({
    required this.title,
    required this.date,
    required this.items,
    this.charges = const [],
    this.note,
  });

  @override
  List<Object?> get props => [title, date, items, charges, note];
}

class SplitBillDeleteRequested extends SplitBillEvent {
  final int billId;
  const SplitBillDeleteRequested({required this.billId});

  @override
  List<Object?> get props => [billId];
}

class SplitBillSummaryRequested extends SplitBillEvent {
  const SplitBillSummaryRequested();
}
