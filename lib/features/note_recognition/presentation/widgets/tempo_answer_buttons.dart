import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:key_starter/core/theme/app_colors.dart';
import 'package:key_starter/core/utils/note_utils.dart';
import 'package:key_starter/features/note_recognition/presentation/providers/tempo_exercise_config.dart';
import 'package:key_starter/features/note_recognition/presentation/providers/tempo_exercise_notifier.dart';

/// Boutons de simulation : « Juste » joue, à l'instant du clic, la note que
/// vise la barre ; « Faux » en joue une autre.
class TempoAnswerButtons extends ConsumerWidget {
  final TempoExerciseConfig config;

  const TempoAnswerButtons({super.key, required this.config});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(tempoExerciseProvider(config).notifier);

    void playTarget({required int stepShift}) {
      final targetStep = notifier.currentTargetStep;
      if (targetStep == null) return;
      notifier.simulateMidi(midiFromDiatonicStep(targetStep + stepShift));
    }

    return Row(
      children: [
        OutlinedButton.icon(
          onPressed: () => playTarget(stepShift: 0),
          icon: const Icon(Icons.check_circle_rounded, size: 16),
          label: const Text('Juste'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.stateGreen,
            side: const BorderSide(color: AppColors.stateGreen),
          ),
        ),
        const SizedBox(width: 8),
        OutlinedButton.icon(
          onPressed: () => playTarget(stepShift: 1),
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
