import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:key_starter/features/song_practice/presentation/providers/song_tempo_notifier.dart';
import 'package:key_starter/presentation/widgets/settings_text_stepper_row.dart';

/// Implémentation de [SettingsTextStepperRow] liée à [songTempoProvider].
class SongTempoRow extends SettingsTextStepperRow {
  const SongTempoRow({super.key});

  @override
  String get label => 'Tempo';

  @override
  String? get description => 'noires par minute';

  @override
  String valueText(WidgetRef ref) =>
      ref.watch(songTempoProvider)?.toString() ?? 'Libre';

  @override
  void onDecrement(WidgetRef ref) =>
      ref.read(songTempoProvider.notifier).decrement();

  @override
  void onIncrement(WidgetRef ref) =>
      ref.read(songTempoProvider.notifier).increment();
}
