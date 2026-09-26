import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:key_starter/core/enums/note_state.dart';
import 'package:key_starter/core/theme/app_colors.dart';
import 'package:key_starter/features/note_recognition/presentation/providers/simple_note_exercise_notifier.dart';
import 'package:key_starter/features/note_recognition/presentation/providers/simple_note_exercise_state.dart';

class SimpleNoteAnswerButtons extends ConsumerWidget {
  final int noteCount;

  const SimpleNoteAnswerButtons({super.key, required this.noteCount});

  static const _middleCMidiNumber = 60;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exerciseState = ref.watch(simpleNoteExerciseProvider(noteCount));
    final running = exerciseState is SimpleNoteExerciseRunning
        ? exerciseState
        : null;
    final isIdle = running?.noteState == NoteState.idle;
    final notifier = ref.read(simpleNoteExerciseProvider(noteCount).notifier);

    int midiOfPitchClass(int pitchClass) =>
        _middleCMidiNumber + pitchClass % 12;

    return Row(
      children: [
        OutlinedButton.icon(
          onPressed: isIdle
              ? () => notifier.simulateMidi(
                  midiOfPitchClass(running!.currentPitchClass),
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
                  midiOfPitchClass(running!.currentPitchClass + 1),
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
