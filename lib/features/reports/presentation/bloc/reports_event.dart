import 'dart:async';

import 'package:equatable/equatable.dart';

abstract class ReportsEvent extends Equatable {
  const ReportsEvent();

  @override
  List<Object?> get props => [];
}

class ReportsDataRefreshed extends ReportsEvent {
  final Completer<void> completer;

  ReportsDataRefreshed({Completer<void>? completer})
      : completer = completer ?? Completer<void>();

  @override
  List<Object?> get props => [];
}

class ReportsDataRequested extends ReportsEvent {
  final DateTime startDate;
  final DateTime endDate;
  final int? accountId;
  final String groupBy;
  final String type;
  final int topN;
  final int limit;

  const ReportsDataRequested({
    required this.startDate,
    required this.endDate,
    this.accountId,
    this.groupBy = 'day',
    this.type = 'expense',
    this.topN = 10,
    this.limit = 5,
  });

  @override
  List<Object?> get props =>
      [startDate, endDate, accountId, groupBy, type, topN, limit];
}

class ReportsGroupByChanged extends ReportsEvent {
  final String groupBy;

  const ReportsGroupByChanged(this.groupBy);

  @override
  List<Object?> get props => [groupBy];
}

class ReportsTypeChanged extends ReportsEvent {
  final String type;

  const ReportsTypeChanged(this.type);

  @override
  List<Object?> get props => [type];
}
