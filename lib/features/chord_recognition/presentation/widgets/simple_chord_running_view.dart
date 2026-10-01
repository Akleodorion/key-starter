import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:key_starter/core/providers/notation_language_provider.dart';
import 'package:key_starter/core/theme/app_color_theme.dart';
import 'package:key_starter/core/widgets/ui_text.dart';
import 'package:key_starter/features/chord_recognition/presentation/providers/simple_chord_exercise_config.dart';
import 'package:key_starter/features/chord_recognition/presentation/providers/simple_chord_exercise_state.dart';
import 'package:key_starter/features/chord_recognition/presentation/widgets/simple_chord_answer_buttons.dart';
import 'package:key_starter/features/chord_recognition/presentation/widgets/simple_chord_display.dart';
import 'package:key_starter/features/chord_recognition/presentation/widgets/simple_chord_feedback_row.dart';
import 'package:key_starter/features/note_recognition/presentation/widgets/exercise_top_bar.dart';

class SimpleChordRunningView extends ConsumerWidget {
  final SimpleChordExerciseRunning running;
  final SimpleChordExerciseConfig config;

  const SimpleChordRunningView({
    super.key,
    required this.running,
    required this.config,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColorTheme.of(context);
    final language = ref.watch(notationLanguageProvider);
    final hint = config.isInversionPractice
        ? 'joue le renversement · touches blanches'
        : 'joue l\'accord · touches blanches, une sur deux';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ExerciseTopBar(
          exerciseLabel: 'Lecture',
          currentNumber: running.currentIndex + 1,
          total: running.chords.length,
        ),
        const SizedBox(height: 16),
        Center(child: UiText(hint, size: 14, color: colors.text2)),
        Expanded(
          child: Center(
            child: SimpleChordDisplay(
              chord: running.currentChord,
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
            SimpleChordAnswerButtons(config: config),
          ],
        ),
        const SizedBox(height: 4),
      ],
    );
  }
}
