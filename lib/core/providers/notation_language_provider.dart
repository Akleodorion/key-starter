import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:key_starter/core/enums/note_language.dart';
import 'package:key_starter/core/providers/app_settings_datasource_provider.dart';

final notationLanguageProvider =
    NotifierProvider<NotationLanguageNotifier, NoteLanguage>(
      NotationLanguageNotifier.new,
    );

class NotationLanguageNotifier extends Notifier<NoteLanguage> {
  @override
  NoteLanguage build() =>
      ref.read(appSettingsLocalDataSourceProvider).notationLanguage;

  void setLanguage(NoteLanguage language) {
    state = language;
    ref.read(appSettingsLocalDataSourceProvider).saveNotationLanguage(language);
  }
}
