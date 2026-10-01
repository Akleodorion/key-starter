import 'dart:async';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:key_starter/core/enums/note_state.dart';
import 'package:key_starter/core/input/input_event.dart';
import 'package:key_starter/core/input/input_source.dart';
import 'package:key_starter/core/input/input_source_provider.dart';
import 'package:key_starter/core/utils/note_feedback_motion.dart';
import 'package:key_starter/core/utils/note_utils.dart';
import 'package:key_starter/features/note_recognition/presentation/providers/flashcard_exercise_state.dart';
import 'package:key_starter/features/note_recognition/presentation/providers/note_exercise_settings_state.dart';

final flashcardExerciseProvider = NotifierProvider.autoDispose
    .family<
      FlashcardExerciseNotifier,
      FlashcardExerciseState,
      NoteExerciseSettings
    >((settings) => FlashcardExerciseNotifier(settings));

class FlashcardExerciseNotifier extends Notifier<FlashcardExerciseState> {
  final NoteExerciseSettings _settings;
  int _correctCount = 0;
  int _currentStreak = 0;
  int _bestStreak = 0;
  int? _noteStartMs;
  final List<int> _responseTimes = [];
  int? _lastPlayedMidiNumber;
  bool _awaitingNoteRelease = false;
  late final InputSource _inputSource;
  Timer? _advanceTimer;

  FlashcardExerciseNotifier(this._settings);

  @override
  FlashcardExerciseState build() {
    _inputSource = ref.read(inputSourceProvider);
    final subscription = _inputSource.events.listen(_onInputEvent);
    ref.onDispose(() {
      subscription.cancel();
      _inputSource.stopListening();
      _advanceTimer?.cancel();
    });

    final noteSteps = _generateSteps();
    _showNote(noteSteps.first);
    return FlashcardExerciseRunning(
      noteSteps: noteSteps,
      currentIndex: 0,
      noteState: NoteState.idle,
    );
  }

  void _showNote(int step) {
    _noteStartMs = DateTime.now().millisecondsSinceEpoch;
    _inputSource.listenFor({midiFromDiatonicStep(step)});
  }

  void _onInputEvent(InputEvent event) {
    switch (event) {
      case NotePlayed(:final midiNumber, :final attackTime):
        _onNotePlayed(midiNumber, attackTime);
      case NoteReleased(:final midiNumber):
        _onNoteReleased(midiNumber);
    }
  }

  List<int> _generateSteps() {
    final random = Random();
    final range = _settings.maxNoteStep - _settings.minNoteStep + 1;
    return List.generate(
      _settings.noteCount,
      (_) => _settings.minNoteStep + random.nextInt(range),
    );
  }

  void _onNoteReleased(int midiNumber) {
    if (_awaitingNoteRelease && midiNumber == _lastPlayedMidiNumber) {
      _awaitingNoteRelease = false;
    }
  }

  void _onNotePlayed(int midiNumber, DateTime playedAt) {
    final currentState = state;
    if (currentState is! FlashcardExerciseRunning) return;
    if (currentState.noteState != NoteState.idle) return;
    if (_awaitingNoteRelease && midiNumber == _lastPlayedMidiNumber) return;

    final playedStep = diatonicStepFromMidi(midiNumber);
    _lastPlayedMidiNumber = midiNumber;

    final nextIndex = currentState.currentIndex + 1;
    _awaitingNoteRelease =
        nextIndex < currentState.total &&
        playedStep == currentState.noteSteps[nextIndex];

    final responseMs = _noteStartMs != null
        ? playedAt.millisecondsSinceEpoch - _noteStartMs!
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

    _advanceTimer = Timer(noteAdvanceDelay, _advance);
  }

  void simulateMidi(int midiNumber) {
    _awaitingNoteRelease = false;
    _onNotePlayed(midiNumber, DateTime.now());
  }

  void _advance() {
    final currentState = state;
    if (currentState is! FlashcardExerciseRunning) return;

    final nextIndex = currentState.currentIndex + 1;
    if (nextIndex >= currentState.total) {
      final avgMs =
          _responseTimes.reduce((a, b) => a + b) ~/ _responseTimes.length;
      state = FlashcardExerciseCompleted(
        correctCount: _correctCount,
        totalNotes: currentState.total,
        avgResponseMs: avgMs,
        bestStreak: _bestStreak,
      );
    } else {
      _showNote(currentState.noteSteps[nextIndex]);
      state = FlashcardExerciseRunning(
        noteSteps: currentState.noteSteps,
        currentIndex: nextIndex,
        noteState: NoteState.idle,
      );
    }
  }
}
