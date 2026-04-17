import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:pocketree/core/error/failures.dart';
import 'package:pocketree/features/splitbill/domain/entities/receipt_scan_result.dart';
import 'package:pocketree/features/splitbill/domain/repositories/splitbill_repository.dart';

class ScanReceiptUseCase {
  final SplitBillRepository repository;
  ScanReceiptUseCase(this.repository);

  Future<Either<Failure, ReceiptScanResult>> call(File image) {
    return repository.scanReceipt(image);
  }
}
