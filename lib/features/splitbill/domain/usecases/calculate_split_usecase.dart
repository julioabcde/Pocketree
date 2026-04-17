import 'package:dartz/dartz.dart';
import 'package:pocketree/core/error/failures.dart';
import 'package:pocketree/features/splitbill/domain/entities/split_bill_detail.dart';
import 'package:pocketree/features/splitbill/domain/repositories/splitbill_repository.dart';

class CalculateSplitUseCase {
  final SplitBillRepository repository;
  CalculateSplitUseCase(this.repository);

  Future<Either<Failure, SplitBillDetail>> call({
    required int billId,
    required List<({String name, bool isPayer, double paidAmount, int? userId})> participants,
    List<({
      int participantIndex,
      List<int>? itemIds,
      double? customAmount,
      Map<String, int>? sharePortions,
    })>? shares,
    int? accountId,
  }) {
    return repository.calculateSplit(
      billId: billId,
      participants: participants,
      shares: shares,
      accountId: accountId,
    );
  }
}