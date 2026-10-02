import 'package:flutter/material.dart';
import 'package:key_starter/core/enums/note_language.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Réglages de l'app (page Réglages) gardés d'un lancement à l'autre.
///
/// Contrat : chaque getter renvoie la valeur sauvegardée, ou la valeur par
/// défaut si rien n'est sauvegardé ou si la valeur est illisible ; chaque
/// `save*` enregistre la nouvelle valeur. Les lectures sont synchrones pour
/// que le bon thème s'affiche dès la première image.
///
/// ```dart
/// final dataSource = AppSettingsLocalDataSourceImpl(preferences: prefs);
/// final themeMode = dataSource.themeMode;
/// await dataSource.saveThemeMode(ThemeMode.dark);
/// ```
///
/// Voir aussi : [AppSettingsLocalDataSourceImpl]
abstract interface class AppSettingsLocalDataSource {
  /// Thème choisi ; [ThemeMode.system] par défaut.
  ThemeMode get themeMode;

  /// Langue des noms de notes ; [NoteLanguage.fr] par défaut.
  NoteLanguage get notationLanguage;

  /// Affichage de l'aide aux noms de notes ; désactivé par défaut.
  bool get showNoteAid;

  /// Enregistre le thème choisi.
  Future<void> saveThemeMode(ThemeMode themeMode);

  /// Enregistre la langue des noms de notes.
  Future<void> saveNotationLanguage(NoteLanguage language);

  /// Enregistre l'affichage de l'aide aux noms de notes.
  Future<void> saveShowNoteAid(bool showNoteAid);
}

/// Implémentation de [AppSettingsLocalDataSource] sur les SharedPreferences.
class AppSettingsLocalDataSourceImpl implements AppSettingsLocalDataSource {
  final SharedPreferences preferences;

  const AppSettingsLocalDataSourceImpl({required this.preferences});

  static const _themeModeKey = 'settings_theme_mode';
  static const _notationLanguageKey = 'settings_notation_language';
  static const _showNoteAidKey = 'settings_show_note_aid';

  @override
  ThemeMode get themeMode =>
      ThemeMode.values.asNameMap()[_savedValue<String>(_themeModeKey)] ??
      ThemeMode.system;

  @override
  NoteLanguage get notationLanguage =>
      NoteLanguage.values.asNameMap()[_savedValue<String>(
        _notationLanguageKey,
      )] ??
      NoteLanguage.fr;

  @override
  bool get showNoteAid => _savedValue<bool>(_showNoteAidKey) ?? false;

  // Une valeur d'un autre type (ancienne version, corruption) est ignorée
  // plutôt que de faire planter le démarrage.
  T? _savedValue<T>(String key) {
    final value = preferences.get(key);
    return value is T ? value : null;
  }

  @override
  Future<void> saveThemeMode(ThemeMode themeMode) =>
      preferences.setString(_themeModeKey, themeMode.name);

  @override
  Future<void> saveNotationLanguage(NoteLanguage language) =>
      preferences.setString(_notationLanguageKey, language.name);

  @override
  Future<void> saveShowNoteAid(bool showNoteAid) =>
      preferences.setBool(_showNoteAidKey, showNoteAid);
}
