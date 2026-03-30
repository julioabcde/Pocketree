import 'package:pocketree/features/transactions/domain/entities/daily_summary.dart';

class DailySummaryModel {
  final DateTime date;
  final double income;
  final double expense;
  final double net;

  DailySummaryModel({
    required this.date,
    required this.income,
    required this.expense,
    required this.net,
  });

  factory DailySummaryModel.fromJson(Map<String, dynamic> json) {
    return DailySummaryModel(
      date: DateTime.parse(json['date'] as String),
      income: double.parse(json['income'] as String),
      expense: double.parse(json['expense'] as String),
      net: double.parse(json['net'] as String),
    );
  }

  DailySummary toEntity() {
    return DailySummary(
      date: date,
      income: income,
      expense: expense,
      net: net,
    );
  }
}