import 'package:equatable/equatable.dart';

class CashflowTrendItem extends Equatable {
  final String period;
  final DateTime startDate;
  final DateTime endDate;
  final double income;
  final double expense;
  final double net;
  final double cumulativeNet;

  const CashflowTrendItem({
    required this.period,
    required this.startDate,
    required this.endDate,
    required this.income,
    required this.expense,
    required this.net,
    required this.cumulativeNet,
  });

  @override
  List<Object?> get props => [
        period,
        startDate,
        endDate,
        income,
        expense,
        net,
        cumulativeNet,
      ];
}
