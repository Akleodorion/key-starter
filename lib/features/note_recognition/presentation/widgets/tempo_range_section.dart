import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:key_starter/core/enums/clef_mode.dart';
import 'package:key_starter/core/widgets/note_range_section.dart';
import 'package:key_starter/features/note_recognition/presentation/providers/tempo_settings_notifier.dart';

/// Implémentation de [NoteRangeSection] liée à [tempoSettingsProvider].
class TempoRangeSection extends NoteRangeSection {
  const TempoRangeSection({super.key});

  @override
  ClefMode clef(WidgetRef ref) => ref.watch(tempoSettingsProvider).clef;

  @override
  int minNoteStep(WidgetRef ref) =>
      ref.watch(tempoSettingsProvider).minNoteStep;

  @override
  int maxNoteStep(WidgetRef ref) =>
      ref.watch(tempoSettingsProvider).maxNoteStep;

  @override
  void decrementMinNote(WidgetRef ref) =>
      ref.read(tempoSettingsProvider.notifier).decrementMinNote();

  @override
  void incrementMinNote(WidgetRef ref) =>
      ref.read(tempoSettingsProvider.notifier).incrementMinNote();

  @override
  void decrementMaxNote(WidgetRef ref) =>
      ref.read(tempoSettingsProvider.notifier).decrementMaxNote();

  @override
  void incrementMaxNote(WidgetRef ref) =>
      ref.read(tempoSettingsProvider.notifier).incrementMaxNote();
}
