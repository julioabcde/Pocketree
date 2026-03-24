// lib/core/di/injection_container.dart

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:pocketree/core/network/dio_client.dart';
import 'package:pocketree/core/storage/token_storage.dart';
import 'package:pocketree/features/accounts/data/datasources/account_remote_datasource.dart';
import 'package:pocketree/features/accounts/data/repositories/account_repository_impl.dart';
import 'package:pocketree/features/accounts/domain/repositories/account_repository.dart';
import 'package:pocketree/features/accounts/domain/usecases/create_account_usecase.dart';
import 'package:pocketree/features/accounts/domain/usecases/delete_account_usecase.dart';
import 'package:pocketree/features/accounts/domain/usecases/get_account_by_id_usecase.dart';
import 'package:pocketree/features/accounts/domain/usecases/get_account_summary_usecase.dart';
import 'package:pocketree/features/accounts/domain/usecases/get_accounts_usecase.dart';
import 'package:pocketree/features/accounts/domain/usecases/update_account_usecase.dart';
import 'package:pocketree/features/accounts/presentation/bloc/account_bloc.dart';
import 'package:pocketree/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:pocketree/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:pocketree/features/auth/domain/repositories/auth_repository.dart';
import 'package:pocketree/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:pocketree/features/auth/domain/usecases/log_in_usecase.dart';
import 'package:pocketree/features/auth/domain/usecases/log_out_usecase.dart';
import 'package:pocketree/features/auth/domain/usecases/register_usecase.dart';
import 'package:pocketree/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:pocketree/features/categories/data/datasources/category_remote_datasource.dart';
import 'package:pocketree/features/categories/data/repositories/category_repository_impl.dart';
import 'package:pocketree/features/categories/domain/repositories/category_repository.dart';
import 'package:pocketree/features/categories/domain/usecases/create_category_usecase.dart';
import 'package:pocketree/features/categories/domain/usecases/delete_category_usecase.dart';
import 'package:pocketree/features/categories/domain/usecases/get_categories_usecase.dart';
import 'package:pocketree/features/categories/domain/usecases/get_category_by_id_usecase.dart';
import 'package:pocketree/features/categories/domain/usecases/update_category_usecase.dart';
import 'package:pocketree/features/categories/presentation/bloc/category_bloc.dart';
import 'package:pocketree/features/home/domain/usecases/get_home_data_usecase.dart';
import 'package:pocketree/features/home/presentation/bloc/home_bloc.dart';
import 'package:pocketree/features/transactions/data/datasources/transaction_remote_datasource.dart';
import 'package:pocketree/features/transactions/data/repositories/transaction_repository_impl.dart';
import 'package:pocketree/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:pocketree/features/transactions/domain/usecases/create_transaction_usecase.dart';
import 'package:pocketree/features/transactions/domain/usecases/create_transfer_usecase.dart';
import 'package:pocketree/features/transactions/domain/usecases/delete_transaction_usecase.dart';
import 'package:pocketree/features/transactions/domain/usecases/get_transaction_by_id_usecase.dart';
import 'package:pocketree/features/transactions/domain/usecases/get_transaction_summary_usecase.dart';
import 'package:pocketree/features/transactions/domain/usecases/get_transactions_usecase.dart';
import 'package:pocketree/features/transactions/domain/usecases/update_transaction_usecase.dart';
import 'package:pocketree/features/transactions/presentation/bloc/transaction_bloc.dart';

final sl = GetIt.instance;

Future<void> setupDependencies() async {
  // Storage
  sl.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(),
  );
  sl.registerLazySingleton<TokenStorage>(() => TokenStorage(sl()));

  // Network
  sl.registerLazySingleton(() => DioClient.create(tokenStorage: sl()));

  //  Datasources 
  sl.registerLazySingleton<AuthRemoteDatasource>(
    () => AuthRemoteDatasourceImpl(sl()),
  );
  sl.registerLazySingleton<AccountRemoteDatasource>(
    () => AccountRemoteDatasourceImpl(sl()),
  );
  sl.registerLazySingleton<CategoryRemoteDatasource>(
    () => CategoryRemoteDatasourceImpl(sl()),
  );
  sl.registerLazySingleton<TransactionRemoteDatasource>(
    () => TransactionRemoteDatasourceImpl(sl()),
  );

  //  Repositories 
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl(), sl()),
  );
  sl.registerLazySingleton<AccountRepository>(
    () => AccountRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<CategoryRepository>(
    () => CategoryRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<TransactionRepository>(
    () => TransactionRepositoryImpl(sl()),
  );

  //  Use Cases 
  sl.registerFactory(() => LogInUseCase(sl()));
  sl.registerFactory(() => LogOutUseCase(sl()));
  sl.registerFactory(() => RegisterUseCase(sl()));
  sl.registerFactory(() => GetCurrentUserUseCase(sl()));

  sl.registerFactory(() => GetAccountsUseCase(sl()));
  sl.registerFactory(() => GetAccountSummaryUseCase(sl()));
  sl.registerFactory(() => GetAccountByIdUseCase(sl()));
  sl.registerFactory(() => CreateAccountUseCase(sl()));
  sl.registerFactory(() => UpdateAccountUseCase(sl()));
  sl.registerFactory(() => DeleteAccountUseCase(sl()));

  sl.registerFactory(() => GetCategoriesUseCase(sl()));
  sl.registerFactory(() => GetCategoryByIdUseCase(sl()));
  sl.registerFactory(() => CreateCategoryUseCase(sl()));
  sl.registerFactory(() => UpdateCategoryUseCase(sl()));
  sl.registerFactory(() => DeleteCategoryUseCase(sl()));

  sl.registerFactory(() => GetTransactionsUseCase(sl()));
  sl.registerFactory(() => GetTransactionByIdUseCase(sl()));
  sl.registerFactory(() => GetTransactionSummaryUseCase(sl()));
  sl.registerFactory(() => CreateTransactionUseCase(sl()));
  sl.registerFactory(() => CreateTransferUseCase(sl()));
  sl.registerFactory(() => UpdateTransactionUseCase(sl()));
  sl.registerFactory(() => DeleteTransactionUseCase(sl()));

  sl.registerFactory(() => GetHomeDataUseCase(sl(), sl()));

  //  BLoCs 
  sl.registerFactory(
    () => AuthBloc(
      logIn: sl(),
      logOut: sl(),
      register: sl(),
      getCurrentUser: sl(),
    ),
  );

  sl.registerFactory(
    () => AccountBloc(
      getAccounts: sl(),
      getAccountSummary: sl(),
      createAccount: sl(),
      updateAccount: sl(),
      deleteAccount: sl(),
    ),
  );

  sl.registerFactory(
    () => CategoryBloc(
      getCategories: sl(),
      createCategory: sl(),
      updateCategory: sl(),
      deleteCategory: sl(),
    ),
  );

  sl.registerFactory(
    () => TransactionBloc(
      getTransactions: sl(),
      getTransactionSummary: sl(),
      createTransaction: sl(),
      updateTransaction: sl(),
      deleteTransaction: sl(),
      createTransfer: sl(),
    ),
  );

  sl.registerFactory(() => HomeBloc(getHomeData: sl()));
}