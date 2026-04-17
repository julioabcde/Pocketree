import 'package:dartz/dartz.dart';
import 'package:pocketree/core/error/error_mapper.dart';
import 'package:pocketree/core/error/failures.dart';
import 'package:pocketree/features/reports/data/datasources/reports_remote_datasource.dart';
import 'package:pocketree/features/reports/domain/entities/account_breakdown.dart';
import 'package:pocketree/features/reports/domain/entities/cashflow_trend_item.dart';
import 'package:pocketree/features/reports/domain/entities/category_breakdown.dart';
import 'package:pocketree/features/reports/domain/entities/period_comparison.dart';
import 'package:pocketree/features/reports/domain/entities/report_overview.dart';
import 'package:pocketree/features/reports/domain/entities/top_transaction.dart';
import 'package:pocketree/features/reports/domain/repositories/reports_repository.dart';

class ReportsRepositoryImpl implements ReportsRepository {
  final ReportsRemoteDatasource remoteDatasource;

  ReportsRepositoryImpl(this.remoteDatasource);

  @override
  Future<Either<Failure, ReportOverview>> getOverview({
    required DateTime startDate,
    required DateTime endDate,
    int? accountId,
  }) async {
    try {
      final model = await remoteDatasource.getOverview(
        startDate: startDate,
        endDate: endDate,
        accountId: accountId,
      );
      return Right(model.toEntity());
    } catch (e) {
      return mapExceptionToFailure(e);
    }
  }

  @override
  Future<Either<Failure, List<CashflowTrendItem>>> getCashflowTrend({
    required DateTime startDate,
    required DateTime endDate,
    int? accountId,
    String groupBy = 'day',
  }) async {
    try {
      final models = await remoteDatasource.getCashflowTrend(
        startDate: startDate,
        endDate: endDate,
        accountId: accountId,
        groupBy: groupBy,
      );
      return Right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return mapExceptionToFailure(e);
    }
  }

  @override
  Future<Either<Failure, CategoryBreakdown>> getCategoryBreakdown({
    required DateTime startDate,
    required DateTime endDate,
    int? accountId,
    String type = 'expense',
    int topN = 10,
  }) async {
    try {
      final model = await remoteDatasource.getCategoryBreakdown(
        startDate: startDate,
        endDate: endDate,
        accountId: accountId,
        type: type,
        topN: topN,
      );
      return Right(model.toEntity());
    } catch (e) {
      return mapExceptionToFailure(e);
    }
  }

  @override
  Future<Either<Failure, AccountBreakdown>> getAccountBreakdown({
    required DateTime startDate,
    required DateTime endDate,
    int? accountId,
    String type = 'expense',
  }) async {
    try {
      final model = await remoteDatasource.getAccountBreakdown(
        startDate: startDate,
        endDate: endDate,
        accountId: accountId,
        type: type,
      );
      return Right(model.toEntity());
    } catch (e) {
      return mapExceptionToFailure(e);
    }
  }

  @override
  Future<Either<Failure, List<TopTransaction>>> getTopTransactions({
    required DateTime startDate,
    required DateTime endDate,
    int? accountId,
    String type = 'expense',
    int limit = 5,
  }) async {
    try {
      final models = await remoteDatasource.getTopTransactions(
        startDate: startDate,
        endDate: endDate,
        accountId: accountId,
        type: type,
        limit: limit,
      );
      return Right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return mapExceptionToFailure(e);
    }
  }

  @override
  Future<Either<Failure, PeriodComparison>> getPeriodComparison({
    required DateTime startDate,
    required DateTime endDate,
    int? accountId,
  }) async {
    try {
      final model = await remoteDatasource.getPeriodComparison(
        startDate: startDate,
        endDate: endDate,
        accountId: accountId,
      );
      return Right(model.toEntity());
    } catch (e) {
      return mapExceptionToFailure(e);
    }
  }
}
