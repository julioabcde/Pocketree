import 'package:dartz/dartz.dart';
import 'package:pocketree/core/error/failures.dart';
import 'package:pocketree/features/accounts/domain/entities/account.dart';
import 'package:pocketree/features/accounts/domain/entities/account_type.dart';
import 'package:pocketree/features/accounts/domain/repositories/account_repository.dart';

class CreateAccountUseCase {
  final AccountRepository repository;

  CreateAccountUseCase(this.repository);

  Future<Either<Failure, Account>> call({
    required String name,
    required AccountType type,
    double? initialBalance,
  }){
    return repository.createAccount(
      name: name,
      type: type,
      initialBalance: initialBalance,
    );
  }
}