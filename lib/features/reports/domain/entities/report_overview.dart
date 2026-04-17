import 'package:equatable/equatable.dart';

class DeltaItem extends Equatable {
  final double amount;
  final double? percent;

  const DeltaItem({required this.amount, this.percent});

  @override
  List<Object?> get props => [amount, percent];
}

class PreviousPeriod extends Equatable {
  final double income;
  final double expense;
  final double net;

  const PreviousPeriod({
    required this.income,
    required this.expense,
    required this.net,
  });

  @override
  List<Object?> get props => [income, expense, net];
}

class OverviewDelta extends Equatable {
  final DeltaItem income;
  final DeltaItem expense;
  final DeltaItem net;

  const OverviewDelta({
    required this.income,
    required this.expense,
    required this.net,
  });

  @override
  List<Object?> get props => [income, expense, net];
}

class ReportOverview extends Equatable {
  final double totalIncome;
  final double totalExpense;
  final double net;
  final int transactionCount;
  final double? savingsRate;
  final PreviousPeriod previousPeriod;
  final OverviewDelta delta;

  const ReportOverview({
    required this.totalIncome,
    required this.totalExpense,
    required this.net,
    required this.transactionCount,
    this.savingsRate,
    required this.previousPeriod,
    required this.delta,
  });

  @override
  List<Object?> get props => [
        totalIncome,
        totalExpense,
        net,
        transactionCount,
        savingsRate,
        previousPeriod,
        delta,
      ];
}
