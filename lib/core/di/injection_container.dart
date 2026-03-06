import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:pocketree/core/network/dio_client.dart';
import 'package:pocketree/core/storage/token_storage.dart';
import 'package:pocketree/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:pocketree/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:pocketree/features/auth/domain/repositories/auth_repository.dart';
import 'package:pocketree/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:pocketree/features/auth/domain/usecases/log_in_usecase.dart';
import 'package:pocketree/features/auth/domain/usecases/log_out_usecase.dart';
import 'package:pocketree/features/auth/domain/usecases/register_usecase.dart';
import 'package:pocketree/features/auth/presentation/bloc/auth_bloc.dart';

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

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl(), sl()),
  );

  // Use cases
  sl.registerFactory(() => LogInUseCase(sl()));
  sl.registerFactory(() => LogOutUseCase(sl()));
  sl.registerFactory(() => RegisterUseCase(sl()));
  sl.registerFactory(() => GetCurrentUserUseCase(sl()));

  // BLoC
  sl.registerFactory(
    () => AuthBloc(
      logIn: sl(),
      logOut: sl(),
      register: sl(),
      getCurrentUser: sl(),
    ),
  );
}
