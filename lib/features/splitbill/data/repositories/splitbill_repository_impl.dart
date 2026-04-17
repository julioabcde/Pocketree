import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:pocketree/core/error/error_mapper.dart';
import 'package:pocketree/core/error/failures.dart';
import 'package:pocketree/features/splitbill/data/datasources/splitbill_remote_datasource.dart';
import 'package:pocketree/features/splitbill/domain/entities/receipt_scan_result.dart';
import 'package:pocketree/features/splitbill/domain/entities/split_bill.dart';
import 'package:pocketree/features/splitbill/domain/entities/split_bill_detail.dart';
import 'package:pocketree/features/splitbill/domain/entities/split_bill_settlement.dart';
import 'package:pocketree/features/splitbill/domain/entities/split_bill_summary.dart';
import 'package:pocketree/features/splitbill/domain/repositories/splitbill_repository.dart';

class SplitBillRepositoryImpl implements SplitBillRepository {
  final SplitBillRemoteDatasource remoteDatasource;

  SplitBillRepositoryImpl(this.remoteDatasource);

  @override
  Future<Either<Failure, SplitBill>> createSplitBill({
    required String title,
    required DateTime date,
    required List<({String name, double price, int quantity})> items,
    List<({String type, String name, double amount})> charges = const [],
    String? note,
  }) async {
    try {
      final model = await remoteDatasource.createSplitBill(
        title: title,
        date: date,
        items: items
            .map(
              (i) => SplitBillItemInput(
                name: i.name,
                price: i.price,
                quantity: i.quantity,
              ),
            )
            .toList(),
        charges: charges
            .map(
              (c) => SplitBillChargeInput(
                type: c.type,
                name: c.name,
                amount: c.amount,
              ),
            )
            .toList(),
        note: note,
      );
      return Right(model.toEntity());
    } catch (e) {
      return mapExceptionToFailure(e);
    }
  }

  @override
  Future<Either<Failure, List<SplitBill>>> getSplitBills() async {
    try {
      final models = await remoteDatasource.getSplitBills();
      return Right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return mapExceptionToFailure(e);
    }
  }

  @override
  Future<Either<Failure, SplitBillDetail>> getSplitBillDetail(
    int billId,
  ) async {
    try {
      final model = await remoteDatasource.getSplitBillDetail(billId);
      return Right(model.toEntity());
    } catch (e) {
      return mapExceptionToFailure(e);
    }
  }

  @override
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
  }) async {
    try {
      final model = await remoteDatasource.calculateSplit(
        billId: billId,
        participants: participants
            .map(
              (p) => ParticipantInput(
                name: p.name,
                isPayer: p.isPayer,
                paidAmount: p.paidAmount,
                userId: p.userId,
              ),
            )
            .toList(),
        shares:
            shares
                ?.map(
                  (s) => ParticipantShareInput(
                    participantIndex: s.participantIndex,
                    itemIds: s.itemIds,
                    customAmount: s.customAmount,
                    sharePortions: s.sharePortions,
                  ),
                )
                .toList() ??
            [],
        accountId: accountId,
      );
      return Right(model.toEntity());
    } catch (e) {
      return mapExceptionToFailure(e);
    }
  }

  @override
  Future<Either<Failure, SplitBillSettlement>> settleDebt({
    required int billId,
    required int debtId,
    required double amount,
    int? accountId,
  }) async {
    try {
      final model = await remoteDatasource.settleDebt(
        billId: billId,
        debtId: debtId,
        amount: amount,
        accountId: accountId,
      );
      return Right(model.toEntity());
    } catch (e) {
      return mapExceptionToFailure(e);
    }
  }

  @override
  Future<Either<Failure, void>> deleteSplitBill(int billId) async {
    try {
      await remoteDatasource.deleteSplitBill(billId);
      return const Right(null);
    } catch (e) {
      return mapExceptionToFailure(e);
    }
  }

  @override
  Future<Either<Failure, List<SplitBillSummary>>> getSplitBillsSummary() async {
    try {
      final models = await remoteDatasource.getSplitBillsSummary();
      return Right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return mapExceptionToFailure(e);
    }
  }

  @override
  Future<Either<Failure, ReceiptScanResult>> scanReceipt(File image) async {
    try {
      final model = await remoteDatasource.scanReceipt(image);
      return Right(model.toEntity());
    } catch (e) {
      return mapExceptionToFailure(e);
    }
  }
}
