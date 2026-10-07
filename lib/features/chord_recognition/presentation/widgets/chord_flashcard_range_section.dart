import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:key_starter/core/enums/clef_mode.dart';
import 'package:key_starter/core/widgets/note_range_section.dart';
import 'package:key_starter/features/chord_recognition/presentation/providers/chord_flashcard_settings_notifier.dart';

/// Implémentation de [NoteRangeSection] liée à [chordFlashcardSettingsProvider].
class ChordFlashcardRangeSection extends NoteRangeSection {
  const ChordFlashcardRangeSection({super.key});

  @override
  String get hint => 'choisis la fondamentale la plus grave et la plus aiguë';

  @override
  ClefMode clef(WidgetRef ref) =>
      ref.watch(chordFlashcardSettingsProvider).clef;

  @override
  int minNoteStep(WidgetRef ref) =>
      ref.watch(chordFlashcardSettingsProvider).minNoteStep;

  @override
  int maxNoteStep(WidgetRef ref) =>
      ref.watch(chordFlashcardSettingsProvider).maxNoteStep;

  @override
  void decrementMinNote(WidgetRef ref) =>
      ref.read(chordFlashcardSettingsProvider.notifier).decrementMinNote();

  @override
  void incrementMinNote(WidgetRef ref) =>
      ref.read(chordFlashcardSettingsProvider.notifier).incrementMinNote();

  @override
  void decrementMaxNote(WidgetRef ref) =>
      ref.read(chordFlashcardSettingsProvider.notifier).decrementMaxNote();

  @override
  void incrementMaxNote(WidgetRef ref) =>
      ref.read(chordFlashcardSettingsProvider.notifier).incrementMaxNote();
}
