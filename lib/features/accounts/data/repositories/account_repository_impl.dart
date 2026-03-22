import 'package:dartz/dartz.dart';
import 'package:pocketree/core/error/error_mapper.dart';
import 'package:pocketree/core/error/failures.dart';
import 'package:pocketree/features/accounts/data/datasources/account_remote_datasource.dart';
import 'package:pocketree/features/accounts/domain/entities/account.dart';
import 'package:pocketree/features/accounts/domain/entities/account_summary.dart';
import 'package:pocketree/features/accounts/domain/entities/account_type.dart';
import 'package:pocketree/features/accounts/domain/repositories/account_repository.dart';

class AccountRepositoryImpl implements AccountRepository {
  final AccountRemoteDatasource remoteDatasource;

  AccountRepositoryImpl(this.remoteDatasource);

  @override
  Future<Either<Failure, Account>> createAccount({
    required String name,
    required AccountType type,
    double? initialBalance,
  }) async {
    try {
      final model = await remoteDatasource.createAccount(
        name: name,
        type: type,
        initialBalance: initialBalance,
      );
      return Right(model.toEntity());
    } catch (e) {
      return mapExceptionToFailure(e);
    }
  }

  @override
  Future<Either<Failure, List<Account>>> getAccounts() async {
    try {
      final models = await remoteDatasource.getAccounts();
      return Right(models.map((model) => model.toEntity()).toList());
    } catch (e) {
      return mapExceptionToFailure(e);
    }
  }

  @override
  Future<Either<Failure, AccountSummary>> getAccountSummary() async {
    try {
      final model = await remoteDatasource.getAccountSummary();
      return Right(model.toEntity());
    } catch (e) {
      return mapExceptionToFailure(e);
    }
  }

  @override
  Future<Either<Failure, Account>> getAccountById(int accountId) async {
    try {
      final model = await remoteDatasource.getAccountById(accountId);
      return Right(model.toEntity());
    } catch (e) {
      return mapExceptionToFailure(e);
    }
  }

  @override
  Future<Either<Failure, Account>> updateAccount({
    required int accountId,
    String? name,
    AccountType? type,
  }) async {
    try {
      final model = await remoteDatasource.updateAccount(
        accountId: accountId,
        name: name,
        type: type,
      );
      return Right(model.toEntity());
    } catch (e) {
      return mapExceptionToFailure(e);
    }
  }

  @override
  Future<Either<Failure, void>> deleteAccount(int accountId) async {
    try {
      await remoteDatasource.deleteAccount(accountId);
      return const Right(null);
    } catch (e) {
      return mapExceptionToFailure(e);
    }
  }
}
