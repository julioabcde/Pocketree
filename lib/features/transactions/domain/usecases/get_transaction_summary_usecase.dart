import 'package:dartz/dartz.dart';
import 'package:pocketree/core/error/failures.dart';
import 'package:pocketree/features/transactions/domain/entities/transaction_filter.dart';
import 'package:pocketree/features/transactions/domain/entities/transaction_summary.dart';
import 'package:pocketree/features/transactions/domain/repositories/transaction_repository.dart';

class GetTransactionSummaryUseCase {
  final TransactionRepository repository;

  GetTransactionSummaryUseCase(this.repository);

  Future<Either<Failure, TransactionSummary>> call({
    TransactionFilter filter = const TransactionFilter(),
  }) {
    return repository.getTransactionSummary(filter: filter);
  }
}
