import 'package:dartz/dartz.dart';
import 'package:pocketree/core/error/failures.dart';
import 'package:pocketree/features/splitbill/domain/entities/split_bill_settlement.dart';
import 'package:pocketree/features/splitbill/domain/repositories/splitbill_repository.dart';

class SettleDebtUseCase {
  final SplitBillRepository repository;
  SettleDebtUseCase(this.repository);

  Future<Either<Failure, SplitBillSettlement>> call({
    required int billId,
    required int debtId,
    required double amount,
    int? accountId,
  }) {
    return repository.settleDebt(
      billId: billId,
      debtId: debtId,
      amount: amount,
      accountId: accountId,
    );
  }
}