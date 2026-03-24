import 'package:dartz/dartz.dart';
import 'package:pocketree/core/error/failures.dart';
import 'package:pocketree/features/transactions/domain/entities/transaction.dart';
import 'package:pocketree/features/transactions/domain/entities/transaction_filter.dart';
import 'package:pocketree/features/transactions/domain/entities/transaction_summary.dart';
import 'package:pocketree/features/transactions/domain/entities/transaction_type.dart';
import 'package:pocketree/features/transactions/domain/entities/transfer_result.dart';

abstract class TransactionRepository {
  Future<Either<Failure, Transaction>> createTransaction({
    required int accountId,
    required TransactionType type,
    required double amount,
    required DateTime date,
    int? categoryId,
    String? note,
  });

  Future<Either<Failure, List<Transaction>>> getTransactions({
    TransactionFilter filter = const TransactionFilter(),
    int? limit,
    int? offset,
  });

  Future<Either<Failure, TransactionSummary>> getTransactionSummary({
    TransactionFilter filter = const TransactionFilter(),
  });

  Future<Either<Failure, TransferResult>> createTransfer({
    required int fromAccountId,
    required int toAccountId,
    required double amount,
    required DateTime date,
    String? note,
  });

  Future<Either<Failure, Transaction>> getTransactionById(int transactionId);

  Future<Either<Failure, Transaction>> updateTransaction({
    required int transactionId,
    int? categoryId,
    double? amount,
    DateTime? date,
    String? note,
  });

  Future<Either<Failure, void>> deleteTransaction(int transactionId);
}
