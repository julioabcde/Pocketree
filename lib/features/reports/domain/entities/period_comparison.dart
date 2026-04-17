import 'package:equatable/equatable.dart';
import 'package:pocketree/features/reports/domain/entities/report_overview.dart';

class PeriodDetail extends Equatable {
  final double income;
  final double expense;
  final double net;
  final int transactionCount;

  const PeriodDetail({
    required this.income,
    required this.expense,
    required this.net,
    required this.transactionCount,
  });

  @override
  List<Object?> get props => [income, expense, net, transactionCount];
}

class ComparisonDelta extends Equatable {
  final DeltaItem income;
  final DeltaItem expense;
  final DeltaItem net;
  final DeltaItem transactionCount;

  const ComparisonDelta({
    required this.income,
    required this.expense,
    required this.net,
    required this.transactionCount,
  });

  @override
  List<Object?> get props => [income, expense, net, transactionCount];
}

class PeriodComparison extends Equatable {
  final PeriodDetail currentPeriod;
  final PeriodDetail previousPeriod;
  final ComparisonDelta delta;

  const PeriodComparison({
    required this.currentPeriod,
    required this.previousPeriod,
    required this.delta,
  });

  @override
  List<Object?> get props => [currentPeriod, previousPeriod, delta];
}
