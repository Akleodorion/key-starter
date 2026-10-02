import 'package:get_it/get_it.dart';
import 'package:key_starter/features/session/data/datasources/session_local_datasource.dart';
import 'package:key_starter/features/session/data/repositories/session_repository_impl.dart';
import 'package:key_starter/features/session/domain/repositories/session_repository.dart';
import 'package:key_starter/features/session/domain/usecases/complete_session_usecase.dart';
import 'package:key_starter/features/session/domain/usecases/create_session_usecase.dart';
import 'package:key_starter/features/session/domain/usecases/get_last_session_params_usecase.dart';
import 'package:key_starter/features/song_practice/data/datasources/song_asset_datasource.dart';
import 'package:key_starter/features/song_practice/data/repositories/song_repository_impl.dart';
import 'package:key_starter/features/song_practice/domain/repositories/song_repository.dart';
import 'package:key_starter/features/song_practice/domain/usecases/load_song_usecase.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  final prefs = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => prefs);

  // Session
  sl.registerLazySingleton<SessionLocalDataSource>(
    () => SessionLocalDataSourceImpl(prefs: sl()),
  );
  sl.registerLazySingleton<SessionRepository>(
    () => SessionRepositoryImpl(dataSource: sl()),
  );
  sl.registerFactory(() => CreateSessionUseCase(repository: sl()));
  sl.registerFactory(() => CompleteSessionUseCase(repository: sl()));
  sl.registerFactory(() => GetLastSessionParamsUseCase(repository: sl()));

  // Morceaux
  sl.registerLazySingleton<SongAssetDataSource>(
    () => SongAssetDataSourceImpl(),
  );
  sl.registerLazySingleton<SongRepository>(
    () => SongRepositoryImpl(dataSource: sl()),
  );
  sl.registerFactory(() => LoadSongUseCase(repository: sl()));
}
