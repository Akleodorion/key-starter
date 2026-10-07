import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:key_starter/core/enums/clef_mode.dart';
import 'package:key_starter/core/widgets/note_range_section.dart';
import 'package:key_starter/features/note_recognition/presentation/providers/defilement_settings_notifier.dart';

/// Implémentation de [NoteRangeSection] liée à [defilementSettingsProvider].
class DefilementRangeSection extends NoteRangeSection {
  const DefilementRangeSection({super.key});

  @override
  ClefMode clef(WidgetRef ref) => ref.watch(defilementSettingsProvider).clef;

  @override
  int minNoteStep(WidgetRef ref) =>
      ref.watch(defilementSettingsProvider).minNoteStep;

  @override
  int maxNoteStep(WidgetRef ref) =>
      ref.watch(defilementSettingsProvider).maxNoteStep;

  @override
  void decrementMinNote(WidgetRef ref) =>
      ref.read(defilementSettingsProvider.notifier).decrementMinNote();

  @override
  void incrementMinNote(WidgetRef ref) =>
      ref.read(defilementSettingsProvider.notifier).incrementMinNote();

  @override
  void decrementMaxNote(WidgetRef ref) =>
      ref.read(defilementSettingsProvider.notifier).decrementMaxNote();

  @override
  void incrementMaxNote(WidgetRef ref) =>
      ref.read(defilementSettingsProvider.notifier).incrementMaxNote();
}
