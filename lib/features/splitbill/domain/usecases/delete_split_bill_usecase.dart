import 'package:dartz/dartz.dart';
import 'package:pocketree/core/error/failures.dart';
import 'package:pocketree/features/splitbill/domain/repositories/splitbill_repository.dart';

class DeleteSplitBillUseCase {
  final SplitBillRepository repository;
  DeleteSplitBillUseCase(this.repository);

  Future<Either<Failure, void>> call(int billId) {
    return repository.deleteSplitBill(billId);
  }
}