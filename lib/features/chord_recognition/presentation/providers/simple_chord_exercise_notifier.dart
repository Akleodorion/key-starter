import 'dart:async';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:key_starter/core/enums/note_state.dart';
import 'package:key_starter/core/input/input_event.dart';
import 'package:key_starter/core/input/input_source_provider.dart';
import 'package:key_starter/core/utils/note_utils.dart';
import 'package:key_starter/features/chord_recognition/domain/entities/chord_prompt.dart';
import 'package:key_starter/features/chord_recognition/presentation/providers/simple_chord_exercise_config.dart';
import 'package:key_starter/features/chord_recognition/presentation/providers/simple_chord_exercise_state.dart';

final simpleChordExerciseProvider = NotifierProvider.autoDispose
    .family<
      SimpleChordExerciseNotifier,
      SimpleChordExerciseState,
      SimpleChordExerciseConfig
    >((config) => SimpleChordExerciseNotifier(config));

/// Durée de la fenêtre de regroupement des Note On MIDI : le protocole MIDI
/// n'a pas de message "accord" natif.
const _detectionWindow = Duration(milliseconds: 100);

class SimpleChordExerciseNotifier extends Notifier<SimpleChordExerciseState> {
  static const feedbackDuration = Duration(milliseconds: 500);

  final SimpleChordExerciseConfig _config;
  final DateTime Function() _now;
  late DateTime _chordShownAt;
  final List<int> _responseTimesMs = [];
  Timer? _detectionTimer;
  Timer? _advanceTimer;
  final Set<int> _pendingMidiNumbers = {};
  int _correctCount = 0;
  int _currentStreak = 0;
  int _bestStreak = 0;

  SimpleChordExerciseNotifier(this._config, {DateTime Function()? now})
    : _now = now ?? DateTime.now;

  @override
  SimpleChordExerciseState build() {
    final subscription = ref
        .read(inputSourceProvider)
        .events
        .listen(_onInputEvent);
    ref.onDispose(() {
      subscription.cancel();
      _detectionTimer?.cancel();
      _advanceTimer?.cancel();
    });
    _chordShownAt = _now();
    return SimpleChordExerciseRunning(
      chords: _generateChords(),
      currentIndex: 0,
      noteState: NoteState.idle,
    );
  }

  /// Tire les consignes parmi toutes les fondamentales et les positions
  /// choisies, sans jamais répéter deux fois de suite la même consigne.
  List<ChordPrompt> _generateChords() {
    final random = Random();
    final candidates = [
      for (final inversion in _config.inversions)
        for (var rootIndex = 0; rootIndex < noteNamesFr.length; rootIndex++)
          ChordPrompt(rootIndex: rootIndex, inversion: inversion),
    ];
    final candidateIndexes = [random.nextInt(candidates.length)];
    while (candidateIndexes.length < _config.chordCount) {
      final offsetFromPrevious = 1 + random.nextInt(candidates.length - 1);
      candidateIndexes.add(
        (candidateIndexes.last + offsetFromPrevious) % candidates.length,
      );
    }
    return [for (final index in candidateIndexes) candidates[index]];
  }

  void _onInputEvent(InputEvent event) {
    if (event is NotePlayed) _onNoteOn(event.midiNumber);
  }

  void simulateMidi(List<int> midiNumbers) {
    for (final midiNumber in midiNumbers) {
      _onNoteOn(midiNumber);
    }
  }

  void _onNoteOn(int midiNumber) {
    final currentState = state;
    if (currentState is! SimpleChordExerciseRunning) return;
    if (currentState.noteState != NoteState.idle) return;

    if (_detectionTimer == null) {
      _responseTimesMs.add(_now().difference(_chordShownAt).inMilliseconds);
      _detectionTimer = Timer(_detectionWindow, _evaluatePending);
    }
    _pendingMidiNumbers.add(midiNumber);
  }

  void _evaluatePending() {
    _detectionTimer = null;
    final currentState = state;
    if (currentState is! SimpleChordExerciseRunning) return;

    final playedMidiNumbers = _pendingMidiNumbers.toList()..sort();
    _pendingMidiNumbers.clear();

    final isCorrect = currentState.currentChord.isPlayedBy(playedMidiNumbers);

    if (isCorrect) {
      _correctCount++;
      _currentStreak++;
      _bestStreak = max(_bestStreak, _currentStreak);
    } else {
      _currentStreak = 0;
    }

    state = currentState.copyWith(
      noteState: isCorrect ? NoteState.correct : NoteState.wrong,
      playedMidiNumbers: playedMidiNumbers,
    );

    _advanceTimer = Timer(feedbackDuration, _advance);
  }

  void _advance() {
    final currentState = state;
    if (currentState is! SimpleChordExerciseRunning) return;

    final nextIndex = currentState.currentIndex + 1;
    if (nextIndex >= currentState.chords.length) {
      state = SimpleChordExerciseCompleted(
        correctCount: _correctCount,
        totalChords: currentState.chords.length,
        bestStreak: _bestStreak,
        avgResponseMs:
            _responseTimesMs.reduce((total, time) => total + time) ~/
            _responseTimesMs.length,
      );
      return;
    }

    _chordShownAt = _now();
    state = currentState.copyWith(
      currentIndex: nextIndex,
      noteState: NoteState.idle,
      playedMidiNumbers: const [],
    );
  }
}
