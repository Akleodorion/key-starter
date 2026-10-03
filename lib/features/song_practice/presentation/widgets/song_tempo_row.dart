import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:key_starter/features/song_practice/presentation/providers/song_tempo_notifier.dart';
import 'package:key_starter/presentation/widgets/settings_stepper_layout.dart';

/// Réglage du tempo d'un morceau : Libre, puis de 40 à 120 noires par minute.
class SongTempoRow extends ConsumerWidget {
  const SongTempoRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bpm = ref.watch(songTempoProvider);
    final notifier = ref.read(songTempoProvider.notifier);

    return SettingsStepperLayout(
      label: 'Tempo',
      description: bpm == null ? 'sans tempo' : 'noires par minute',
      valueText: bpm?.toString() ?? 'Libre',
      onDecrement: notifier.decrement,
      onIncrement: notifier.increment,
    );
  }
}
