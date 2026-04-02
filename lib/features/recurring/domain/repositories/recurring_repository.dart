import 'package:dartz/dartz.dart';
import 'package:pocketree/core/error/failures.dart';
import 'package:pocketree/features/recurring/domain/entities/recurring_transaction.dart';
import 'package:pocketree/features/transactions/domain/entities/transaction_type.dart';

abstract class RecurringRepository {
  Future<Either<Failure, List<RecurringTransaction>>> getRecurringTransactions();
  Future<Either<Failure, void>> deleteRecurringTransaction(int recurringId);
  Future<Either<Failure, RecurringTransaction>> createRecurringTransaction({
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
  });
  Future<Either<Failure, RecurringTransaction>> updateRecurringTransaction(
    int recurringId, {
    int? categoryId,
    double? amount,
    String? endDate,
    String? timezone,
    bool? autoCreate,
    int? maxOccurrences,
    bool? isActive,
    String? note,
  });
  Future<Either<Failure, void>> executeRecurringTransaction(int recurringId);
}