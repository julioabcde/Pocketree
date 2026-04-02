import 'package:dartz/dartz.dart';
import 'package:pocketree/core/error/failures.dart';
import 'package:pocketree/features/recurring/domain/entities/recurring_transaction.dart';
import 'package:pocketree/features/recurring/domain/repositories/recurring_repository.dart';

class GetRecurringUseCase {
  final RecurringRepository repository;
  GetRecurringUseCase(this.repository);

  Future<Either<Failure, List<RecurringTransaction>>> call() {
    return repository.getRecurringTransactions();
  }
}