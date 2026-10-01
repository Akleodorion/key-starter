import 'dart:async';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:key_starter/core/enums/note_state.dart';
import 'package:key_starter/core/input/input_event.dart';
import 'package:key_starter/core/input/input_source.dart';
import 'package:key_starter/core/input/input_source_provider.dart';
import 'package:key_starter/core/utils/note_utils.dart';
import 'package:key_starter/features/note_recognition/presentation/providers/simple_note_exercise_config.dart';
import 'package:key_starter/features/note_recognition/presentation/providers/simple_note_exercise_state.dart';

final simpleNoteExerciseProvider = NotifierProvider.autoDispose
    .family<
      SimpleNoteExerciseNotifier,
      SimpleNoteExerciseState,
      SimpleNoteExerciseConfig
    >((config) => SimpleNoteExerciseNotifier(config));

class SimpleNoteExerciseNotifier extends Notifier<SimpleNoteExerciseState> {
  static const feedbackDuration = Duration(milliseconds: 500);

  static const _allPitchClasses = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11];

  final SimpleNoteExerciseConfig _config;
  final DateTime Function() _now;
  final Random _random;
  late final InputSource _inputSource;
  Timer? _advanceTimer;
  int _correctCount = 0;
  int _currentStreak = 0;
  int _bestStreak = 0;
  late DateTime _noteShownAt;
  final List<int> _responseTimesMs = [];

  SimpleNoteExerciseNotifier(
    this._config, {
    DateTime Function()? now,
    Random? random,
  }) : _now = now ?? DateTime.now,
       _random = random ?? Random();

  @override
  SimpleNoteExerciseState build() {
    _inputSource = ref.read(inputSourceProvider);
    final subscription = _inputSource.events.listen(_onInputEvent);
    ref.onDispose(() {
      subscription.cancel();
      _inputSource.stopListening();
      _advanceTimer?.cancel();
    });
    final pitchClasses = _generatePitchClasses();
    _showNote(pitchClasses.first);
    return SimpleNoteExerciseRunning(
      pitchClasses: pitchClasses,
      currentIndex: 0,
      noteState: NoteState.idle,
    );
  }

  List<int> _generatePitchClasses() {
    final candidatePitchClasses = _config.includeBlackKeys
        ? _allPitchClasses
        : diatonicSemitones;
    final candidateCount = candidatePitchClasses.length;
    final candidatePositions = [_random.nextInt(candidateCount)];
    while (candidatePositions.length < _config.noteCount) {
      final offsetFromPrevious = 1 + _random.nextInt(candidateCount - 1);
      candidatePositions.add(
        (candidatePositions.last + offsetFromPrevious) % candidateCount,
      );
    }
    return [
      for (final position in candidatePositions)
        candidatePitchClasses[position],
    ];
  }

  /// L'octave ne compte pas : toutes les touches de la classe de hauteur sont
  /// des réponses acceptées.
  void _showNote(int pitchClass) {
    _noteShownAt = _now();
    _inputSource.listenFor(pianoMidiNumbersOfPitchClass(pitchClass));
  }

  void _onInputEvent(InputEvent event) {
    if (event is NotePlayed) _onNotePlayed(event.midiNumber, event.attackTime);
  }

  void simulateMidi(int midiNumber) => _onNotePlayed(midiNumber, _now());

  void _onNotePlayed(int midiNumber, DateTime playedAt) {
    final currentState = state;
    if (currentState is! SimpleNoteExerciseRunning) return;
    if (currentState.noteState != NoteState.idle) return;

    final isCorrect = midiNumber % 12 == currentState.currentPitchClass;
    _responseTimesMs.add(playedAt.difference(_noteShownAt).inMilliseconds);

    if (isCorrect) {
      _correctCount++;
      _currentStreak++;
      _bestStreak = max(_bestStreak, _currentStreak);
    } else {
      _currentStreak = 0;
    }

    state = currentState.copyWith(
      noteState: isCorrect ? NoteState.correct : NoteState.wrong,
      playedMidiNumber: midiNumber,
    );

    _advanceTimer = Timer(feedbackDuration, _advance);
  }

  void _advance() {
    final currentState = state;
    if (currentState is! SimpleNoteExerciseRunning) return;

    final nextIndex = currentState.currentIndex + 1;
    if (nextIndex >= currentState.pitchClasses.length) {
      state = SimpleNoteExerciseCompleted(
        correctCount: _correctCount,
        totalNotes: currentState.pitchClasses.length,
        bestStreak: _bestStreak,
        avgResponseMs:
            _responseTimesMs.reduce((total, time) => total + time) ~/
            _responseTimesMs.length,
      );
      return;
    }

    _showNote(currentState.pitchClasses[nextIndex]);
    state = SimpleNoteExerciseRunning(
      pitchClasses: currentState.pitchClasses,
      currentIndex: nextIndex,
      noteState: NoteState.idle,
    );
  }
}
