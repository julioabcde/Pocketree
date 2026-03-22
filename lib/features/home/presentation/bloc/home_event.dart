import 'dart:async';

import 'package:equatable/equatable.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class HomeDataRequested extends HomeEvent {
  const HomeDataRequested();
}

class HomeDataRefreshed extends HomeEvent {
  final Completer<void> completer;

  HomeDataRefreshed({Completer<void>? completer})
    : completer = completer ?? Completer<void>();

  @override
  List<Object?> get props => [];
}
