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
  int _correctCount = 0;
  int _currentStreak = 0;
  int _bestStreak = 0;
  int? _noteStartMs;
  final List<int> _responseTimes = [];
  int? _lastPlayedMidiNumber;
  bool _awaitingNoteRelease = false;

  FlashcardExerciseNotifier(this._settings);

  @override
  FlashcardExerciseState build() {
    ref.listen(midiNoteOnProvider, (_, next) {
      next.whenData(_onMidiReceived);
    });
    ref.listen(midiNoteOffProvider, (_, next) {
      next.whenData(_onMidiNoteOff);
    });
    _noteStartMs = DateTime.now().millisecondsSinceEpoch;
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

  void _onMidiNoteOff(int midiNumber) {
    if (_awaitingNoteRelease && midiNumber == _lastPlayedMidiNumber) {
      _awaitingNoteRelease = false;
    }
  }

  void _onMidiReceived(int midiNumber) {
    final currentState = state;
    if (currentState is! FlashcardExerciseRunning) return;
    if (currentState.noteState != NoteState.idle) return;
    if (_awaitingNoteRelease && midiNumber == _lastPlayedMidiNumber) return;

    final playedStep = diatonicStepFromMidi(midiNumber);
    _lastPlayedMidiNumber = midiNumber;

    // Activer le verrou maintenant si la note suivante requiert le même step,
    // pour que le Note OFF reçu pendant l'animation de feedback puisse le lever.
    final nextIndex = currentState.currentIndex + 1;
    _awaitingNoteRelease = nextIndex < currentState.total &&
        playedStep == currentState.noteSteps[nextIndex];

    final responseMs = _noteStartMs != null
        ? DateTime.now().millisecondsSinceEpoch - _noteStartMs!
        : 0;
    _responseTimes.add(responseMs);

    final isCorrect = playedStep == currentState.currentStep;

    if (isCorrect) {
      _correctCount++;
      _currentStreak++;
      if (_currentStreak > _bestStreak) _bestStreak = _currentStreak;
    } else {
      _currentStreak = 0;
    }

    state = currentState.copyWith(
      noteState: isCorrect ? NoteState.correct : NoteState.wrong,
      playedStep: playedStep,
    );

    Future.delayed(const Duration(milliseconds: 200), _advance);
  }

  void simulateMidi(int midiNumber) {
    _awaitingNoteRelease = false;
    _onMidiReceived(midiNumber);
  }

  void _advance() {
    final currentState = state;
    if (currentState is! FlashcardExerciseRunning) return;

    final nextIndex = currentState.currentIndex + 1;
    if (nextIndex >= currentState.total) {
      final avgMs = _responseTimes.reduce((a, b) => a + b) ~/ _responseTimes.length;
      state = FlashcardExerciseCompleted(
        correctCount: _correctCount,
        totalNotes: currentState.total,
        avgResponseMs: avgMs,
        bestStreak: _bestStreak,
      );
    } else {
      _noteStartMs = DateTime.now().millisecondsSinceEpoch;
      state = FlashcardExerciseRunning(
        noteSteps: currentState.noteSteps,
        currentIndex: nextIndex,
        noteState: NoteState.idle,
      );
    }
  }
}
