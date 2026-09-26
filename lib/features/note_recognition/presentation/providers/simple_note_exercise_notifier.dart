import 'dart:async';
import 'dart:math';

import 'package:flutter_midi_command/flutter_midi_command.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:key_starter/core/enums/note_state.dart';
import 'package:key_starter/core/utils/note_utils.dart';
import 'package:key_starter/features/note_recognition/presentation/providers/simple_note_exercise_state.dart';

final simpleNoteExerciseProvider = NotifierProvider.autoDispose
    .family<SimpleNoteExerciseNotifier, SimpleNoteExerciseState, int>(
      (noteCount) => SimpleNoteExerciseNotifier(noteCount),
    );

class SimpleNoteExerciseNotifier extends Notifier<SimpleNoteExerciseState> {
  static const feedbackDuration = Duration(milliseconds: 500);

  final int _noteCount;
  final DateTime Function() _now;
  Timer? _advanceTimer;
  int _correctCount = 0;
  int _currentStreak = 0;
  int _bestStreak = 0;
  late DateTime _noteShownAt;
  final List<int> _responseTimesMs = [];

  SimpleNoteExerciseNotifier(this._noteCount, {DateTime Function()? now})
    : _now = now ?? DateTime.now;

  @override
  SimpleNoteExerciseState build() {
    final subscription = MidiCommand().onMidiDataReceived?.listen(
      _onMidiPacket,
    );
    ref.onDispose(() {
      subscription?.cancel();
      _advanceTimer?.cancel();
    });
    _noteShownAt = _now();
    return SimpleNoteExerciseRunning(
      pitchClasses: _generatePitchClasses(),
      currentIndex: 0,
      noteState: NoteState.idle,
    );
  }

  List<int> _generatePitchClasses() {
    final random = Random();
    const candidatePitchClasses = diatonicSemitones;
    final candidateCount = candidatePitchClasses.length;
    final candidatePositions = [random.nextInt(candidateCount)];
    while (candidatePositions.length < _noteCount) {
      final offsetFromPrevious = 1 + random.nextInt(candidateCount - 1);
      candidatePositions.add(
        (candidatePositions.last + offsetFromPrevious) % candidateCount,
      );
    }
    return [
      for (final position in candidatePositions)
        candidatePitchClasses[position],
    ];
  }

  void _onMidiPacket(MidiPacket packet) {
    final data = packet.data;
    if (data.length < 3) return;

    final status = data[0] & 0xF0;
    final isNoteOn = status == 0x90 && data[2] > 0;
    if (isNoteOn) simulateMidi(data[1]);
  }

  void simulateMidi(int midiNumber) {
    final currentState = state;
    if (currentState is! SimpleNoteExerciseRunning) return;
    if (currentState.noteState != NoteState.idle) return;

    final isCorrect = midiNumber % 12 == currentState.currentPitchClass;
    _responseTimesMs.add(_now().difference(_noteShownAt).inMilliseconds);

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

    _noteShownAt = _now();
    state = SimpleNoteExerciseRunning(
      pitchClasses: currentState.pitchClasses,
      currentIndex: nextIndex,
      noteState: NoteState.idle,
    );
  }
}
