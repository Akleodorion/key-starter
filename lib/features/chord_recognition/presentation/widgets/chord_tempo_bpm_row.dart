import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:key_starter/features/chord_recognition/presentation/providers/chord_tempo_bpm_notifier.dart';
import 'package:key_starter/presentation/widgets/settings_stepper_row.dart';

/// Implémentation de [SettingsStepperRow] liée à [chordTempoBpmProvider].
class ChordTempoBpmRow extends SettingsStepperRow {
  const ChordTempoBpmRow({super.key});

  @override
  String get label => 'Tempo';

  @override
  String? get description => 'battements par minute';

  @override
  int value(WidgetRef ref) => ref.watch(chordTempoBpmProvider);

  @override
  void onDecrement(WidgetRef ref) =>
      ref.read(chordTempoBpmProvider.notifier).decrement();

  @override
  void onIncrement(WidgetRef ref) =>
      ref.read(chordTempoBpmProvider.notifier).increment();
}
