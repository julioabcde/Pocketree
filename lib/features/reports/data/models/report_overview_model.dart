import 'package:pocketree/features/reports/domain/entities/report_overview.dart';

class DeltaItemModel {
  final double amount;
  final double? percent;

  DeltaItemModel({required this.amount, this.percent});

  factory DeltaItemModel.fromJson(Map<String, dynamic> json) {
    return DeltaItemModel(
      amount: double.parse(json['amount'] as String),
      percent: json['percent'] != null
          ? double.parse(json['percent'] as String)
          : null,
    );
  }

  DeltaItem toEntity() => DeltaItem(amount: amount, percent: percent);
}

class PreviousPeriodModel {
  final double income;
  final double expense;
  final double net;

  PreviousPeriodModel({
    required this.income,
    required this.expense,
    required this.net,
  });

  factory PreviousPeriodModel.fromJson(Map<String, dynamic> json) {
    return PreviousPeriodModel(
      income: double.parse(json['income'] as String),
      expense: double.parse(json['expense'] as String),
      net: double.parse(json['net'] as String),
    );
  }

  PreviousPeriod toEntity() => PreviousPeriod(
        income: income,
        expense: expense,
        net: net,
      );
}

class OverviewDeltaModel {
  final DeltaItemModel income;
  final DeltaItemModel expense;
  final DeltaItemModel net;

  OverviewDeltaModel({
    required this.income,
    required this.expense,
    required this.net,
  });

  factory OverviewDeltaModel.fromJson(Map<String, dynamic> json) {
    return OverviewDeltaModel(
      income: DeltaItemModel.fromJson(json['income'] as Map<String, dynamic>),
      expense: DeltaItemModel.fromJson(json['expense'] as Map<String, dynamic>),
      net: DeltaItemModel.fromJson(json['net'] as Map<String, dynamic>),
    );
  }

  OverviewDelta toEntity() => OverviewDelta(
        income: income.toEntity(),
        expense: expense.toEntity(),
        net: net.toEntity(),
      );
}

class ReportOverviewModel {
  final double totalIncome;
  final double totalExpense;
  final double net;
  final int transactionCount;
  final double? savingsRate;
  final PreviousPeriodModel previousPeriod;
  final OverviewDeltaModel delta;

  ReportOverviewModel({
    required this.totalIncome,
    required this.totalExpense,
    required this.net,
    required this.transactionCount,
    this.savingsRate,
    required this.previousPeriod,
    required this.delta,
  });

  factory ReportOverviewModel.fromJson(Map<String, dynamic> json) {
    return ReportOverviewModel(
      totalIncome: double.parse(json['total_income'] as String),
      totalExpense: double.parse(json['total_expense'] as String),
      net: double.parse(json['net'] as String),
      transactionCount: json['transaction_count'] as int,
      savingsRate: json['savings_rate'] != null
          ? double.parse(json['savings_rate'] as String)
          : null,
      previousPeriod: PreviousPeriodModel.fromJson(
          json['previous_period'] as Map<String, dynamic>),
      delta: OverviewDeltaModel.fromJson(
          json['delta'] as Map<String, dynamic>),
    );
  }

  ReportOverview toEntity() => ReportOverview(
        totalIncome: totalIncome,
        totalExpense: totalExpense,
        net: net,
        transactionCount: transactionCount,
        savingsRate: savingsRate,
        previousPeriod: previousPeriod.toEntity(),
        delta: delta.toEntity(),
      );
}
