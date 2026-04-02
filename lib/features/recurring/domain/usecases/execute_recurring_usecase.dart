import 'package:dartz/dartz.dart';
import 'package:pocketree/core/error/failures.dart';
import 'package:pocketree/features/recurring/domain/repositories/recurring_repository.dart';

class ExecuteRecurringUseCase {
  final RecurringRepository repository;
  ExecuteRecurringUseCase(this.repository);

  Future<Either<Failure, void>> call(int recurringId) {
    return repository.executeRecurringTransaction(recurringId);
  }
}
