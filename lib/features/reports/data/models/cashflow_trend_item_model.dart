import 'package:pocketree/features/reports/domain/entities/cashflow_trend_item.dart';

class CashflowTrendItemModel {
  final String period;
  final DateTime startDate;
  final DateTime endDate;
  final double income;
  final double expense;
  final double net;
  final double cumulativeNet;

  CashflowTrendItemModel({
    required this.period,
    required this.startDate,
    required this.endDate,
    required this.income,
    required this.expense,
    required this.net,
    required this.cumulativeNet,
  });

  factory CashflowTrendItemModel.fromJson(Map<String, dynamic> json) {
    return CashflowTrendItemModel(
      period: json['period'] as String,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      income: double.parse(json['income'] as String),
      expense: double.parse(json['expense'] as String),
      net: double.parse(json['net'] as String),
      cumulativeNet: double.parse(json['cumulative_net'] as String),
    );
  }

  CashflowTrendItem toEntity() => CashflowTrendItem(
        period: period,
        startDate: startDate,
        endDate: endDate,
        income: income,
        expense: expense,
        net: net,
        cumulativeNet: cumulativeNet,
      );
}
