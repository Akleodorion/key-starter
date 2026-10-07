import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:key_starter/core/enums/clef_mode.dart';
import 'package:key_starter/core/widgets/note_range_section.dart';
import 'package:key_starter/features/chord_recognition/presentation/providers/chord_tempo_settings_notifier.dart';

/// Implémentation de [NoteRangeSection] liée à [chordTempoSettingsProvider].
class ChordTempoRangeSection extends NoteRangeSection {
  const ChordTempoRangeSection({super.key});

  @override
  String get hint => 'choisis la fondamentale la plus grave et la plus aiguë';

  @override
  ClefMode clef(WidgetRef ref) => ref.watch(chordTempoSettingsProvider).clef;

  @override
  int minNoteStep(WidgetRef ref) =>
      ref.watch(chordTempoSettingsProvider).minNoteStep;

  @override
  int maxNoteStep(WidgetRef ref) =>
      ref.watch(chordTempoSettingsProvider).maxNoteStep;

  @override
  void decrementMinNote(WidgetRef ref) =>
      ref.read(chordTempoSettingsProvider.notifier).decrementMinNote();

  @override
  void incrementMinNote(WidgetRef ref) =>
      ref.read(chordTempoSettingsProvider.notifier).incrementMinNote();

  @override
  void decrementMaxNote(WidgetRef ref) =>
      ref.read(chordTempoSettingsProvider.notifier).decrementMaxNote();

  @override
  void incrementMaxNote(WidgetRef ref) =>
      ref.read(chordTempoSettingsProvider.notifier).incrementMaxNote();
}
