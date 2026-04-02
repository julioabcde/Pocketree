import 'package:dartz/dartz.dart';
import 'package:pocketree/core/error/failures.dart';
import 'package:pocketree/features/recurring/domain/entities/recurring_transaction.dart';
import 'package:pocketree/features/recurring/domain/repositories/recurring_repository.dart';
import 'package:pocketree/features/transactions/domain/entities/transaction_type.dart';

class CreateRecurringUseCase {
  final RecurringRepository repository;
  CreateRecurringUseCase(this.repository);

  Future<Either<Failure, RecurringTransaction>> call({
    required int accountId,
    required TransactionType type,
    required double amount,
    required RecurringFrequency frequency,
    required DateTime startDate,
    int? categoryId,
    DateTime? endDate,
    String timezone = 'UTC',
    bool autoCreate = true,
    String? note,
  }) {
    return repository.createRecurringTransaction(
      accountId: accountId,
      type: type,
      amount: amount,
      frequency: frequency,
      startDate: startDate,
      categoryId: categoryId,
      endDate: endDate,
      timezone: timezone,
      autoCreate: autoCreate,
      note: note,
    );
  }
}
