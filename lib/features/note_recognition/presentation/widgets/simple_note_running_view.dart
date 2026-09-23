import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:key_starter/core/providers/notation_language_provider.dart';
import 'package:key_starter/core/theme/app_color_theme.dart';
import 'package:key_starter/core/widgets/ui_text.dart';
import 'package:key_starter/features/note_recognition/presentation/providers/simple_note_exercise_state.dart';
import 'package:key_starter/features/note_recognition/presentation/widgets/exercise_top_bar.dart';
import 'package:key_starter/features/note_recognition/presentation/widgets/simple_note_answer_buttons.dart';
import 'package:key_starter/features/note_recognition/presentation/widgets/simple_note_display.dart';
import 'package:key_starter/features/note_recognition/presentation/widgets/simple_note_feedback_row.dart';

class SimpleNoteRunningView extends ConsumerWidget {
  final SimpleNoteExerciseRunning running;
  final int noteCount;

  const SimpleNoteRunningView({
    super.key,
    required this.running,
    required this.noteCount,
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
          total: running.noteIndexes.length,
        ),
        const SizedBox(height: 16),
        Center(child: UiText('joue cette note', size: 14, color: colors.text2)),
        Expanded(
          child: Center(
            child: SimpleNoteDisplay(
              noteIndex: running.currentNoteIndex,
              noteState: running.noteState,
              language: language,
            ),
          ),
        ),
        Row(
          children: [
            Expanded(
              child: SimpleNoteFeedbackRow(
                playedMidiNumber: running.playedMidiNumber,
                noteState: running.noteState,
                language: language,
              ),
            ),
            SimpleNoteAnswerButtons(noteCount: noteCount),
          ],
        ),
        const SizedBox(height: 4),
      ],
    );
  }
}
