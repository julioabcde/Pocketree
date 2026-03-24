import 'package:dartz/dartz.dart';
import 'package:pocketree/core/error/failures.dart';
import 'package:pocketree/features/transactions/domain/entities/transaction.dart';
import 'package:pocketree/features/transactions/domain/entities/transaction_filter.dart';
import 'package:pocketree/features/transactions/domain/repositories/transaction_repository.dart';

class GetTransactionsUseCase {
  final TransactionRepository repository;

  GetTransactionsUseCase(this.repository);

  Future<Either<Failure, List<Transaction>>> call({
    TransactionFilter filter = const TransactionFilter(),
    int? limit,
    int? offset,
  }) {
    return repository.getTransactions(
      filter: filter,
      limit: limit,
      offset: offset,
    );
  }
}