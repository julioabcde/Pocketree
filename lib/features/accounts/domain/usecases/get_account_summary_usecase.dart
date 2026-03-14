import 'package:dartz/dartz.dart';
import 'package:pocketree/core/error/failures.dart';
import 'package:pocketree/features/accounts/domain/entities/account_summary.dart';
import 'package:pocketree/features/accounts/domain/repositories/account_repository.dart';

class GetAccountSummaryUseCase {
  final AccountRepository repository;

  GetAccountSummaryUseCase(this.repository);

  Future<Either<Failure, AccountSummary>> call() {
    return repository.getAccountSummary();
  }
}