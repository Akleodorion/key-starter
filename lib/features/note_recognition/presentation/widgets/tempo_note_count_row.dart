import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:key_starter/features/note_recognition/presentation/providers/tempo_settings_notifier.dart';
import 'package:key_starter/presentation/widgets/settings_stepper_row.dart';

/// Implémentation de [SettingsStepperRow] liée à [tempoSettingsProvider].
class TempoNoteCountRow extends SettingsStepperRow {
  const TempoNoteCountRow({super.key});

  @override
  String get label => 'Nombre de notes';

  @override
  int value(WidgetRef ref) => ref.watch(tempoSettingsProvider).noteCount;

  @override
  void onDecrement(WidgetRef ref) =>
      ref.read(tempoSettingsProvider.notifier).decrementNoteCount();

  @override
  void onIncrement(WidgetRef ref) =>
      ref.read(tempoSettingsProvider.notifier).incrementNoteCount();
}
