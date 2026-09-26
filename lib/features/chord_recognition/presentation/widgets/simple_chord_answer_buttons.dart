import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:key_starter/core/enums/note_state.dart';
import 'package:key_starter/core/theme/app_colors.dart';
import 'package:key_starter/core/utils/note_utils.dart';
import 'package:key_starter/features/chord_recognition/presentation/providers/simple_chord_exercise_notifier.dart';
import 'package:key_starter/features/chord_recognition/presentation/providers/simple_chord_exercise_state.dart';

class SimpleChordAnswerButtons extends ConsumerWidget {
  final int chordCount;

  const SimpleChordAnswerButtons({super.key, required this.chordCount});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exerciseState = ref.watch(simpleChordExerciseProvider(chordCount));
    final running = exerciseState is SimpleChordExerciseRunning
        ? exerciseState
        : null;
    final isIdle = running?.noteState == NoteState.idle;
    final notifier = ref.read(simpleChordExerciseProvider(chordCount).notifier);

    List<int> rootPositionChordMidi(int rootIndex) => [
      midiFromDiatonicStep(rootIndex),
      midiFromDiatonicStep(rootIndex + 2),
      midiFromDiatonicStep(rootIndex + 4),
    ];

    return Row(
      children: [
        OutlinedButton.icon(
          onPressed: isIdle
              ? () => notifier.simulateMidi(
                  rootPositionChordMidi(running!.currentRootIndex),
                )
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
                  rootPositionChordMidi(running!.currentRootIndex + 1),
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
