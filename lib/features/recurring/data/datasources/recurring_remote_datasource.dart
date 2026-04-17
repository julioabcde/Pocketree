import 'package:dio/dio.dart';
import 'package:pocketree/core/error/dio_error_handler.dart';
import 'package:pocketree/features/recurring/data/models/recurring_transaction_model.dart';

abstract class RecurringRemoteDatasource {
  Future<List<RecurringTransactionModel>> getRecurringTransactions();
  Future<void> deleteRecurringTransaction(int recurringId);
  Future<RecurringTransactionModel> createRecurringTransaction({
    required int accountId,
    required String type,
    required double amount,
    required String frequency,
    required String startDate,
    int? categoryId,
    String? endDate,
    String timezone = 'UTC',
    bool autoCreate = true,
    String? note,
    int? dayOfWeek,
    int? dayOfMonth,
    int? monthOfYear,
  });
  Future<RecurringTransactionModel> updateRecurringTransaction(
    int recurringId, {
    int? categoryId,
    double? amount,
    String? endDate,
    String? timezone,
    bool? autoCreate,
    int? maxOccurrences,
    bool? isActive,
    String? note,
  });
  Future<void> executeRecurringTransaction(int recurringId);
}

class RecurringRemoteDatasourceImpl implements RecurringRemoteDatasource {
  final Dio dio;
  RecurringRemoteDatasourceImpl(this.dio);

  @override
  Future<List<RecurringTransactionModel>> getRecurringTransactions() async {
    try {
      final response = await dio.get('/recurring');
      final list = response.data as List<dynamic>;
      return list
          .map((json) => RecurringTransactionModel.fromJson(
                json as Map<String, dynamic>,
              ))
          .toList();
    } on DioException catch (e) {
      handleDioError(e);
    }
  }

  @override
  Future<void> deleteRecurringTransaction(int recurringId) async {
    try {
      await dio.delete('/recurring/$recurringId');
    } on DioException catch (e) {
      handleDioError(e);
    }
  }

  @override
  Future<RecurringTransactionModel> createRecurringTransaction({
    required int accountId,
    required String type,
    required double amount,
    required String frequency,
    required String startDate,
    int? categoryId,
    String? endDate,
    String timezone = 'UTC',
    bool autoCreate = true,
    String? note,
    int? dayOfWeek,
    int? dayOfMonth,
    int? monthOfYear,
  }) async {
    try {
      final body = {
        'account_id': accountId,
        'type': type,
        'amount': amount,
        'frequency': frequency,
        'start_date': startDate,
        'timezone': timezone,
        'auto_create': autoCreate,
        'category_id': ?categoryId,
        'end_date': ?endDate,
        'note': ?note,
        'day_of_week': ?dayOfWeek,
        'day_of_month': ?dayOfMonth,
        'month_of_year': ?monthOfYear,
      };
      final response = await dio.post('/recurring', data: body);
      return RecurringTransactionModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      handleDioError(e);
    }
  }

  @override
  Future<RecurringTransactionModel> updateRecurringTransaction(
    int recurringId, {
    int? categoryId,
    double? amount,
    String? endDate,
    String? timezone,
    bool? autoCreate,
    int? maxOccurrences,
    bool? isActive,
    String? note,
  }) async {
    try {
      final body = {
        'category_id': ?categoryId,
        'amount': ?amount,
        'end_date': ?endDate,
        'timezone': ?timezone,
        'auto_create': ?autoCreate,
        'max_occurrences': ?maxOccurrences,
        'is_active': ?isActive,
        'note': ?note,
      };
      final response = await dio.put('/recurring/$recurringId', data: body);
      return RecurringTransactionModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      handleDioError(e);
    }
  }

  @override
  Future<void> executeRecurringTransaction(int recurringId) async {
    try {
      await dio.post('/recurring/$recurringId/execute');
    } on DioException catch (e) {
      handleDioError(e);
    }
  }
}