import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:key_starter/features/chord_recognition/presentation/providers/simple_chord_settings_notifier.dart';
import 'package:key_starter/presentation/widgets/settings_stepper_row.dart';

/// Implémentation de [SettingsStepperRow] liée à [simpleChordSettingsProvider].
class SimpleChordCountRow extends SettingsStepperRow {
  const SimpleChordCountRow({super.key});

  @override
  String get label => "Nombre d'accords";

  @override
  int value(WidgetRef ref) => ref.watch(simpleChordSettingsProvider).noteCount;

  @override
  void onDecrement(WidgetRef ref) =>
      ref.read(simpleChordSettingsProvider.notifier).decrementNoteCount();

  @override
  void onIncrement(WidgetRef ref) =>
      ref.read(simpleChordSettingsProvider.notifier).incrementNoteCount();
}
