import 'package:dartz/dartz.dart';
import 'package:pocketree/core/error/failures.dart';
import 'package:pocketree/features/transactions/domain/entities/transaction.dart';
import 'package:pocketree/features/transactions/domain/entities/transaction_type.dart';
import 'package:pocketree/features/transactions/domain/repositories/transaction_repository.dart';

class CreateTransactionUseCase {
  final TransactionRepository repository;

  CreateTransactionUseCase(this.repository);

  Future<Either<Failure, Transaction>> call({
    required int accountId,
    required TransactionType type,
    required double amount,
    required DateTime date,
    int? categoryId,
    String? note,
  }) {
    return repository.createTransaction(
      accountId: accountId,
      type: type,
      amount: amount,
      date: date,
      categoryId: categoryId,
      note: note,
    );
  }
}