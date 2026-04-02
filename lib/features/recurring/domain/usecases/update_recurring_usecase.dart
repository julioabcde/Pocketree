import 'package:dartz/dartz.dart';
import 'package:pocketree/core/error/failures.dart';
import 'package:pocketree/features/recurring/domain/entities/recurring_transaction.dart';
import 'package:pocketree/features/recurring/domain/repositories/recurring_repository.dart';

class UpdateRecurringUseCase {
  final RecurringRepository repository;
  UpdateRecurringUseCase(this.repository);

  Future<Either<Failure, RecurringTransaction>> call(
    int recurringId, {
    int? categoryId,
    double? amount,
    String? endDate,
    String? timezone,
    bool? autoCreate,
    int? maxOccurrences,
    bool? isActive,
    String? note,
  }) {
    return repository.updateRecurringTransaction(
      recurringId,
      categoryId: categoryId,
      amount: amount,
      endDate: endDate,
      timezone: timezone,
      autoCreate: autoCreate,
      maxOccurrences: maxOccurrences,
      isActive: isActive,
      note: note,
    );
  }
}
