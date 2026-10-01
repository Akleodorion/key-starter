import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:key_starter/core/enums/note_state.dart';
import 'package:key_starter/core/theme/app_colors.dart';
import 'package:key_starter/features/chord_recognition/domain/entities/chord_prompt.dart';
import 'package:key_starter/features/chord_recognition/presentation/providers/simple_chord_exercise_config.dart';
import 'package:key_starter/features/chord_recognition/presentation/providers/simple_chord_exercise_notifier.dart';
import 'package:key_starter/features/chord_recognition/presentation/providers/simple_chord_exercise_state.dart';

class SimpleChordAnswerButtons extends ConsumerWidget {
  final SimpleChordExerciseConfig config;

  const SimpleChordAnswerButtons({super.key, required this.config});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exerciseState = ref.watch(simpleChordExerciseProvider(config));
    final running = exerciseState is SimpleChordExerciseRunning
        ? exerciseState
        : null;
    final isIdle = running?.noteState == NoteState.idle;
    final notifier = ref.read(simpleChordExerciseProvider(config).notifier);

    ChordPrompt nextRootChord(ChordPrompt chord) => ChordPrompt(
      rootIndex: (chord.rootIndex + 1) % 7,
      inversion: chord.inversion,
    );

    return Row(
      children: [
        OutlinedButton.icon(
          onPressed: isIdle
              ? () => notifier.simulateMidi(running!.currentChord.midiNumbers)
              : null,
          icon: const Icon(Icons.check_circle_rounded, size: 16),
          label: const Text('Juste'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.stateGreen,
            side: const BorderSide(color: AppColors.stateGreen),
          ),
        ),
        const SizedBox(width: 8),
        OutlinedButton.icon(
          onPressed: isIdle
              ? () => notifier.simulateMidi(
                  nextRootChord(running!.currentChord).midiNumbers,
                )
              : null,
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
