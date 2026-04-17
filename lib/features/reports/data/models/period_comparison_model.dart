import 'package:pocketree/features/reports/data/models/report_overview_model.dart';
import 'package:pocketree/features/reports/domain/entities/period_comparison.dart';
import 'package:pocketree/features/reports/domain/entities/report_overview.dart';

class PeriodDetailModel {
  final double income;
  final double expense;
  final double net;
  final int transactionCount;

  PeriodDetailModel({
    required this.income,
    required this.expense,
    required this.net,
    required this.transactionCount,
  });

  factory PeriodDetailModel.fromJson(Map<String, dynamic> json) {
    return PeriodDetailModel(
      income: double.parse(json['income'] as String),
      expense: double.parse(json['expense'] as String),
      net: double.parse(json['net'] as String),
      transactionCount: json['transaction_count'] as int,
    );
  }

  PeriodDetail toEntity() => PeriodDetail(
        income: income,
        expense: expense,
        net: net,
        transactionCount: transactionCount,
      );
}

class ComparisonDeltaModel {
  final DeltaItemModel income;
  final DeltaItemModel expense;
  final DeltaItemModel net;
  final DeltaItemModel transactionCount;

  ComparisonDeltaModel({
    required this.income,
    required this.expense,
    required this.net,
    required this.transactionCount,
  });

  factory ComparisonDeltaModel.fromJson(Map<String, dynamic> json) {
    return ComparisonDeltaModel(
      income: DeltaItemModel.fromJson(json['income'] as Map<String, dynamic>),
      expense: DeltaItemModel.fromJson(json['expense'] as Map<String, dynamic>),
      net: DeltaItemModel.fromJson(json['net'] as Map<String, dynamic>),
      transactionCount: _parseDeltaItemWithIntAmount(
          json['transaction_count'] as Map<String, dynamic>),
    );
  }

  static DeltaItemModel _parseDeltaItemWithIntAmount(
      Map<String, dynamic> json) {
    final amount = json['amount'];
    return DeltaItemModel(
      amount: amount is int ? amount.toDouble() : double.parse(amount as String),
      percent: json['percent'] != null
          ? double.parse(json['percent'] as String)
          : null,
    );
  }

  ComparisonDelta toEntity() => ComparisonDelta(
        income: DeltaItem(amount: income.amount, percent: income.percent),
        expense: DeltaItem(amount: expense.amount, percent: expense.percent),
        net: DeltaItem(amount: net.amount, percent: net.percent),
        transactionCount: DeltaItem(
          amount: transactionCount.amount,
          percent: transactionCount.percent,
        ),
      );
}

class PeriodComparisonModel {
  final PeriodDetailModel currentPeriod;
  final PeriodDetailModel previousPeriod;
  final ComparisonDeltaModel delta;

  PeriodComparisonModel({
    required this.currentPeriod,
    required this.previousPeriod,
    required this.delta,
  });

  factory PeriodComparisonModel.fromJson(Map<String, dynamic> json) {
    return PeriodComparisonModel(
      currentPeriod: PeriodDetailModel.fromJson(
          json['current_period'] as Map<String, dynamic>),
      previousPeriod: PeriodDetailModel.fromJson(
          json['previous_period'] as Map<String, dynamic>),
      delta: ComparisonDeltaModel.fromJson(
          json['delta'] as Map<String, dynamic>),
    );
  }

  PeriodComparison toEntity() => PeriodComparison(
        currentPeriod: currentPeriod.toEntity(),
        previousPeriod: previousPeriod.toEntity(),
        delta: delta.toEntity(),
      );
}
