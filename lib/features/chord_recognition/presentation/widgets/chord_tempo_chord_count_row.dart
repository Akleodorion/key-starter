import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:key_starter/features/chord_recognition/presentation/providers/chord_tempo_settings_notifier.dart';
import 'package:key_starter/presentation/widgets/settings_stepper_row.dart';

/// Implémentation de [SettingsStepperRow] liée à [chordTempoSettingsProvider].
class ChordTempoChordCountRow extends SettingsStepperRow {
  const ChordTempoChordCountRow({super.key});

  @override
  String get label => 'Nombre d\'accords';

  @override
  int value(WidgetRef ref) => ref.watch(chordTempoSettingsProvider).noteCount;

  @override
  void onDecrement(WidgetRef ref) =>
      ref.read(chordTempoSettingsProvider.notifier).decrementNoteCount();

  @override
  void onIncrement(WidgetRef ref) =>
      ref.read(chordTempoSettingsProvider.notifier).incrementNoteCount();
}
