import 'dart:async';

import 'package:equatable/equatable.dart';

abstract class CalendarEvent extends Equatable {
  const CalendarEvent();

  @override
  List<Object?> get props => [];
}

class CalendarMonthRequested extends CalendarEvent {
  final DateTime month;

  const CalendarMonthRequested({required this.month});

  @override
  List<Object?> get props => [month];
}

class CalendarDaySelected extends CalendarEvent {
  final DateTime date;

  const CalendarDaySelected({required this.date});

  @override
  List<Object?> get props => [date];
}

class CalendarDataRefreshed extends CalendarEvent {
  final Completer<void> completer;

  CalendarDataRefreshed({Completer<void>? completer})
      : completer = completer ?? Completer<void>();

  @override
  List<Object?> get props => [];
}