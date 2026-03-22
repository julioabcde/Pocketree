import 'package:dartz/dartz.dart';
import 'package:pocketree/core/error/failures.dart';
import 'package:pocketree/features/accounts/domain/repositories/account_repository.dart';

class DeleteAccountUseCase {
  final AccountRepository repository;

  DeleteAccountUseCase(this.repository);

  Future<Either<Failure, void>> call(int accountId) {
    return repository.deleteAccount(accountId);
  } 
}