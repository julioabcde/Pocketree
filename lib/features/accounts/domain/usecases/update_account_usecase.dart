import 'package:dartz/dartz.dart';
import 'package:pocketree/core/error/failures.dart';
import 'package:pocketree/features/accounts/domain/entities/account.dart';
import 'package:pocketree/features/accounts/domain/entities/account_type.dart';
import 'package:pocketree/features/accounts/domain/repositories/account_repository.dart';

class UpdateAccountUseCase {
  final AccountRepository repository;

  UpdateAccountUseCase(this.repository);

  Future<Either<Failure, Account>> call({
    required int accountId,
    String? name,
    AccountType? type,
  }) {
    return repository.updateAccount(
      accountId: accountId,
      name: name,
      type: type,
    );
  }
}