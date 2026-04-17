import 'package:dartz/dartz.dart';
import 'package:pocketree/core/error/failures.dart';
import 'package:pocketree/features/splitbill/domain/entities/split_bill.dart';
import 'package:pocketree/features/splitbill/domain/repositories/splitbill_repository.dart';

class CreateSplitBillUseCase {
  final SplitBillRepository repository;
  CreateSplitBillUseCase(this.repository);

  Future<Either<Failure, SplitBill>> call({
    required String title,
    required DateTime date,
    required List<({String name, double price, int quantity})> items,
    List<({String type, String name, double amount})> charges = const [],
    String? note,
  }) {
    return repository.createSplitBill(
      title: title,
      date: date,
      items: items,
      charges: charges,
      note: note,
    );
  }
}