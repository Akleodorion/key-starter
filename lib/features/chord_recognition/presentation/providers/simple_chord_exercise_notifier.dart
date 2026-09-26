import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_midi_command/flutter_midi_command.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:key_starter/core/enums/note_state.dart';
import 'package:key_starter/core/utils/note_utils.dart';
import 'package:key_starter/features/chord_recognition/presentation/providers/simple_chord_exercise_state.dart';

final simpleChordExerciseProvider = NotifierProvider.autoDispose
    .family<SimpleChordExerciseNotifier, SimpleChordExerciseState, int>(
      (chordCount) => SimpleChordExerciseNotifier(chordCount),
    );

/// Durée de la fenêtre de regroupement des Note On MIDI : le protocole MIDI
/// n'a pas de message "accord" natif.
const _detectionWindow = Duration(milliseconds: 100);

class SimpleChordExerciseNotifier extends Notifier<SimpleChordExerciseState> {
  static const feedbackDuration = Duration(milliseconds: 500);

  final int _chordCount;
  final DateTime Function() _now;
  late DateTime _chordShownAt;
  final List<int> _responseTimesMs = [];
  Timer? _detectionTimer;
  Timer? _advanceTimer;
  final Set<int> _pendingMidiNumbers = {};
  int _correctCount = 0;
  int _currentStreak = 0;
  int _bestStreak = 0;

  SimpleChordExerciseNotifier(this._chordCount, {DateTime Function()? now})
    : _now = now ?? DateTime.now;

  @override
  SimpleChordExerciseState build() {
    final subscription = MidiCommand().onMidiDataReceived?.listen(
      _onMidiPacket,
    );
    ref.onDispose(() {
      subscription?.cancel();
      _detectionTimer?.cancel();
      _advanceTimer?.cancel();
    });
    _chordShownAt = _now();
    return SimpleChordExerciseRunning(
      rootIndexes: _generateRootIndexes(),
      currentIndex: 0,
      noteState: NoteState.idle,
    );
  }

  List<int> _generateRootIndexes() {
    final random = Random();
    final noteNameCount = noteNamesFr.length;
    final rootIndexes = [random.nextInt(noteNameCount)];
    while (rootIndexes.length < _chordCount) {
      final offsetFromPrevious = 1 + random.nextInt(noteNameCount - 1);
      rootIndexes.add((rootIndexes.last + offsetFromPrevious) % noteNameCount);
    }
    return rootIndexes;
  }

  void _onMidiPacket(MidiPacket packet) {
    final data = packet.data;
    if (data.length < 3) return;

    final status = data[0] & 0xF0;
    final isNoteOn = status == 0x90 && data[2] > 0;
    if (isNoteOn) _onNoteOn(data[1]);
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

    final isCorrect = _isRootPosition(
      playedMidiNumbers,
      currentState.currentRootIndex,
    );

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
    if (nextIndex >= currentState.rootIndexes.length) {
      state = SimpleChordExerciseCompleted(
        correctCount: _correctCount,
        totalChords: currentState.rootIndexes.length,
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

  bool _isRootPosition(List<int> sortedMidiNumbers, int rootIndex) {
    final lowestMidiNumber = sortedMidiNumbers.first;
    if (lowestMidiNumber % 12 != diatonicSemitones[rootIndex]) return false;

    int semitonesAboveRoot(int degreesAboveRoot) {
      final degree = rootIndex + degreesAboveRoot;
      final noteNameCount = diatonicSemitones.length;
      return diatonicSemitones[degree % noteNameCount] +
          12 * (degree ~/ noteNameCount) -
          diatonicSemitones[rootIndex];
    }

    final expectedMidiNumbers = [
      lowestMidiNumber,
      lowestMidiNumber + semitonesAboveRoot(2),
      lowestMidiNumber + semitonesAboveRoot(4),
    ];
    return listEquals(sortedMidiNumbers, expectedMidiNumbers);
  }
}
