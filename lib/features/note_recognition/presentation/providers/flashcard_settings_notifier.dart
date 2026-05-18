import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:key_starter/core/enums/clef_mode.dart';
import 'package:key_starter/features/note_recognition/presentation/providers/flashcard_settings_state.dart';

final flashcardSettingsProvider =
    NotifierProvider<FlashcardSettingsNotifier, FlashcardSettings>(
      FlashcardSettingsNotifier.new,
    );

class FlashcardSettingsNotifier extends Notifier<FlashcardSettings> {
  static const int _minNoteCount = 10;
  static const int _maxNoteCount = 100;

  @override
  FlashcardSettings build() =>
      const FlashcardSettings(clef: ClefMode.treble, noteCount: 15);

  void setClef(ClefMode clef) => state = state.copyWith(clef: clef);

  void incrementNoteCount() {
    if (state.noteCount < _maxNoteCount) {
      state = state.copyWith(noteCount: state.noteCount + 5);
    }
  }

  void decrementNoteCount() {
    if (state.noteCount > _minNoteCount) {
      state = state.copyWith(noteCount: state.noteCount - 5);
    }
  }
}
