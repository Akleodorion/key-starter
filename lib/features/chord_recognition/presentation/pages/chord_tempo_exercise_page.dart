import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:key_starter/core/theme/app_color_theme.dart';
import 'package:key_starter/core/widgets/midi_only_exercise_frame.dart';
import 'package:key_starter/features/chord_recognition/presentation/providers/chord_tempo_exercise_config.dart';
import 'package:key_starter/features/chord_recognition/presentation/providers/chord_tempo_exercise_notifier.dart';
import 'package:key_starter/features/chord_recognition/presentation/providers/chord_tempo_exercise_state.dart';
import 'package:key_starter/features/chord_recognition/presentation/widgets/chord_tempo_running_view.dart';
import 'package:key_starter/features/session/domain/entities/timing_offset.dart';
import 'package:key_starter/features/session/presentation/pages/recap_page.dart';

class ChordTempoExercisePage extends ConsumerStatefulWidget {
  final ChordTempoExerciseConfig config;

  const ChordTempoExercisePage({super.key, required this.config});

  @override
  ConsumerState<ChordTempoExercisePage> createState() =>
      _ChordTempoExercisePageState();
}

class _ChordTempoExercisePageState
    extends ConsumerState<ChordTempoExercisePage> {
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
    final config = widget.config;
    final exerciseState = ref.watch(chordTempoExerciseProvider(config));

    ref.listen(chordTempoExerciseProvider(config), (_, next) {
      if (next is! ChordTempoExerciseCompleted || !mounted) return;
      _handingOffToRecap = true;
      final navigator = Navigator.of(context);
      navigator.pushReplacement(
        MaterialPageRoute(
          builder: (_) => RecapPage(
            exerciseLabel: 'Accords · tempo',
            correctCount: next.correctCount,
            totalNotes: next.totalChords,
            timingOffset: TimingOffset(averageMs: next.avgTimingOffsetMs),
            bestStreak: next.bestStreak,
            onRetry: () => navigator.pushReplacement(
              MaterialPageRoute(
                builder: (_) => ChordTempoExercisePage(config: config),
              ),
            ),
          ),
        ),
      );
    });

    return MidiOnlyExerciseFrame(
      onPause: () =>
          ref.read(chordTempoExerciseProvider(config).notifier).pause(),
      onResume: () =>
          ref.read(chordTempoExerciseProvider(config).notifier).resume(),
      child: Scaffold(
        backgroundColor: colors.bg,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: switch (exerciseState) {
              ChordTempoExerciseRunning() => ChordTempoRunningView(
                running: exerciseState,
                config: config,
              ),
              ChordTempoExerciseCompleted() => const SizedBox.shrink(),
            },
          ),
        ),
      ),
    );
  }
}
