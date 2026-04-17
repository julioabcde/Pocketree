import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:pocketree/core/error/dio_error_handler.dart';
import 'package:pocketree/features/reports/data/models/account_breakdown_model.dart';
import 'package:pocketree/features/reports/data/models/cashflow_trend_item_model.dart';
import 'package:pocketree/features/reports/data/models/category_breakdown_model.dart';
import 'package:pocketree/features/reports/data/models/period_comparison_model.dart';
import 'package:pocketree/features/reports/data/models/report_overview_model.dart';
import 'package:pocketree/features/reports/data/models/top_transaction_model.dart';

abstract class ReportsRemoteDatasource {
  Future<ReportOverviewModel> getOverview({
    required DateTime startDate,
    required DateTime endDate,
    int? accountId,
  });

  Future<List<CashflowTrendItemModel>> getCashflowTrend({
    required DateTime startDate,
    required DateTime endDate,
    int? accountId,
    String groupBy = 'day',
  });

  Future<CategoryBreakdownModel> getCategoryBreakdown({
    required DateTime startDate,
    required DateTime endDate,
    int? accountId,
    String type = 'expense',
    int topN = 10,
  });

  Future<AccountBreakdownModel> getAccountBreakdown({
    required DateTime startDate,
    required DateTime endDate,
    int? accountId,
    String type = 'expense',
  });

  Future<List<TopTransactionModel>> getTopTransactions({
    required DateTime startDate,
    required DateTime endDate,
    int? accountId,
    String type = 'expense',
    int limit = 5,
  });

  Future<PeriodComparisonModel> getPeriodComparison({
    required DateTime startDate,
    required DateTime endDate,
    int? accountId,
  });
}

class ReportsRemoteDatasourceImpl implements ReportsRemoteDatasource {
  final Dio dio;
  static final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  ReportsRemoteDatasourceImpl(this.dio);

  Map<String, dynamic> _baseParams(
    DateTime startDate,
    DateTime endDate, {
    int? accountId,
  }) {
    final params = <String, dynamic>{
      'start_date': _dateFormat.format(startDate),
      'end_date': _dateFormat.format(endDate),
    };
    if (accountId != null) params['account_id'] = accountId;
    return params;
  }

  @override
  Future<ReportOverviewModel> getOverview({
    required DateTime startDate,
    required DateTime endDate,
    int? accountId,
  }) async {
    try {
      final response = await dio.get(
        '/reports/overview',
        queryParameters: _baseParams(startDate, endDate, accountId: accountId),
      );
      return ReportOverviewModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      handleDioError(e);
    }
  }

  @override
  Future<List<CashflowTrendItemModel>> getCashflowTrend({
    required DateTime startDate,
    required DateTime endDate,
    int? accountId,
    String groupBy = 'day',
  }) async {
    try {
      final params = _baseParams(startDate, endDate, accountId: accountId);
      params['group_by'] = groupBy;
      final response = await dio.get(
        '/reports/cashflow-trend',
        queryParameters: params,
      );
      final list = response.data as List<dynamic>;
      return list
          .map(
            (e) => CashflowTrendItemModel.fromJson(e as Map<String, dynamic>),
          )
          .toList();
    } on DioException catch (e) {
      handleDioError(e);
    }
  }

  @override
  Future<CategoryBreakdownModel> getCategoryBreakdown({
    required DateTime startDate,
    required DateTime endDate,
    int? accountId,
    String type = 'expense',
    int topN = 10,
  }) async {
    try {
      final params = _baseParams(startDate, endDate, accountId: accountId);
      params['type'] = type;
      params['top_n'] = topN;
      final response = await dio.get(
        '/reports/category-breakdown',
        queryParameters: params,
      );
      return CategoryBreakdownModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      handleDioError(e);
    }
  }

  @override
  Future<AccountBreakdownModel> getAccountBreakdown({
    required DateTime startDate,
    required DateTime endDate,
    int? accountId,
    String type = 'expense',
  }) async {
    try {
      final params = _baseParams(startDate, endDate, accountId: accountId);
      params['type'] = type;
      final response = await dio.get(
        '/reports/account-breakdown',
        queryParameters: params,
      );
      return AccountBreakdownModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      handleDioError(e);
    }
  }

  @override
  Future<List<TopTransactionModel>> getTopTransactions({
    required DateTime startDate,
    required DateTime endDate,
    int? accountId,
    String type = 'expense',
    int limit = 5,
  }) async {
    try {
      final params = _baseParams(startDate, endDate, accountId: accountId);
      params['type'] = type;
      params['limit'] = limit;
      final response = await dio.get(
        '/reports/top-transactions',
        queryParameters: params,
      );
      final list = response.data as List<dynamic>;
      return list
          .map((e) => TopTransactionModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      handleDioError(e);
    }
  }

  @override
  Future<PeriodComparisonModel> getPeriodComparison({
    required DateTime startDate,
    required DateTime endDate,
    int? accountId,
  }) async {
    try {
      final response = await dio.get(
        '/reports/period-comparison',
        queryParameters: _baseParams(startDate, endDate, accountId: accountId),
      );
      return PeriodComparisonModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      handleDioError(e);
    }
  }
}
