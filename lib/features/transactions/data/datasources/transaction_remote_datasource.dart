import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:pocketree/core/error/dio_error_handler.dart';
import 'package:pocketree/features/transactions/data/models/daily_summary.model.dart';
import 'package:pocketree/features/transactions/data/models/transaction_model.dart';
import 'package:pocketree/features/transactions/data/models/transaction_summary_model.dart';
import 'package:pocketree/features/transactions/data/models/transfer_result_model.dart';
import 'package:pocketree/features/transactions/domain/entities/transaction_filter.dart';
import 'package:pocketree/features/transactions/domain/entities/transaction_type.dart';

abstract class TransactionRemoteDatasource {
  Future<TransactionModel> createTransaction({
    required int accountId,
    required TransactionType type,
    required double amount,
    required DateTime date,
    int? categoryId,
    String? note,
  });

  Future<List<TransactionModel>> getTransactions({
    TransactionFilter filter = const TransactionFilter(),
    int? limit,
    int? offset,
  });

  Future<TransactionSummaryModel> getTransactionSummary({
    TransactionFilter filter = const TransactionFilter(),
  });

  Future<List<DailySummaryModel>> getDailySummary({
    required String month,
    int? accountId,
  });

  Future<TransferResultModel> createTransfer({
    required int fromAccountId,
    required int toAccountId,
    required double amount,
    required DateTime date,
    String? note,
  });

  Future<TransactionModel> getTransactionById(int transactionId);

  Future<TransactionModel> updateTransaction({
    required int transactionId,
    int? accountId,
    int? categoryId,
    double? amount,
    DateTime? date,
    String? note,
  });

  Future<void> deleteTransaction(int transactionId);
}

class TransactionRemoteDatasourceImpl implements TransactionRemoteDatasource {
  final Dio dio;
  static final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  TransactionRemoteDatasourceImpl(this.dio);

  @override
  Future<TransactionModel> createTransaction({
    required int accountId,
    required TransactionType type,
    required double amount,
    required DateTime date,
    int? categoryId,
    String? note,
  }) async {
    try {
      final data = <String, dynamic>{
        'account_id': accountId,
        'type': type.value,
        'amount': amount.toStringAsFixed(2),
        'date': _dateFormat.format(date),
      };

      if (categoryId != null) data['category_id'] = categoryId;
      if (note != null) data['note'] = note;

      final response = await dio.post('/transactions', data: data);
      return TransactionModel.fromJson(response.data);
    } on DioException catch (e) {
      handleDioError(e);
    }
  }

  @override
  Future<List<TransactionModel>> getTransactions({
    TransactionFilter filter = const TransactionFilter(),
    int? limit,
    int? offset,
  }) async {
    try {
      final queryParams = _buildTransactionParams(filter);

      if (limit != null) queryParams['limit'] = limit;
      if (offset != null) queryParams['offset'] = offset;

      final response = await dio.get(
        '/transactions',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      final list = response.data as List<dynamic>;
      return list
          .map(
            (json) => TransactionModel.fromJson(json as Map<String, dynamic>),
          )
          .toList();
    } on DioException catch (e) {
      handleDioError(e);
    }
  }

  @override
  Future<TransactionSummaryModel> getTransactionSummary({
    TransactionFilter filter = const TransactionFilter(),
  }) async {
    try {
      final queryParams = _buildSummaryParams(filter);

      final response = await dio.get(
        '/transactions/summary',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      return TransactionSummaryModel.fromJson(response.data);
    } on DioException catch (e) {
      handleDioError(e);
    }
  }

  @override
  Future<List<DailySummaryModel>> getDailySummary({
    required String month,
    int? accountId,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'month': month,
      };

      if (accountId != null) queryParams['account_id'] = accountId;

      final response = await dio.get(
        '/transactions/daily-summary',
        queryParameters: queryParams,
      );
      final list = response.data as List<dynamic>;
      return list
          .map(
            (json) => DailySummaryModel.fromJson(json as Map<String, dynamic>),
          )
          .toList();
    } on DioException catch (e) {
      handleDioError(e);
    }
  }

  @override
  Future<TransferResultModel> createTransfer({
    required int fromAccountId,
    required int toAccountId,
    required double amount,
    required DateTime date,
    String? note,
  }) async {
    try {
      final data = <String, dynamic>{
        'from_account_id': fromAccountId,
        'to_account_id': toAccountId,
        'amount': amount.toStringAsFixed(2),
        'date': _dateFormat.format(date),
      };

      if (note != null) data['note'] = note;

      final response = await dio.post('/transactions/transfer', data: data);
      return TransferResultModel.fromJson(response.data);
    } on DioException catch (e) {
      handleDioError(e);
    }
  }

  @override
  Future<TransactionModel> getTransactionById(int transactionId) async {
    try {
      final response = await dio.get('/transactions/$transactionId');
      return TransactionModel.fromJson(response.data);
    } on DioException catch (e) {
      handleDioError(e);
    }
  }

  @override
  Future<TransactionModel> updateTransaction({
    required int transactionId,
    int? accountId,
    int? categoryId,
    double? amount,
    DateTime? date,
    String? note,
  }) async {
    try {
      final data = <String, dynamic>{};

      if (accountId != null) data['account_id'] = accountId;
      if (categoryId != null) data['category_id'] = categoryId;
      if (amount != null) data['amount'] = amount.toStringAsFixed(2);
      if (date != null) data['date'] = _dateFormat.format(date);
      if (note != null) data['note'] = note;

      final response = await dio.put(
        '/transactions/$transactionId',
        data: data,
      );
      return TransactionModel.fromJson(response.data);
    } on DioException catch (e) {
      handleDioError(e);
    }
  }

  @override
  Future<void> deleteTransaction(int transactionId) async {
    try {
      await dio.delete('/transactions/$transactionId');
    } on DioException catch (e) {
      handleDioError(e);
    }
  }

  Map<String, dynamic> _buildTransactionParams(TransactionFilter filter) {
    return <String, dynamic>{
      if (filter.accountId != null) 'account_id': filter.accountId,
      if (filter.categoryId != null) 'category_id': filter.categoryId,
      if (filter.type != null) 'type': filter.type!.value,
      if (filter.startDate != null)
        'start_date': _dateFormat.format(filter.startDate!),
      if (filter.endDate != null)
        'end_date': _dateFormat.format(filter.endDate!),
    };
  }

  Map<String, dynamic> _buildSummaryParams(TransactionFilter filter) {
    return <String, dynamic>{
      if (filter.accountId != null) 'account_id': filter.accountId,
      if (filter.categoryId != null) 'category_id': filter.categoryId,
      if (filter.startDate != null)
        'start_date': _dateFormat.format(filter.startDate!),
      if (filter.endDate != null)
        'end_date': _dateFormat.format(filter.endDate!),
    };
  }
}