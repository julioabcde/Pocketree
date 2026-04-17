import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:pocketree/core/error/failures.dart';
import 'package:pocketree/features/splitbill/domain/entities/receipt_scan_result.dart';
import 'package:pocketree/features/splitbill/domain/entities/split_bill.dart';
import 'package:pocketree/features/splitbill/domain/entities/split_bill_detail.dart';
import 'package:pocketree/features/splitbill/domain/entities/split_bill_settlement.dart';
import 'package:pocketree/features/splitbill/domain/entities/split_bill_summary.dart';

abstract class SplitBillRepository {
  Future<Either<Failure, SplitBill>> createSplitBill({
    required String title,
    required DateTime date,
    required List<({String name, double price, int quantity})> items,
    List<({String type, String name, double amount})> charges,
    String? note,
  });

  Future<Either<Failure, List<SplitBill>>> getSplitBills();

  Future<Either<Failure, SplitBillDetail>> getSplitBillDetail(int billId);

  Future<Either<Failure, SplitBillDetail>> calculateSplit({
    required int billId,
    required List<({String name, bool isPayer, double paidAmount, int? userId})>
    participants,
    List<
      ({
        int participantIndex,
        List<int>? itemIds,
        double? customAmount,
        Map<String, int>? sharePortions,
      })
    >?
    shares,
    int? accountId,
  });

  Future<Either<Failure, SplitBillSettlement>> settleDebt({
    required int billId,
    required int debtId,
    required double amount,
    int? accountId,
  });

  Future<Either<Failure, void>> deleteSplitBill(int billId);

  Future<Either<Failure, List<SplitBillSummary>>> getSplitBillsSummary();

  Future<Either<Failure, ReceiptScanResult>> scanReceipt(File image);
}
