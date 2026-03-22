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
import 'package:pocketree/features/home/domain/usecases/get_home_data_usecase.dart';
import 'package:pocketree/features/home/presentation/bloc/home_bloc.dart';

final sl = GetIt.instance;

Future<void> setupDependencies() async {
  // Storage
  sl.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(),
  );
  sl.registerLazySingleton<TokenStorage>(() => TokenStorage(sl()));

  // Network
  sl.registerLazySingleton(() => DioClient.create(tokenStorage: sl()));

  // Datasources
  sl.registerLazySingleton<AuthRemoteDatasource>(
    () => AuthRemoteDatasourceImpl(sl()),
  );
  sl.registerLazySingleton<AccountRemoteDatasource>(
    () => AccountRemoteDatasourceImpl(sl()),
  );

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl(), sl()),
  );
  sl.registerLazySingleton<AccountRepository>(
    () => AccountRepositoryImpl(sl()),
  );

  // Use cases
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

  sl.registerFactory(() => GetHomeDataUseCase(sl()));

  // BLoC
  sl.registerFactory(
    () => AuthBloc(
      logIn: sl(),
      logOut: sl(),
      register: sl(),
      getCurrentUser: sl(),
    ),
  );

  // BLoC
  sl.registerFactory(
    () => AccountBloc(
      getAccounts: sl(),
      getAccountSummary: sl(),
      createAccount: sl(),
      updateAccount: sl(),
      deleteAccount: sl(),
    ),
  );

  sl.registerFactory(() => HomeBloc(getHomeData: sl()));
}
