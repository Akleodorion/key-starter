import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:key_starter/features/note_recognition/presentation/providers/simple_note_settings_notifier.dart';
import 'package:key_starter/presentation/widgets/settings_stepper_row.dart';

/// Implémentation de [SettingsStepperRow] liée à [simpleNoteSettingsProvider].
class SimpleNoteNoteCountRow extends SettingsStepperRow {
  const SimpleNoteNoteCountRow({super.key});

  @override
  String get label => 'Nombre de notes';

  @override
  int value(WidgetRef ref) => ref.watch(simpleNoteSettingsProvider).noteCount;

  @override
  void onDecrement(WidgetRef ref) =>
      ref.read(simpleNoteSettingsProvider.notifier).decrementNoteCount();

  @override
  void onIncrement(WidgetRef ref) =>
      ref.read(simpleNoteSettingsProvider.notifier).incrementNoteCount();
}
