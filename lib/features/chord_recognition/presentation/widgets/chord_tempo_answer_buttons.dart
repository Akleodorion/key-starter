import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:key_starter/core/theme/app_colors.dart';
import 'package:key_starter/core/utils/note_utils.dart';
import 'package:key_starter/features/chord_recognition/presentation/providers/chord_tempo_exercise_config.dart';
import 'package:key_starter/features/chord_recognition/presentation/providers/chord_tempo_exercise_notifier.dart';

/// Boutons de simulation : « Juste » joue, à l'instant du clic, l'accord que
/// vise la barre ; « Faux » en joue un autre (fondamentale décalée d'un
/// degré).
class ChordTempoAnswerButtons extends ConsumerWidget {
  final ChordTempoExerciseConfig config;

  const ChordTempoAnswerButtons({super.key, required this.config});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(chordTempoExerciseProvider(config).notifier);

    void playTarget({required int rootShift}) {
      final targetChord = notifier.currentTargetChord;
      if (targetChord == null) return;
      notifier.simulateMidi([
        midiFromDiatonicStep(targetChord.first + rootShift),
        ...targetChord.skip(1).map(midiFromDiatonicStep),
      ]);
    }

    return Row(
      children: [
        OutlinedButton.icon(
          onPressed: () => playTarget(rootShift: 0),
          icon: const Icon(Icons.check_circle_rounded, size: 16),
          label: const Text('Juste'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.stateGreen,
            side: const BorderSide(color: AppColors.stateGreen),
          ),
        ),
        const SizedBox(width: 8),
        OutlinedButton.icon(
          onPressed: () => playTarget(rootShift: 1),
          icon: const Icon(Icons.cancel_rounded, size: 16),
          label: const Text('Faux'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.stateRed,
            side: const BorderSide(color: AppColors.stateRed),
          ),
        ),
      ],
    );
  }
}
