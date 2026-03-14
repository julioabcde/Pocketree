import 'package:dartz/dartz.dart';
import 'package:pocketree/core/error/failures.dart';
import 'package:pocketree/features/accounts/domain/entities/account.dart';
import 'package:pocketree/features/accounts/domain/repositories/account_repository.dart';

class GetAccountByIdUseCase {
  final AccountRepository repository;

  GetAccountByIdUseCase(this.repository);

  Future<Either<Failure, Account>> call(int accountId) {
    return repository.getAccountById(accountId);
  }
}
