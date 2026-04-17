import 'package:equatable/equatable.dart';
import 'package:pocketree/features/reports/domain/entities/reports_data.dart';

abstract class ReportsState extends Equatable {
  const ReportsState();

  @override
  List<Object?> get props => [];
}

class ReportsInitial extends ReportsState {
  const ReportsInitial();
}

class ReportsLoading extends ReportsState {
  const ReportsLoading();
}

class ReportsLoaded extends ReportsState {
  final ReportsData data;
  final DateTime startDate;
  final DateTime endDate;
  final int? accountId;
  final String groupBy;
  final String type;
  final int topN;
  final int limit;

  const ReportsLoaded({
    required this.data,
    required this.startDate,
    required this.endDate,
    this.accountId,
    required this.groupBy,
    required this.type,
    required this.topN,
    required this.limit,
  });

  @override
  List<Object?> get props =>
      [data, startDate, endDate, accountId, groupBy, type, topN, limit];
}

class ReportsError extends ReportsState {
  final String message;

  const ReportsError(this.message);

  @override
  List<Object?> get props => [message];
}
