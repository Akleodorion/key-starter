import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:key_starter/core/theme/app_color_theme.dart';
import 'package:key_starter/features/note_recognition/presentation/providers/tempo_exercise_config.dart';
import 'package:key_starter/features/note_recognition/presentation/providers/tempo_exercise_notifier.dart';
import 'package:key_starter/features/note_recognition/presentation/providers/tempo_exercise_state.dart';
import 'package:key_starter/features/note_recognition/presentation/widgets/tempo_running_view.dart';
import 'package:key_starter/features/session/domain/entities/timing_offset.dart';
import 'package:key_starter/features/session/presentation/pages/recap_page.dart';

class TempoExercisePage extends ConsumerStatefulWidget {
  final TempoExerciseConfig config;

  const TempoExercisePage({super.key, required this.config});

  @override
  ConsumerState<TempoExercisePage> createState() => _TempoExercisePageState();
}

class _TempoExercisePageState extends ConsumerState<TempoExercisePage> {
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
    final exerciseState = ref.watch(tempoExerciseProvider(config));

    ref.listen(tempoExerciseProvider(config), (_, next) {
      if (next is! TempoExerciseCompleted || !mounted) return;
      _handingOffToRecap = true;
      final navigator = Navigator.of(context);
      navigator.pushReplacement(
        MaterialPageRoute(
          builder: (_) => RecapPage(
            exerciseLabel: 'Lecture · tempo',
            correctCount: next.correctCount,
            totalNotes: next.totalNotes,
            timingOffset: TimingOffset(averageMs: next.avgTimingOffsetMs),
            bestStreak: next.bestStreak,
            onRetry: () => navigator.pushReplacement(
              MaterialPageRoute(
                builder: (_) => TempoExercisePage(config: config),
              ),
            ),
          ),
        ),
      );
    });

    return Scaffold(
      backgroundColor: colors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: switch (exerciseState) {
            TempoExerciseRunning() => TempoRunningView(
              running: exerciseState,
              config: config,
            ),
            TempoExerciseCompleted() => const SizedBox.shrink(),
          },
        ),
      ),
    );
  }
}
