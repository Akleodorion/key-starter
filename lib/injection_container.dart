import 'package:get_it/get_it.dart';
import 'package:key_starter/features/note_recognition/data/datasources/midi_datasource.dart';
import 'package:key_starter/features/note_recognition/data/repositories/note_recognition_repository_impl.dart';
import 'package:key_starter/features/note_recognition/domain/repositories/note_recognition_repository.dart';
import 'package:key_starter/features/note_recognition/domain/usecases/recognize_note_usecase.dart';
import 'package:key_starter/features/session/data/datasources/session_local_datasource.dart';
import 'package:key_starter/features/session/data/repositories/session_repository_impl.dart';
import 'package:key_starter/features/session/domain/repositories/session_repository.dart';
import 'package:key_starter/features/session/domain/usecases/complete_session_usecase.dart';
import 'package:key_starter/features/session/domain/usecases/create_session_usecase.dart';
import 'package:key_starter/features/session/domain/usecases/get_last_session_params_usecase.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  final prefs = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => prefs);

  // Note recognition
  sl.registerLazySingleton<MidiDataSource>(() => MidiDataSourceImpl());
  sl.registerLazySingleton<NoteRecognitionRepository>(
    () => NoteRecognitionRepositoryImpl(dataSource: sl()),
  );
  sl.registerFactory(() => RecognizeNoteUseCase(repository: sl()));

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
}
