import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:key_starter/core/enums/clef_mode.dart';
import 'package:key_starter/core/widgets/note_range_section.dart';
import 'package:key_starter/features/note_recognition/presentation/providers/flashcard_settings_notifier.dart';

/// Implémentation de [NoteRangeSection] liée à [flashcardSettingsProvider].
class FlashcardRangeSection extends NoteRangeSection {
  const FlashcardRangeSection({super.key});

  @override
  ClefMode clef(WidgetRef ref) => ref.watch(flashcardSettingsProvider).clef;

  @override
  int minNoteStep(WidgetRef ref) =>
      ref.watch(flashcardSettingsProvider).minNoteStep;

  @override
  int maxNoteStep(WidgetRef ref) =>
      ref.watch(flashcardSettingsProvider).maxNoteStep;

  @override
  void decrementMinNote(WidgetRef ref) =>
      ref.read(flashcardSettingsProvider.notifier).decrementMinNote();

  @override
  void incrementMinNote(WidgetRef ref) =>
      ref.read(flashcardSettingsProvider.notifier).incrementMinNote();

  @override
  void decrementMaxNote(WidgetRef ref) =>
      ref.read(flashcardSettingsProvider.notifier).decrementMaxNote();

  @override
  void incrementMaxNote(WidgetRef ref) =>
      ref.read(flashcardSettingsProvider.notifier).incrementMaxNote();
}
