import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:key_starter/core/providers/notation_language_provider.dart';
import 'package:key_starter/core/theme/app_color_theme.dart';
import 'package:key_starter/core/widgets/ui_text.dart';
import 'package:key_starter/features/chord_recognition/presentation/providers/simple_chord_exercise_state.dart';
import 'package:key_starter/features/chord_recognition/presentation/widgets/simple_chord_answer_buttons.dart';
import 'package:key_starter/features/chord_recognition/presentation/widgets/simple_chord_display.dart';
import 'package:key_starter/features/chord_recognition/presentation/widgets/simple_chord_feedback_row.dart';
import 'package:key_starter/features/note_recognition/presentation/widgets/exercise_top_bar.dart';

class SimpleChordRunningView extends ConsumerWidget {
  final SimpleChordExerciseRunning running;
  final int chordCount;

  const SimpleChordRunningView({
    super.key,
    required this.running,
    required this.chordCount,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColorTheme.of(context);
    final language = ref.watch(notationLanguageProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ExerciseTopBar(
          exerciseLabel: 'Lecture',
          currentNumber: running.currentIndex + 1,
          total: running.rootIndexes.length,
        ),
        const SizedBox(height: 16),
        Center(
          child: UiText(
            'joue l\'accord · touches blanches, une sur deux',
            size: 14,
            color: colors.text2,
          ),
        ),
        Expanded(
          child: Center(
            child: SimpleChordDisplay(
              rootIndex: running.currentRootIndex,
              noteState: running.noteState,
              language: language,
            ),
          ),
        ),
        Row(
          children: [
            Expanded(
              child: SimpleChordFeedbackRow(
                playedMidiNumbers: running.playedMidiNumbers,
                noteState: running.noteState,
                language: language,
              ),
            ),
            SimpleChordAnswerButtons(chordCount: chordCount),
          ],
        ),
        const SizedBox(height: 4),
      ],
    );
  }
}
