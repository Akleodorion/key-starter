import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:key_starter/core/theme/app_color_theme.dart';
import 'package:key_starter/core/widgets/ui_text.dart';
import 'package:key_starter/features/chord_recognition/presentation/providers/chord_tempo_exercise_config.dart';
import 'package:key_starter/features/chord_recognition/presentation/providers/chord_tempo_exercise_notifier.dart';
import 'package:key_starter/features/chord_recognition/presentation/providers/chord_tempo_exercise_state.dart';
import 'package:key_starter/features/note_recognition/presentation/widgets/exercise_top_bar.dart';
import 'package:key_starter/features/chord_recognition/presentation/widgets/chord_tempo_answer_buttons.dart';
import 'package:key_starter/features/chord_recognition/presentation/widgets/chord_tempo_staff_card.dart';

/// Vue de la partie en cours : redessinée à chaque image pour faire avancer
/// la barre sur l'horloge du notifier.
class ChordTempoRunningView extends ConsumerStatefulWidget {
  final ChordTempoExerciseRunning running;
  final ChordTempoExerciseConfig config;

  const ChordTempoRunningView({
    super.key,
    required this.running,
    required this.config,
  });

  @override
  ConsumerState<ChordTempoRunningView> createState() =>
      _ChordTempoRunningViewState();
}

class _ChordTempoRunningViewState extends ConsumerState<ChordTempoRunningView>
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
    final notifier = ref.read(
      chordTempoExerciseProvider(widget.config).notifier,
    );
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
            'joue chaque accord quand la barre le croise',
            size: 14,
            color: colors.text2,
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ChordTempoStaffCard(
            chordSteps: widget.running.chordSteps,
            chordStates: widget.running.chordStates,
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
          child: ChordTempoAnswerButtons(config: widget.config),
        ),
        const SizedBox(height: 4),
      ],
    );
  }
}
