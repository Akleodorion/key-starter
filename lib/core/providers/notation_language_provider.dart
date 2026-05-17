import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:key_starter/core/enums/note_language.dart';

final notationLanguageProvider =
    NotifierProvider<NotationLanguageNotifier, NoteLanguage>(NotationLanguageNotifier.new);

class NotationLanguageNotifier extends Notifier<NoteLanguage> {
  @override
  NoteLanguage build() => NoteLanguage.fr;

  void setLanguage(NoteLanguage language) => state = language;
}
