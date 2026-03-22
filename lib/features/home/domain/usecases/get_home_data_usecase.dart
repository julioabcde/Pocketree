import 'package:dartz/dartz.dart';
import 'package:pocketree/core/error/failures.dart';
import 'package:pocketree/features/accounts/domain/repositories/account_repository.dart';
import 'package:pocketree/features/home/domain/entities/home_data.dart';

class GetHomeDataUseCase {
  final AccountRepository accountRepository;

  GetHomeDataUseCase(this.accountRepository);

  Future<Either<Failure, HomeData>> call() async {
    final result = await accountRepository.getAccounts();
    return result.fold(
      (failure) => Left(failure),
      (accounts) => Right(HomeData(accounts: accounts)),
    );
  }
}