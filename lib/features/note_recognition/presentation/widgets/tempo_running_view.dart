import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:key_starter/core/theme/app_color_theme.dart';
import 'package:key_starter/core/widgets/ui_text.dart';
import 'package:key_starter/features/note_recognition/presentation/providers/tempo_exercise_config.dart';
import 'package:key_starter/features/note_recognition/presentation/providers/tempo_exercise_notifier.dart';
import 'package:key_starter/features/note_recognition/presentation/providers/tempo_exercise_state.dart';
import 'package:key_starter/features/note_recognition/presentation/widgets/exercise_top_bar.dart';
import 'package:key_starter/features/note_recognition/presentation/widgets/tempo_answer_buttons.dart';
import 'package:key_starter/features/note_recognition/presentation/widgets/tempo_staff_card.dart';

/// Vue de la partie en cours : redessinée à chaque image pour faire avancer
/// la barre sur l'horloge du notifier.
class TempoRunningView extends ConsumerStatefulWidget {
  final TempoExerciseRunning running;
  final TempoExerciseConfig config;

  const TempoRunningView({
    super.key,
    required this.running,
    required this.config,
  });

  @override
  ConsumerState<TempoRunningView> createState() => _TempoRunningViewState();
}

class _TempoRunningViewState extends ConsumerState<TempoRunningView>
    with SingleTickerProviderStateMixin {
  late final Ticker _frameTicker = createTicker((_) => setState(() {}));

  @override
  void initState() {
    super.initState();
    _frameTicker.start();
  }

  @override
  void dispose() {
    _frameTicker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColorTheme.of(context);
    final notifier = ref.read(tempoExerciseProvider(widget.config).notifier);
    final timeline = notifier.timeline;
    final elapsed = notifier.elapsed;
    final barLine = timeline.barLineAt(elapsed);
    final barFraction = timeline.barFractionAt(elapsed);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ExerciseTopBar(
          exerciseLabel: 'Tempo',
          currentNumber: timeline.barNoteIndexAt(elapsed) + 1,
          total: timeline.noteCount,
        ),
        const SizedBox(height: 12),
        Center(
          child: UiText(
            'joue chaque note quand la barre la croise',
            size: 14,
            color: colors.text2,
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: TempoStaffCard(
            noteSteps: widget.running.noteSteps,
            noteStates: widget.running.noteStates,
            clef: widget.config.settings.clef,
            topLine: timeline.topLineAt(elapsed),
            barLine: barLine,
            barFraction: barFraction,
            countInBeat: timeline.countInBeatAt(elapsed),
          ),
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: TempoAnswerButtons(config: widget.config),
        ),
        const SizedBox(height: 4),
      ],
    );
  }
}
