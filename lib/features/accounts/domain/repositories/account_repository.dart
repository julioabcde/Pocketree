import 'package:dartz/dartz.dart';
import 'package:pocketree/core/error/failures.dart';
import 'package:pocketree/features/accounts/domain/entities/account.dart';
import 'package:pocketree/features/accounts/domain/entities/account_summary.dart';
import 'package:pocketree/features/accounts/domain/entities/account_type.dart';

abstract class AccountRepository {
  Future<Either<Failure, Account>> createAccount({
    required String name,
    required AccountType type,
    double? initialBalance,
  });

  Future<Either<Failure, List<Account>>> getAccounts();

  Future<Either<Failure, AccountSummary>> getAccountSummary();

  Future<Either<Failure, Account>> getAccountById(int accountId);

  Future<Either<Failure, Account>> updateAccount({
    required int accountId,
    String? name,
    AccountType? type,
  });

  Future<Either<Failure, void>> deleteAccount(int accountId);
}
