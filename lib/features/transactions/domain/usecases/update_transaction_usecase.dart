import 'package:dartz/dartz.dart';
import 'package:pocketree/core/error/failures.dart';
import 'package:pocketree/features/transactions/domain/entities/transaction.dart';
import 'package:pocketree/features/transactions/domain/repositories/transaction_repository.dart';

class UpdateTransactionUseCase {
  final TransactionRepository repository;

  UpdateTransactionUseCase(this.repository);

  Future<Either<Failure, Transaction>> call({
    required int transactionId,
    int? accountId,
    int? categoryId,
    double? amount,
    DateTime? date,
    String? note,
  }) {
    return repository.updateTransaction(
      transactionId: transactionId,
      accountId: accountId,
      categoryId: categoryId,
      amount: amount,
      date: date,
      note: note,
    );
  }
}