import 'package:equatable/equatable.dart';

class SettlementSummary extends Equatable {
  final double totalDebtAmount;
  final double remainingDebtAmount;
  final int settledDebtCount;
  final int totalDebtCount;
  final int settlementCount;
  final double settledAmount;

  const SettlementSummary({
    required this.totalDebtAmount,
    required this.remainingDebtAmount,
    required this.settledDebtCount,
    required this.totalDebtCount,
    required this.settlementCount,
    required this.settledAmount,
  });

  double get nominalProgress =>
      totalDebtAmount > 0 ? settledAmount / totalDebtAmount : 0.0;

  @override
  List<Object?> get props => [
        totalDebtAmount,
        remainingDebtAmount,
        settledDebtCount,
        totalDebtCount,
        settlementCount,
        settledAmount,
      ];
}