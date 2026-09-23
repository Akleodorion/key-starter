import 'dart:async';
import 'dart:math';

import 'package:flutter_midi_command/flutter_midi_command.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:key_starter/core/enums/note_state.dart';
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
  Timer? _advanceTimer;

  FlashcardExerciseNotifier(this._settings);

  @override
  FlashcardExerciseState build() {
    final subscription = MidiCommand().onMidiDataReceived?.listen(
      _onMidiPacket,
    );
    ref.onDispose(() {
      subscription?.cancel();
      _advanceTimer?.cancel();
    });

    _noteStartMs = DateTime.now().millisecondsSinceEpoch;
    return FlashcardExerciseRunning(
      noteSteps: _generateSteps(),
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
      _onMidiReceived(midiNumber);
    } else if (isNoteOff) {
      _onMidiNoteOff(midiNumber);
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

    final nextIndex = currentState.currentIndex + 1;
    _awaitingNoteRelease =
        nextIndex < currentState.total &&
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

    _advanceTimer = Timer(const Duration(milliseconds: 200), _advance);
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
      final avgMs =
          _responseTimes.reduce((a, b) => a + b) ~/ _responseTimes.length;
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
