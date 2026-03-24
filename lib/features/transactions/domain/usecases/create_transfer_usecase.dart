import 'package:dartz/dartz.dart';
import 'package:pocketree/core/error/failures.dart';
import 'package:pocketree/features/transactions/domain/entities/transfer_result.dart';
import 'package:pocketree/features/transactions/domain/repositories/transaction_repository.dart';

class CreateTransferUseCase {
  final TransactionRepository repository;

  CreateTransferUseCase(this.repository);

  Future<Either<Failure, TransferResult>> call({
    required int fromAccountId,
    required int toAccountId,
    required double amount,
    required DateTime date,
    String? note,
  }) {
    return repository.createTransfer(
      fromAccountId: fromAccountId,
      toAccountId: toAccountId,
      amount: amount,
      date: date,
      note: note,
    );
  }
}