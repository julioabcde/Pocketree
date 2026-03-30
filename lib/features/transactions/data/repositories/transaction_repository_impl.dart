import 'package:dartz/dartz.dart';
import 'package:pocketree/core/error/error_mapper.dart';
import 'package:pocketree/core/error/failures.dart';
import 'package:pocketree/features/transactions/data/datasources/transaction_remote_datasource.dart';
import 'package:pocketree/features/transactions/domain/entities/daily_summary.dart';
import 'package:pocketree/features/transactions/domain/entities/transaction.dart';
import 'package:pocketree/features/transactions/domain/entities/transaction_filter.dart';
import 'package:pocketree/features/transactions/domain/entities/transaction_summary.dart';
import 'package:pocketree/features/transactions/domain/entities/transaction_type.dart';
import 'package:pocketree/features/transactions/domain/entities/transfer_result.dart';
import 'package:pocketree/features/transactions/domain/repositories/transaction_repository.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionRemoteDatasource remoteDatasource;

  TransactionRepositoryImpl(this.remoteDatasource);

  @override
  Future<Either<Failure, Transaction>> createTransaction({
    required int accountId,
    required TransactionType type,
    required double amount,
    required DateTime date,
    int? categoryId,
    String? note,
  }) async {
    try {
      final model = await remoteDatasource.createTransaction(
        accountId: accountId,
        type: type,
        amount: amount,
        date: date,
        categoryId: categoryId,
        note: note,
      );
      return Right(model.toEntity());
    } catch (e) {
      return mapExceptionToFailure(e);
    }
  }

  @override
  Future<Either<Failure, List<Transaction>>> getTransactions({
    TransactionFilter filter = const TransactionFilter(),
    int? limit,
    int? offset,
  }) async {
    try {
      final models = await remoteDatasource.getTransactions(
        filter: filter,
        limit: limit,
        offset: offset,
      );
      return Right(models.map((model) => model.toEntity()).toList());
    } catch (e) {
      return mapExceptionToFailure(e);
    }
  }

  @override
  Future<Either<Failure, TransactionSummary>> getTransactionSummary({
    TransactionFilter filter = const TransactionFilter(),
  }) async {
    try {
      final model = await remoteDatasource.getTransactionSummary(
        filter: filter,
      );
      return Right(model.toEntity());
    } catch (e) {
      return mapExceptionToFailure(e);
    }
  }

  @override
  Future<Either<Failure, List<DailySummary>>> getDailySummary({
    required String month,
    int? accountId,
  }) async {
    try {
      final models = await remoteDatasource.getDailySummary(
        month: month,
        accountId: accountId,
      );
      return Right(models.map((model) => model.toEntity()).toList());
    } catch (e) {
      return mapExceptionToFailure(e);
    }
  }

  @override
  Future<Either<Failure, TransferResult>> createTransfer({
    required int fromAccountId,
    required int toAccountId,
    required double amount,
    required DateTime date,
    String? note,
  }) async {
    try {
      final model = await remoteDatasource.createTransfer(
        fromAccountId: fromAccountId,
        toAccountId: toAccountId,
        amount: amount,
        date: date,
        note: note,
      );
      return Right(model.toEntity());
    } catch (e) {
      return mapExceptionToFailure(e);
    }
  }

  @override
  Future<Either<Failure, Transaction>> getTransactionById(
    int transactionId,
  ) async {
    try {
      final model = await remoteDatasource.getTransactionById(transactionId);
      return Right(model.toEntity());
    } catch (e) {
      return mapExceptionToFailure(e);
    }
  }

  @override
  Future<Either<Failure, Transaction>> updateTransaction({
    required int transactionId,
    int? accountId,
    int? categoryId,
    double? amount,
    DateTime? date,
    String? note,
  }) async {
    try {
      final model = await remoteDatasource.updateTransaction(
        transactionId: transactionId,
        accountId: accountId,
        categoryId: categoryId,
        amount: amount,
        date: date,
        note: note,
      );
      return Right(model.toEntity());
    } catch (e) {
      return mapExceptionToFailure(e);
    }
  }

  @override
  Future<Either<Failure, void>> deleteTransaction(int transactionId) async {
    try {
      await remoteDatasource.deleteTransaction(transactionId);
      return const Right(null);
    } catch (e) {
      return mapExceptionToFailure(e);
    }
  }
}