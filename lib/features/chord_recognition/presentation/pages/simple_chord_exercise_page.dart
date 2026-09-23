import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:key_starter/core/theme/app_color_theme.dart';
import 'package:key_starter/features/chord_recognition/presentation/providers/simple_chord_exercise_notifier.dart';
import 'package:key_starter/features/chord_recognition/presentation/providers/simple_chord_exercise_state.dart';
import 'package:key_starter/features/chord_recognition/presentation/widgets/simple_chord_running_view.dart';
import 'package:key_starter/features/session/presentation/pages/recap_page.dart';

class SimpleChordExercisePage extends ConsumerStatefulWidget {
  final int chordCount;

  const SimpleChordExercisePage({super.key, required this.chordCount});

  @override
  ConsumerState<SimpleChordExercisePage> createState() =>
      _SimpleChordExercisePageState();
}

class _SimpleChordExercisePageState
    extends ConsumerState<SimpleChordExercisePage> {
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
    final chordCount = widget.chordCount;
    final exerciseState = ref.watch(simpleChordExerciseProvider(chordCount));

    ref.listen(simpleChordExerciseProvider(chordCount), (_, next) {
      if (next is! SimpleChordExerciseCompleted || !mounted) return;
      _handingOffToRecap = true;
      final navigator = Navigator.of(context);
      navigator.pushReplacement(
        MaterialPageRoute(
          builder: (_) => RecapPage(
            exerciseLabel: 'Lecture · accords simples',
            correctCount: next.correctCount,
            totalNotes: next.totalChords,
            avgResponseMs: next.avgResponseMs,
            bestStreak: next.bestStreak,
            onRetry: () => navigator.pushReplacement(
              MaterialPageRoute(
                builder: (_) => SimpleChordExercisePage(chordCount: chordCount),
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
            SimpleChordExerciseRunning() => SimpleChordRunningView(
              running: exerciseState,
              chordCount: chordCount,
            ),
            SimpleChordExerciseCompleted() => const SizedBox.shrink(),
          },
        ),
      ),
    );
  }
}
