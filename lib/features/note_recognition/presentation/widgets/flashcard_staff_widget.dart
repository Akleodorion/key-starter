import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:key_starter/core/enums/clef_mode.dart';
import 'package:key_starter/core/enums/note_state.dart';
import 'package:key_starter/core/widgets/staff_widget.dart';
import 'package:key_starter/features/note_recognition/presentation/providers/flashcard_exercise_notifier.dart';
import 'package:key_starter/features/note_recognition/presentation/providers/flashcard_exercise_state.dart';
import 'package:key_starter/features/note_recognition/presentation/providers/flashcard_settings_state.dart';

/// Implémentation de [StaffWidget] liée à [flashcardExerciseProvider].
class FlashcardStaffWidget extends StaffWidget {
  final FlashcardSettings settings;

  const FlashcardStaffWidget({
    super.key,
    required this.settings,
    super.height = 100,
  });

  @override
  ClefMode clef(WidgetRef ref) => settings.clef;

  @override
  int? diatonicStep(WidgetRef ref) {
    final exerciseState = ref.watch(flashcardExerciseProvider(settings));
    return exerciseState is FlashcardExerciseRunning
        ? exerciseState.currentStep
        : null;
  }

  @override
  NoteState noteState(WidgetRef ref) {
    final exerciseState = ref.watch(flashcardExerciseProvider(settings));
    return exerciseState is FlashcardExerciseRunning
        ? exerciseState.noteState
        : NoteState.idle;
  }
}
