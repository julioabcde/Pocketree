import 'package:pocketree/features/splitbill/domain/entities/settlement_summary.dart';

class SettlementSummaryModel {
  final double totalDebtAmount;
  final double remainingDebtAmount;
  final int settledDebtCount;
  final int totalDebtCount;
  final int settlementCount;
  final double settledAmount;

  SettlementSummaryModel({
    required this.totalDebtAmount,
    required this.remainingDebtAmount,
    required this.settledDebtCount,
    required this.totalDebtCount,
    required this.settlementCount,
    required this.settledAmount,
  });

  factory SettlementSummaryModel.fromJson(Map<String, dynamic> json) {
    return SettlementSummaryModel(
      totalDebtAmount:
          double.parse(json['total_debt_amount'] as String),
      remainingDebtAmount:
          double.parse(json['remaining_debt_amount'] as String),
      settledDebtCount: json['settled_debt_count'] as int,
      totalDebtCount: json['total_debt_count'] as int,
      settlementCount: json['settlement_count'] as int,
      settledAmount: double.parse(json['settled_amount'] as String),
    );
  }

  SettlementSummary toEntity() => SettlementSummary(
        totalDebtAmount: totalDebtAmount,
        remainingDebtAmount: remainingDebtAmount,
        settledDebtCount: settledDebtCount,
        totalDebtCount: totalDebtCount,
        settlementCount: settlementCount,
        settledAmount: settledAmount,
      );
}