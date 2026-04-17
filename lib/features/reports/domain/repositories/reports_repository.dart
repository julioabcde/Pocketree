import 'package:dartz/dartz.dart';
import 'package:pocketree/core/error/failures.dart';
import 'package:pocketree/features/reports/domain/entities/account_breakdown.dart';
import 'package:pocketree/features/reports/domain/entities/cashflow_trend_item.dart';
import 'package:pocketree/features/reports/domain/entities/category_breakdown.dart';
import 'package:pocketree/features/reports/domain/entities/period_comparison.dart';
import 'package:pocketree/features/reports/domain/entities/report_overview.dart';
import 'package:pocketree/features/reports/domain/entities/top_transaction.dart';

abstract class ReportsRepository {
  Future<Either<Failure, ReportOverview>> getOverview({
    required DateTime startDate,
    required DateTime endDate,
    int? accountId,
  });

  Future<Either<Failure, List<CashflowTrendItem>>> getCashflowTrend({
    required DateTime startDate,
    required DateTime endDate,
    int? accountId,
    String groupBy = 'day',
  });

  Future<Either<Failure, CategoryBreakdown>> getCategoryBreakdown({
    required DateTime startDate,
    required DateTime endDate,
    int? accountId,
    String type = 'expense',
    int topN = 10,
  });

  Future<Either<Failure, AccountBreakdown>> getAccountBreakdown({
    required DateTime startDate,
    required DateTime endDate,
    int? accountId,
    String type = 'expense',
  });

  Future<Either<Failure, List<TopTransaction>>> getTopTransactions({
    required DateTime startDate,
    required DateTime endDate,
    int? accountId,
    String type = 'expense',
    int limit = 5,
  });

  Future<Either<Failure, PeriodComparison>> getPeriodComparison({
    required DateTime startDate,
    required DateTime endDate,
    int? accountId,
  });
}
