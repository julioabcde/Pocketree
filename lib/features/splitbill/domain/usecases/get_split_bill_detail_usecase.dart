import 'package:dartz/dartz.dart';
import 'package:pocketree/core/error/failures.dart';
import 'package:pocketree/features/splitbill/domain/entities/split_bill_detail.dart';
import 'package:pocketree/features/splitbill/domain/repositories/splitbill_repository.dart';

class GetSplitBillDetailUseCase {
  final SplitBillRepository repository;
  GetSplitBillDetailUseCase(this.repository);

  Future<Either<Failure, SplitBillDetail>> call(int billId) {
    return repository.getSplitBillDetail(billId);
  }
}