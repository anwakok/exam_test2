import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/network/dio_client.dart';
import 'features/ai/data/ai_cache_service.dart';
import 'features/ai/data/ai_service.dart';
import 'features/cards/data/datasources/card_local_datasource.dart';
import 'features/cards/data/datasources/card_remote_datasource.dart';
import 'features/cards/data/repositories/card_repository_impl.dart';
import 'features/cards/domain/repositories/card_repository.dart';
import 'features/cards/domain/usecases/get_cards.dart';
import 'features/cards/presentation/bloc/card_bloc.dart';
import 'features/duel/duel_bloc.dart';
import 'features/scan/data/card_scanner_service.dart';
import 'features/settings/data/settings_service.dart';
import 'features/user/data/sqlite_user_repository.dart';

final getIt = GetIt.instance;

Future<void> initDependencies() async {
  // Reset if already initialized (for testing)
  if (getIt.isRegistered<Dio>()) {
    getIt.reset();
  }

  // Core
  getIt.registerLazySingleton<Dio>(() => Dio());
  getIt.registerLazySingleton<DioClient>(() => DioClient(getIt()));

  // Data Sources
  getIt.registerLazySingleton<CardRemoteDatasource>(
    () => CardRemoteDatasourceImpl(getIt<DioClient>().dio),
  );
  getIt.registerLazySingleton<CardLocalDatasource>(
    () => CardLocalDatasourceImpl(),
  );

  // Repositories
  getIt.registerLazySingleton<CardRepository>(
    () => CardRepositoryImpl(remote: getIt(), local: getIt()),
  );

  // Use Cases
  getIt.registerLazySingleton(() => GetCards(getIt()));

  // BLoCs
  getIt.registerFactory(() => CardBloc(getIt()));
  getIt.registerFactory(() => DuelBloc());

  // Services
  getIt.registerLazySingleton(() => SettingsService());
  getIt.registerLazySingleton(() => CardScannerService());
  getIt.registerLazySingleton<AIService>(
    () => GroqAIService(getIt<DioClient>().dio),
  );
  getIt.registerLazySingleton(() => AICacheService(getIt()));

  // SQLite Repository
  getIt.registerLazySingleton(() => SQLiteUserRepository());

  // Initialize
  await getIt<SettingsService>().init();
  await Hive.initFlutter();
  await getIt<AICacheService>().init();
}
