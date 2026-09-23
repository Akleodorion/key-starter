import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_midi_command/flutter_midi_command.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:key_starter/core/enums/note_state.dart';
import 'package:key_starter/core/utils/note_utils.dart';
import 'package:key_starter/features/chord_recognition/presentation/providers/chord_flashcard_exercise_state.dart';
import 'package:key_starter/features/note_recognition/presentation/providers/note_exercise_settings_state.dart';

final chordFlashcardExerciseProvider = NotifierProvider.autoDispose
    .family<
      ChordFlashcardExerciseNotifier,
      ChordFlashcardExerciseState,
      NoteExerciseSettings
    >((settings) => ChordFlashcardExerciseNotifier(settings));

/// Durée de la fenêtre de regroupement des Note On MIDI : le protocole MIDI
/// n'a pas de message "accord" natif, un accord n'est qu'une suite de Note On
/// séparés de quelques millisecondes.
const _detectionWindow = Duration(milliseconds: 100);

class ChordFlashcardExerciseNotifier
    extends Notifier<ChordFlashcardExerciseState> {
  final NoteExerciseSettings _settings;
  int _correctCount = 0;
  int _currentStreak = 0;
  int _bestStreak = 0;
  int? _chordStartMs;
  final List<int> _responseTimes = [];

  Timer? _detectionTimer;
  Timer? _advanceTimer;
  final Set<int> _pendingDiatonicSteps = {};
  final Set<int> _pendingMidiNumbers = {};
  final Set<int> _awaitingReleaseMidiNumbers = {};

  ChordFlashcardExerciseNotifier(this._settings);

  @override
  ChordFlashcardExerciseState build() {
    final subscription = MidiCommand().onMidiDataReceived?.listen(
      _onMidiPacket,
    );
    ref.onDispose(() {
      subscription?.cancel();
      _detectionTimer?.cancel();
      _advanceTimer?.cancel();
    });

    _chordStartMs = DateTime.now().millisecondsSinceEpoch;
    return ChordFlashcardExerciseRunning(
      chordSteps: _generateChords(),
      currentIndex: 0,
      noteState: NoteState.idle,
    );
  }

  void _onMidiPacket(MidiPacket packet) {
    final data = packet.data;
    if (data.length < 3) return;

    final status = data[0] & 0xF0;
    final midiNumber = data[1];
    final velocity = data[2];

    final isNoteOn = status == 0x90 && velocity > 0;
    final isNoteOff = status == 0x80 || (status == 0x90 && velocity == 0);

    if (isNoteOn) {
      _onNoteOn(midiNumber);
    } else if (isNoteOff) {
      _onNoteOff(midiNumber);
    }
  }

  List<List<int>> _generateChords() {
    final random = Random();
    final maxRoot = max(_settings.minNoteStep, _settings.maxNoteStep - 4);
    final range = maxRoot - _settings.minNoteStep + 1;
    return List.generate(_settings.noteCount, (_) {
      final root = _settings.minNoteStep + random.nextInt(range);
      return [root, root + 2, root + 4];
    });
  }

  void _onNoteOn(int midiNumber) {
    final currentState = state;
    if (currentState is! ChordFlashcardExerciseRunning) return;
    if (currentState.noteState != NoteState.idle) return;
    if (_awaitingReleaseMidiNumbers.isNotEmpty) return;

    final step = diatonicStepFromMidi(midiNumber);
    if (step == null) return;

    _pendingDiatonicSteps.add(step);
    _pendingMidiNumbers.add(midiNumber);
    _detectionTimer ??= Timer(_detectionWindow, _evaluatePending);
  }

  void _onNoteOff(int midiNumber) {
    _awaitingReleaseMidiNumbers.remove(midiNumber);
  }

  void _evaluatePending() {
    _detectionTimer = null;
    final currentState = state;
    if (currentState is! ChordFlashcardExerciseRunning) return;

    final playedSteps = _pendingDiatonicSteps.toList()..sort();
    _pendingDiatonicSteps.clear();
    _awaitingReleaseMidiNumbers
      ..clear()
      ..addAll(_pendingMidiNumbers);
    _pendingMidiNumbers.clear();

    final responseMs = _chordStartMs != null
        ? DateTime.now().millisecondsSinceEpoch - _chordStartMs!
        : 0;
    _responseTimes.add(responseMs);

    final isCorrect = setEquals(
      playedSteps.toSet(),
      currentState.currentChord.toSet(),
    );

    if (isCorrect) {
      _correctCount++;
      _currentStreak++;
      if (_currentStreak > _bestStreak) _bestStreak = _currentStreak;
    } else {
      _currentStreak = 0;
    }

    state = currentState.copyWith(
      noteState: isCorrect ? NoteState.correct : NoteState.wrong,
      playedSteps: playedSteps,
    );

    _advanceTimer = Timer(const Duration(milliseconds: 200), _advance);
  }

  void simulateMidi(List<int> midiNumbers) {
    _awaitingReleaseMidiNumbers.clear();
    for (final midiNumber in midiNumbers) {
      _onNoteOn(midiNumber);
    }
  }

  void _advance() {
    final currentState = state;
    if (currentState is! ChordFlashcardExerciseRunning) return;

    final nextIndex = currentState.currentIndex + 1;
    if (nextIndex >= currentState.total) {
      final avgMs =
          _responseTimes.reduce((a, b) => a + b) ~/ _responseTimes.length;
      state = ChordFlashcardExerciseCompleted(
        correctCount: _correctCount,
        totalNotes: currentState.total,
        avgResponseMs: avgMs,
        bestStreak: _bestStreak,
      );
    } else {
      _chordStartMs = DateTime.now().millisecondsSinceEpoch;
      state = ChordFlashcardExerciseRunning(
        chordSteps: currentState.chordSteps,
        currentIndex: nextIndex,
        noteState: NoteState.idle,
      );
    }
  }
}
