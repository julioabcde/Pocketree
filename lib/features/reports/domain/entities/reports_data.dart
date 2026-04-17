import 'package:equatable/equatable.dart';
import 'package:pocketree/features/reports/domain/entities/account_breakdown.dart';
import 'package:pocketree/features/reports/domain/entities/cashflow_trend_item.dart';
import 'package:pocketree/features/reports/domain/entities/category_breakdown.dart';
import 'package:pocketree/features/reports/domain/entities/period_comparison.dart';
import 'package:pocketree/features/reports/domain/entities/report_overview.dart';
import 'package:pocketree/features/reports/domain/entities/top_transaction.dart';

class ReportsData extends Equatable {
  final ReportOverview overview;
  final List<CashflowTrendItem> cashflowTrend;
  final CategoryBreakdown categoryBreakdown;
  final AccountBreakdown accountBreakdown;
  final List<TopTransaction> topTransactions;
  final PeriodComparison periodComparison;

  const ReportsData({
    required this.overview,
    required this.cashflowTrend,
    required this.categoryBreakdown,
    required this.accountBreakdown,
    required this.topTransactions,
    required this.periodComparison,
  });

  @override
  List<Object?> get props => [
        overview,
        cashflowTrend,
        categoryBreakdown,
        accountBreakdown,
        topTransactions,
        periodComparison,
      ];
}
