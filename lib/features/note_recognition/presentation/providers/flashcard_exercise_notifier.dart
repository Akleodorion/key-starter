import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:key_starter/core/enums/note_state.dart';
import 'package:key_starter/core/providers/midi_note_provider.dart';
import 'package:key_starter/core/utils/note_utils.dart';
import 'package:key_starter/features/note_recognition/presentation/providers/flashcard_exercise_state.dart';
import 'package:key_starter/features/note_recognition/presentation/providers/flashcard_settings_state.dart';

final flashcardExerciseProvider = NotifierProvider.autoDispose
    .family<
      FlashcardExerciseNotifier,
      FlashcardExerciseState,
      FlashcardSettings
    >((settings) => FlashcardExerciseNotifier(settings));

class FlashcardExerciseNotifier extends Notifier<FlashcardExerciseState> {
  final FlashcardSettings _settings;

  FlashcardExerciseNotifier(this._settings);

  @override
  FlashcardExerciseState build() {
    ref.listen(midiNoteOnProvider, (_, next) {
      next.whenData(_onMidiReceived);
    });

    return FlashcardExerciseRunning(
      noteSteps: _generateSteps(),
      currentIndex: 0,
      noteState: NoteState.idle,
    );
  }

  List<int> _generateSteps() {
    final random = Random();
    final range = _settings.maxNoteStep - _settings.minNoteStep + 1;
    return List.generate(
      _settings.noteCount,
      (_) => _settings.minNoteStep + random.nextInt(range),
    );
  }

  void _onMidiReceived(int midiNumber) {
    final currentState = state;
    if (currentState is! FlashcardExerciseRunning) return;
    if (currentState.noteState != NoteState.idle) return;

    final playedStep = diatonicStepFromMidi(midiNumber);
    final isCorrect = playedStep == currentState.currentStep;

    state = currentState.copyWith(
      noteState: isCorrect ? NoteState.correct : NoteState.wrong,
      playedStep: playedStep,
    );

    Future.delayed(const Duration(milliseconds: 200), _advance);
  }

  void simulateMidi(int midiNumber) => _onMidiReceived(midiNumber);

  void _advance() {
    final currentState = state;
    if (currentState is! FlashcardExerciseRunning) return;

    final nextIndex = currentState.currentIndex + 1;
    if (nextIndex >= currentState.total) {
      state = const FlashcardExerciseCompleted();
    } else {
      state = FlashcardExerciseRunning(
        noteSteps: currentState.noteSteps,
        currentIndex: nextIndex,
        noteState: NoteState.idle,
      );
    }
  }
}
