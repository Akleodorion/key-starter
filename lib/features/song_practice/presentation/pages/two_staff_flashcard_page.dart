import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:key_starter/core/theme/app_color_theme.dart';
import 'package:key_starter/core/widgets/midi_only_exercise_frame.dart';
import 'package:key_starter/features/song_practice/presentation/providers/two_staff_flashcard_notifier.dart';
import 'package:key_starter/features/song_practice/presentation/providers/two_staff_flashcard_state.dart';
import 'package:key_starter/features/song_practice/presentation/widgets/two_staff_flashcard_running_view.dart';

class TwoStaffFlashcardPage extends ConsumerStatefulWidget {
  const TwoStaffFlashcardPage({super.key});

  @override
  ConsumerState<TwoStaffFlashcardPage> createState() =>
      _TwoStaffFlashcardPageState();
}

class _TwoStaffFlashcardPageState extends ConsumerState<TwoStaffFlashcardPage> {
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
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColorTheme.of(context);
    final exerciseState = ref.watch(twoStaffFlashcardProvider);

    return MidiOnlyExerciseFrame(
      child: Scaffold(
        backgroundColor: colors.bg,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: switch (exerciseState) {
              TwoStaffFlashcardRunning() => TwoStaffFlashcardRunningView(
                running: exerciseState,
              ),
            },
          ),
        ),
      ),
    );
  }
}
