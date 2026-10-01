import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:key_starter/features/chord_recognition/presentation/providers/chord_inversion_settings_notifier.dart';
import 'package:key_starter/presentation/widgets/settings_stepper_row.dart';

/// Implémentation de [SettingsStepperRow] liée à [chordInversionSettingsProvider].
class ChordInversionCountRow extends SettingsStepperRow {
  const ChordInversionCountRow({super.key});

  @override
  String get label => "Nombre d'accords";

  @override
  int value(WidgetRef ref) =>
      ref.watch(chordInversionSettingsProvider).noteCount;

  @override
  void onDecrement(WidgetRef ref) =>
      ref.read(chordInversionSettingsProvider.notifier).decrementNoteCount();

  @override
  void onIncrement(WidgetRef ref) =>
      ref.read(chordInversionSettingsProvider.notifier).incrementNoteCount();
}
