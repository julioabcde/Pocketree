import 'dart:io';

import 'package:dio/dio.dart';
import 'package:pocketree/core/error/dio_error_handler.dart';
import 'package:pocketree/features/splitbill/data/models/receipt_scan_model.dart';
import 'package:pocketree/features/splitbill/data/models/split_bill_detail_model.dart';
import 'package:pocketree/features/splitbill/data/models/split_bill_model.dart';
import 'package:pocketree/features/splitbill/data/models/split_bill_settlement_model.dart';
import 'package:pocketree/features/splitbill/data/models/split_bill_summary_model.dart';

class SplitBillItemInput {
  final String name;
  final double price;
  final int quantity;

  const SplitBillItemInput({
    required this.name,
    required this.price,
    this.quantity = 1,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'price': price.toStringAsFixed(2),
    'quantity': quantity,
  };
}

class SplitBillChargeInput {
  final String type;
  final String name;
  final double amount;

  const SplitBillChargeInput({
    required this.type,
    required this.name,
    required this.amount,
  });

  Map<String, dynamic> toJson() => {
    'type': type,
    'name': name,
    'amount': amount.toStringAsFixed(2),
  };
}

class ParticipantInput {
  final String name;
  final bool isPayer;
  final double paidAmount;
  final int? userId;

  const ParticipantInput({
    required this.name,
    this.isPayer = false,
    this.paidAmount = 0.0,
    this.userId,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'name': name,
      'is_payer': isPayer,
      'paid_amount': paidAmount.toStringAsFixed(2),
    };
    if (userId != null) map['user_id'] = userId;
    return map;
  }
}

class ParticipantShareInput {
  final int participantIndex;
  final List<int>? itemIds;
  final double? customAmount;

  final Map<String, int>? sharePortions;

  const ParticipantShareInput({
    required this.participantIndex,
    this.itemIds,
    this.customAmount,
    this.sharePortions,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{'participant_index': participantIndex};
    if (itemIds != null) map['item_ids'] = itemIds;
    if (customAmount != null) {
      map['custom_amount'] = customAmount!.toStringAsFixed(2);
    }
    if (sharePortions != null) map['share_portions'] = sharePortions;
    return map;
  }
}

abstract class SplitBillRemoteDatasource {
  Future<SplitBillModel> createSplitBill({
    required String title,
    required DateTime date,
    required List<SplitBillItemInput> items,
    List<SplitBillChargeInput> charges,
    String? note,
  });

  Future<List<SplitBillModel>> getSplitBills();

  Future<SplitBillDetailModel> getSplitBillDetail(int billId);

  Future<SplitBillDetailModel> calculateSplit({
    required int billId,
    required List<ParticipantInput> participants,
    List<ParticipantShareInput> shares,
    int? accountId,
  });

  Future<SplitBillSettlementModel> settleDebt({
    required int billId,
    required int debtId,
    required double amount,
    int? accountId,
  });

  Future<void> deleteSplitBill(int billId);
  Future<List<SplitBillSummaryModel>> getSplitBillsSummary();

  Future<ReceiptScanResultModel> scanReceipt(File image);
}

class SplitBillRemoteDatasourceImpl implements SplitBillRemoteDatasource {
  final Dio dio;

  SplitBillRemoteDatasourceImpl(this.dio);

  @override
  Future<List<SplitBillSummaryModel>> getSplitBillsSummary() async {
    try {
      final response = await dio.get('/split-bills/summary');
      final list = response.data as List<dynamic>;
      return list
          .map((j) => SplitBillSummaryModel.fromJson(j as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      handleDioError(e);
    }
  }

  @override
  Future<SplitBillModel> createSplitBill({
    required String title,
    required DateTime date,
    required List<SplitBillItemInput> items,
    List<SplitBillChargeInput> charges = const [],
    String? note,
  }) async {
    try {
      final data = <String, dynamic>{
        'title': title,
        'date': _formatDate(date),
        'items': items.map((i) => i.toJson()).toList(),
      };
      if (charges.isNotEmpty) {
        data['charges'] = charges.map((c) => c.toJson()).toList();
      }
      if (note != null) data['note'] = note;

      final response = await dio.post('/split-bills', data: data);
      return SplitBillModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      handleDioError(e);
    }
  }

  @override
  Future<List<SplitBillModel>> getSplitBills() async {
    try {
      final response = await dio.get('/split-bills');
      final list = response.data as List<dynamic>;
      return list
          .map((j) => SplitBillModel.fromJson(j as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      handleDioError(e);
    }
  }

  @override
  Future<SplitBillDetailModel> getSplitBillDetail(int billId) async {
    try {
      final response = await dio.get('/split-bills/$billId');
      return SplitBillDetailModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      handleDioError(e);
    }
  }

  @override
  Future<SplitBillDetailModel> calculateSplit({
    required int billId,
    required List<ParticipantInput> participants,
    List<ParticipantShareInput> shares = const [],
    int? accountId,
  }) async {
    try {
      final data = <String, dynamic>{
        'participants': participants.map((p) => p.toJson()).toList(),
      };
      if (shares.isNotEmpty) {
        data['shares'] = shares.map((s) => s.toJson()).toList();
      }
      if (accountId != null) data['account_id'] = accountId;

      await dio.post('/split-bills/$billId/calculate', data: data);
      return getSplitBillDetail(billId);
    } on DioException catch (e) {
      handleDioError(e);
    }
  }

  @override
  Future<SplitBillSettlementModel> settleDebt({
    required int billId,
    required int debtId,
    required double amount,
    int? accountId,
  }) async {
    try {
      final data = <String, dynamic>{'amount': amount.toStringAsFixed(2)};
      if (accountId != null) data['account_id'] = accountId;
      final response = await dio.post(
        '/split-bills/$billId/debts/$debtId/settle',
        data: data,
      );
      return SplitBillSettlementModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      handleDioError(e);
    }
  }

  @override
  Future<void> deleteSplitBill(int billId) async {
    try {
      await dio.delete('/split-bills/$billId');
    } on DioException catch (e) {
      handleDioError(e);
    }
  }

  @override
  Future<ReceiptScanResultModel> scanReceipt(File image) async {
    try {
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          image.path,
          filename: image.uri.pathSegments.last,
        ),
      });
      final response = await dio.post(
        '/split-bills/scan-receipt',
        data: formData,
        options: Options(
          receiveTimeout: const Duration(seconds: 90),
          sendTimeout: const Duration(seconds: 60),
        ),
      );
      return ReceiptScanResultModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      handleDioError(e);
    }
  }

  String _formatDate(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}
