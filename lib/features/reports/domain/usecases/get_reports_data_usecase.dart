import 'package:dartz/dartz.dart';
import 'package:pocketree/core/error/failures.dart';
import 'package:pocketree/features/reports/domain/entities/reports_data.dart';
import 'package:pocketree/features/reports/domain/repositories/reports_repository.dart';

class GetReportsDataUseCase {
  final ReportsRepository repository;

  GetReportsDataUseCase(this.repository);

  Future<Either<Failure, ReportsData>> call({
    required DateTime startDate,
    required DateTime endDate,
    int? accountId,
    String groupBy = 'day',
    String type = 'expense',
    int topN = 10,
    int limit = 5,
  }) async {
    final (
      overviewResult,
      cashflowResult,
      categoryResult,
      accountResult,
      topTxResult,
      comparisonResult,
    ) = await (
      repository.getOverview(
        startDate: startDate,
        endDate: endDate,
        accountId: accountId,
      ),
      repository.getCashflowTrend(
        startDate: startDate,
        endDate: endDate,
        accountId: accountId,
        groupBy: groupBy,
      ),
      repository.getCategoryBreakdown(
        startDate: startDate,
        endDate: endDate,
        accountId: accountId,
        type: type,
        topN: topN,
      ),
      repository.getAccountBreakdown(
        startDate: startDate,
        endDate: endDate,
        accountId: accountId,
        type: type,
      ),
      repository.getTopTransactions(
        startDate: startDate,
        endDate: endDate,
        accountId: accountId,
        type: type,
        limit: limit,
      ),
      repository.getPeriodComparison(
        startDate: startDate,
        endDate: endDate,
        accountId: accountId,
      ),
    ).wait;

    return overviewResult.fold(
      (failure) => Left(failure),
      (overview) => cashflowResult.fold(
        (failure) => Left(failure),
        (cashflow) => categoryResult.fold(
          (failure) => Left(failure),
          (category) => accountResult.fold(
            (failure) => Left(failure),
            (account) => topTxResult.fold(
              (failure) => Left(failure),
              (topTx) => comparisonResult.fold(
                (failure) => Left(failure),
                (comparison) => Right(
                  ReportsData(
                    overview: overview,
                    cashflowTrend: cashflow,
                    categoryBreakdown: category,
                    accountBreakdown: account,
                    topTransactions: topTx,
                    periodComparison: comparison,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
