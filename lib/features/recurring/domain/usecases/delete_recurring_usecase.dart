import 'package:dartz/dartz.dart';
import 'package:pocketree/core/error/failures.dart';
import 'package:pocketree/features/recurring/domain/repositories/recurring_repository.dart';

class DeleteRecurringUseCase {
  final RecurringRepository repository;
  DeleteRecurringUseCase(this.repository);

  Future<Either<Failure, void>> call(int recurringId) {
    return repository.deleteRecurringTransaction(recurringId);
  }
}