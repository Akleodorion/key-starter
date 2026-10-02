import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:key_starter/core/datasources/app_settings_local_datasource.dart';

/// Source des réglages de l'app. En mémoire par défaut ; `main()` la remplace
/// par la source sauvegardée dans les SharedPreferences.
final appSettingsLocalDataSourceProvider = Provider<AppSettingsLocalDataSource>(
  (ref) => InMemoryAppSettingsLocalDataSource(),
);
