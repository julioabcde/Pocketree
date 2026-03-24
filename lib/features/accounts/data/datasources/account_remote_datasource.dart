import 'package:dio/dio.dart';
import 'package:pocketree/core/error/dio_error_handler.dart';
import 'package:pocketree/features/accounts/data/models/account_model.dart';
import 'package:pocketree/features/accounts/data/models/account_summary_model.dart';
import 'package:pocketree/features/accounts/domain/entities/account_type.dart';


abstract class AccountRemoteDatasource {
  Future<AccountModel> createAccount({
    required String name,
    required AccountType type,
    double? initialBalance,
  });

  Future<List<AccountModel>> getAccounts();

  Future<AccountSummaryModel> getAccountSummary();

  Future<AccountModel> getAccountById(int accountId);

  Future<AccountModel> updateAccount({
    required int accountId,
    String? name,
    AccountType? type,
  });

  Future<void> deleteAccount(int accountId);
}

class AccountRemoteDatasourceImpl implements AccountRemoteDatasource {
  final Dio dio;

  AccountRemoteDatasourceImpl(this.dio);

  @override
  Future<AccountModel> createAccount({
    required String name,
    required AccountType type,
    double? initialBalance,
  }) async {
    try {
      final data = <String, dynamic>{
        'name': name,
        'type': type.value,
      };

      if (initialBalance != null) {
        data['initial_balance'] = initialBalance.toStringAsFixed(2);
      }

      final response = await dio.post('/accounts', data: data);
      return AccountModel.fromJson(response.data);
    } on DioException catch (e) {
      handleDioError(e);
    }
  }

  @override
  Future<List<AccountModel>> getAccounts() async {
    try {
      final response = await dio.get('/accounts');
      final list = response.data as List<dynamic>;
      return list
          .map((json) => AccountModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      handleDioError(e);
    }
  }

  @override
  Future<AccountSummaryModel> getAccountSummary() async {
    try {
      final response = await dio.get('/accounts/summary');
      return AccountSummaryModel.fromJson(response.data);
    } on DioException catch (e) {
      handleDioError(e);
    }
  }

  @override
  Future<AccountModel> getAccountById(int accountId) async {
    try {
      final response = await dio.get('/accounts/$accountId');
      return AccountModel.fromJson(response.data);
    } on DioException catch (e) {
      handleDioError(e);
    }
  }

  @override
  Future<AccountModel> updateAccount({
    required int accountId,
    String? name,
    AccountType? type,
  }) async {
    try {
      final data = <String, dynamic>{};

      if (name != null) data['name'] = name;
      if (type != null) data['type'] = type.value;

      final response = await dio.put('/accounts/$accountId', data: data);
      return AccountModel.fromJson(response.data);
    } on DioException catch (e) {
      handleDioError(e);
    }
  }

  @override
  Future<void> deleteAccount(int accountId) async {
    try {
      await dio.delete('/accounts/$accountId');
    } on DioException catch (e) {
      handleDioError(e);
    }
  }
}