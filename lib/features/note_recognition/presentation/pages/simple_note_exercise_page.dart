import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:key_starter/core/theme/app_color_theme.dart';
import 'package:key_starter/features/note_recognition/presentation/providers/simple_note_exercise_config.dart';
import 'package:key_starter/features/note_recognition/presentation/providers/simple_note_exercise_notifier.dart';
import 'package:key_starter/features/note_recognition/presentation/providers/simple_note_exercise_state.dart';
import 'package:key_starter/features/note_recognition/presentation/widgets/simple_note_running_view.dart';
import 'package:key_starter/features/session/presentation/pages/recap_page.dart';

class SimpleNoteExercisePage extends ConsumerStatefulWidget {
  final SimpleNoteExerciseConfig config;

  const SimpleNoteExercisePage({super.key, required this.config});

  @override
  ConsumerState<SimpleNoteExercisePage> createState() =>
      _SimpleNoteExercisePageState();
}

class _SimpleNoteExercisePageState
    extends ConsumerState<SimpleNoteExercisePage> {
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
    final exerciseState = ref.watch(simpleNoteExerciseProvider(config));

    ref.listen(simpleNoteExerciseProvider(config), (_, next) {
      if (next is! SimpleNoteExerciseCompleted || !mounted) return;
      _handingOffToRecap = true;
      final navigator = Navigator.of(context);
      navigator.pushReplacement(
        MaterialPageRoute(
          builder: (_) => RecapPage(
            exerciseLabel: 'Lecture · notes simples',
            correctCount: next.correctCount,
            totalNotes: next.totalNotes,
            avgResponseMs: next.avgResponseMs,
            bestStreak: next.bestStreak,
            onRetry: () => navigator.pushReplacement(
              MaterialPageRoute(
                builder: (_) => SimpleNoteExercisePage(config: config),
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
            SimpleNoteExerciseRunning() => SimpleNoteRunningView(
              running: exerciseState,
              config: config,
            ),
            SimpleNoteExerciseCompleted() => const SizedBox.shrink(),
          },
        ),
      ),
    );
  }
}
