import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:key_starter/core/enums/note_state.dart';
import 'package:key_starter/core/providers/notation_language_provider.dart';
import 'package:key_starter/core/theme/app_color_theme.dart';
import 'package:key_starter/core/theme/app_colors.dart';
import 'package:key_starter/core/utils/note_utils.dart';
import 'package:key_starter/core/widgets/ui_text.dart';
import 'package:key_starter/features/note_recognition/presentation/providers/flashcard_exercise_notifier.dart';
import 'package:key_starter/features/note_recognition/presentation/providers/flashcard_exercise_state.dart';
import 'package:key_starter/features/note_recognition/presentation/providers/note_exercise_settings_state.dart';
import 'package:key_starter/features/note_recognition/presentation/widgets/exercise_feedback_row.dart';
import 'package:key_starter/features/note_recognition/presentation/widgets/exercise_top_bar.dart';
import 'package:key_starter/features/note_recognition/presentation/widgets/flashcard_staff_card.dart';
import 'package:key_starter/features/session/presentation/pages/recap_page.dart';

class FlashcardExercisePage extends ConsumerStatefulWidget {
  final NoteExerciseSettings settings;

  const FlashcardExercisePage({super.key, required this.settings});

  @override
  ConsumerState<FlashcardExercisePage> createState() =>
      _FlashcardExercisePageState();
}

class _FlashcardExercisePageState extends ConsumerState<FlashcardExercisePage> {
  bool _handingOffToRecap = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    if (!_handingOffToRecap) {
      SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColorTheme.of(context);
    final language = ref.watch(notationLanguageProvider);
    final exerciseState = ref.watch(flashcardExerciseProvider(widget.settings));

    ref.listen(flashcardExerciseProvider(widget.settings), (_, next) {
      if (next is FlashcardExerciseCompleted) {
        if (!mounted) return;
        _handingOffToRecap = true;
        final navigator = Navigator.of(context);
        final settings = widget.settings;
        navigator.pushReplacement(
          MaterialPageRoute(
            builder: (_) => RecapPage(
              exerciseLabel: 'Lecture · flashcard',
              correctCount: next.correctCount,
              totalNotes: next.totalNotes,
              avgResponseMs: next.avgResponseMs,
              bestStreak: next.bestStreak,
              onRetry: () => navigator.pushReplacement(
                MaterialPageRoute(
                  builder: (_) => FlashcardExercisePage(settings: settings),
                ),
              ),
            ),
          ),
        );
      }
    });

    final running = exerciseState is FlashcardExerciseRunning
        ? exerciseState
        : null;
    final currentNumber = running != null ? running.currentIndex + 1 : 0;
    final total = running?.total ?? 0;
    final isIdle = running?.noteState == NoteState.idle;
    final notifier = ref.read(
      flashcardExerciseProvider(widget.settings).notifier,
    );

    return Scaffold(
      backgroundColor: colors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ExerciseTopBar(
                exerciseLabel: 'Lecture',
                currentNumber: currentNumber,
                total: total,
              ),
              const SizedBox(height: 16),
              Center(
                child: UiText('joue cette note', size: 14, color: colors.text2),
              ),
              const SizedBox(height: 12),
              FlashcardStaffCard(settings: widget.settings),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: ExerciseFeedbackRow(
                      playedStep: running?.playedStep,
                      noteState: running?.noteState ?? NoteState.idle,
                      language: language,
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: isIdle
                        ? () => notifier.simulateMidi(
                            midiFromDiatonicStep(running!.currentStep),
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
                            midiFromDiatonicStep(running!.currentStep + 1),
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
              ),
              const SizedBox(height: 4),
            ],
          ),
        ),
      ),
    );
  }
}
