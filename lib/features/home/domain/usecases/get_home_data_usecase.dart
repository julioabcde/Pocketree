import 'package:dartz/dartz.dart';
import 'package:pocketree/core/error/failures.dart';
import 'package:pocketree/features/accounts/domain/repositories/account_repository.dart';
import 'package:pocketree/features/home/domain/entities/home_data.dart';
import 'package:pocketree/features/transactions/domain/entities/transaction_filter.dart';
import 'package:pocketree/features/transactions/domain/repositories/transaction_repository.dart';

class GetHomeDataUseCase {
  final AccountRepository accountRepository;
  final TransactionRepository transactionRepository;

  GetHomeDataUseCase(this.accountRepository, this.transactionRepository);

  Future<Either<Failure, HomeData>> call() async {
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);

    final todayFilter = TransactionFilter(
      startDate: todayStart,
      endDate: todayStart,
    );

    final (accountsResult, transactionsResult) = await (
      accountRepository.getAccounts(),
      transactionRepository.getTransactions(filter: todayFilter),
    ).wait;

    return accountsResult.fold(
      (failure) => Left(failure),
      (accounts) => transactionsResult.fold(
        (failure) => Left(failure),
        (transactions) => Right(
          HomeData(accounts: accounts, todayTransactions: transactions),
        ),
      ),
    );
  }
}
