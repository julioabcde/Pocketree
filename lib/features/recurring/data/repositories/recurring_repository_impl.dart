import 'package:dartz/dartz.dart';
import 'package:intl/intl.dart';
import 'package:pocketree/core/error/error_mapper.dart';
import 'package:pocketree/core/error/failures.dart';
import 'package:pocketree/features/recurring/data/datasources/recurring_remote_datasource.dart';
import 'package:pocketree/features/recurring/domain/entities/recurring_transaction.dart';
import 'package:pocketree/features/recurring/domain/repositories/recurring_repository.dart';
import 'package:pocketree/features/transactions/domain/entities/transaction_type.dart';

class RecurringRepositoryImpl implements RecurringRepository {
  final RecurringRemoteDatasource remoteDatasource;
  RecurringRepositoryImpl(this.remoteDatasource);

  @override
  Future<Either<Failure, List<RecurringTransaction>>>
      getRecurringTransactions() async {
    try {
      final models = await remoteDatasource.getRecurringTransactions();
      return Right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return mapExceptionToFailure(e);
    }
  }

  @override
  Future<Either<Failure, void>> deleteRecurringTransaction(
      int recurringId) async {
    try {
      await remoteDatasource.deleteRecurringTransaction(recurringId);
      return const Right(null);
    } catch (e) {
      return mapExceptionToFailure(e);
    }
  }

  @override
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
  }) async {
    try {
      int? dayOfWeek;
      int? dayOfMonth;
      int? monthOfYear;

      switch (frequency) {
        case RecurringFrequency.weekly:
          dayOfWeek = startDate.weekday;
        case RecurringFrequency.monthly:
          dayOfMonth = startDate.day;
        case RecurringFrequency.yearly:
          dayOfMonth = startDate.day;
          monthOfYear = startDate.month;
        case RecurringFrequency.daily:
          break;
      }

      final formatter = DateFormat('yyyy-MM-dd');
      final model = await remoteDatasource.createRecurringTransaction(
        accountId: accountId,
        type: type.value,
        amount: amount,
        frequency: frequency.value,
        startDate: formatter.format(startDate),
        categoryId: categoryId,
        endDate: endDate != null ? formatter.format(endDate) : null,
        timezone: timezone,
        autoCreate: autoCreate,
        note: note,
        dayOfWeek: dayOfWeek,
        dayOfMonth: dayOfMonth,
        monthOfYear: monthOfYear,
      );
      return Right(model.toEntity());
    } catch (e) {
      return mapExceptionToFailure(e);
    }
  }

  @override
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
  }) async {
    try {
      final model = await remoteDatasource.updateRecurringTransaction(
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
      return Right(model.toEntity());
    } catch (e) {
      return mapExceptionToFailure(e);
    }
  }

  @override
  Future<Either<Failure, void>> executeRecurringTransaction(
      int recurringId) async {
    try {
      await remoteDatasource.executeRecurringTransaction(recurringId);
      return const Right(null);
    } catch (e) {
      return mapExceptionToFailure(e);
    }
  }
}