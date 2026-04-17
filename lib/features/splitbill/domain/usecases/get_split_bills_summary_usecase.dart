import 'package:dartz/dartz.dart';
import 'package:pocketree/core/error/failures.dart';
import 'package:pocketree/features/splitbill/domain/entities/split_bill_summary.dart';
import 'package:pocketree/features/splitbill/domain/repositories/splitbill_repository.dart';

class GetSplitBillsSummaryUseCase {
  final SplitBillRepository repository;
  GetSplitBillsSummaryUseCase(this.repository);

  Future<Either<Failure, List<SplitBillSummary>>> call() {
    return repository.getSplitBillsSummary();
  }
}