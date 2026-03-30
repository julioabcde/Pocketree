import 'package:dartz/dartz.dart';
import 'package:pocketree/core/error/failures.dart';
import 'package:pocketree/features/transactions/domain/entities/daily_summary.dart';
import 'package:pocketree/features/transactions/domain/repositories/transaction_repository.dart';

class GetDailySummaryUseCase {
  final TransactionRepository repository;

  GetDailySummaryUseCase(this.repository);

  Future<Either<Failure, List<DailySummary>>> call({
    required String month,
    int? accountId,
  }) {
    return repository.getDailySummary(
      month: month,
      accountId: accountId,
    );
  }
}