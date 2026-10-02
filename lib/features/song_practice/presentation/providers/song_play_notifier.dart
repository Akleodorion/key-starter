import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:key_starter/core/enums/note_state.dart';
import 'package:key_starter/core/input/input_event.dart';
import 'package:key_starter/core/input/input_source_provider.dart';
import 'package:key_starter/core/models/two_staff_event.dart';
import 'package:key_starter/core/utils/held_keys_tracker.dart';
import 'package:key_starter/core/utils/note_feedback_motion.dart';
import 'package:key_starter/core/utils/two_staff_judgement.dart';
import 'package:key_starter/features/song_practice/domain/entities/song_event.dart';
import 'package:key_starter/features/song_practice/presentation/providers/hand_selection.dart';
import 'package:key_starter/features/song_practice/presentation/providers/song_play_config.dart';
import 'package:key_starter/features/song_practice/presentation/providers/song_play_state.dart';

final songPlayProvider = NotifierProvider.autoDispose
    .family<SongPlayNotifier, SongPlayState, SongPlayConfig>(
      (config) => SongPlayNotifier(config),
    );

class SongPlayNotifier extends Notifier<SongPlayState> {
  final SongPlayConfig _config;
  int _playablePosition = 0;
  int _errorCount = 0;
  Map<int, TwoStaffVerdict> _judgedVerdicts = const {};
  late HeldKeysTracker _tracker;
  Timer? _advanceTimer;
  final Set<int> _pressedDuringFeedback = {};

  SongPlayNotifier(this._config);

  /// Indices, dans le morceau, des événements où la main travaillée a au
  /// moins une note à jouer.
  late final List<int> _playableEventIndices = [
    for (var index = 0; index < _config.song.events.length; index++)
      if (_hasExpectedNotes(_config.song.events[index])) index,
  ];

  bool _hasExpectedNotes(SongEvent event) {
    final expected = _expectedNotes(event);
    return expected.trebleSteps.isNotEmpty || expected.bassSteps.isNotEmpty;
  }

  /// Notes jugées pour [event] : celles des mains travaillées seulement.
  TwoStaffEvent _expectedNotes(SongEvent event) => switch (_config.hands) {
    HandSelection.both => event.notes,
    HandSelection.rightOnly => TwoStaffEvent(
      trebleSteps: event.notes.trebleSteps,
      bassSteps: const [],
    ),
    HandSelection.leftOnly => TwoStaffEvent(
      trebleSteps: const [],
      bassSteps: event.notes.bassSteps,
    ),
  };

  @override
  SongPlayState build() {
    final subscription = ref
        .read(inputSourceProvider)
        .events
        .listen(_onInputEvent);
    ref.onDispose(() {
      subscription.cancel();
      _advanceTimer?.cancel();
    });
    return _firstState();
  }

  SongPlayState _firstState() {
    _playablePosition = 0;
    _errorCount = 0;
    _judgedVerdicts = const {};
    if (_playableEventIndices.isEmpty) {
      return const SongPlayFinished(errorCount: 0);
    }
    return _startEvent();
  }

  SongPlayRunning _startEvent() {
    final eventIndex = _playableEventIndices[_playablePosition];
    final event = _config.song.events[eventIndex];
    final expected = _expectedNotes(event);
    _tracker = HeldKeysTracker(
      expectedKeyCount: expected.trebleSteps.length + expected.bassSteps.length,
    );
    return SongPlayRunning(
      currentEventIndex: eventIndex,
      currentEvent: event,
      noteState: NoteState.idle,
      errorCount: _errorCount,
      judgedVerdicts: _judgedVerdicts,
    );
  }

  void _onInputEvent(InputEvent inputEvent) {
    final currentState = state;
    if (currentState is! SongPlayRunning) return;
    if (currentState.noteState != NoteState.idle) {
      switch (inputEvent) {
        case NotePlayed(:final midiNumber):
          _pressedDuringFeedback.add(midiNumber);
        case NoteReleased(:final midiNumber):
          _pressedDuringFeedback.remove(midiNumber);
      }
      return;
    }
    _apply(currentState, inputEvent);
  }

  void _apply(SongPlayRunning currentState, InputEvent inputEvent) {
    final outcome = switch (inputEvent) {
      NotePlayed(:final midiNumber) => _tracker.press(midiNumber),
      NoteReleased(:final midiNumber) => _tracker.release(midiNumber),
    };
    switch (outcome) {
      case HeldKeysPending():
        return;
      case HeldKeysComplete(:final heldMidiNumbers):
        _judge(currentState, heldMidiNumbers);
      case HeldKeysAbandoned(:final playedMidiNumbers):
        _judge(currentState, playedMidiNumbers);
    }
  }

  void _judge(SongPlayRunning currentState, Set<int> playedMidiNumbers) {
    final expected = _expectedNotes(currentState.currentEvent);
    final verdict = judgeTwoStaffEvent(expected, playedMidiNumbers);
    if (!verdict.isCorrect) _errorCount++;
    _judgedVerdicts = {
      ..._judgedVerdicts,
      currentState.currentEventIndex: verdict,
    };
    state = currentState.copyWith(
      noteState: verdict.isCorrect ? NoteState.correct : NoteState.wrong,
      verdict: verdict,
      errorCount: _errorCount,
      judgedVerdicts: _judgedVerdicts,
    );
    _advanceTimer = Timer(noteAdvanceDelay, _advance);
  }

  // Les touches enfoncées pendant le retour visuel sont rejouées sur
  // l'événement suivant, pour qu'un passage rapide ne perde aucune note.
  void _advance() {
    _advanceTimer = null;
    _playablePosition++;
    final pendingPresses = Set.of(_pressedDuringFeedback);
    _pressedDuringFeedback.clear();
    if (_playablePosition >= _playableEventIndices.length) {
      state = SongPlayFinished(errorCount: _errorCount);
      return;
    }
    state = _startEvent();
    for (final midiNumber in pendingPresses) {
      final currentState = state;
      if (currentState is! SongPlayRunning ||
          currentState.noteState != NoteState.idle) {
        return;
      }
      _apply(currentState, NotePlayed(midiNumber, attackTime: DateTime.now()));
    }
  }

  /// Reprend le morceau au premier événement, compteur d'erreurs à zéro.
  void restart() {
    _advanceTimer?.cancel();
    _advanceTimer = null;
    _pressedDuringFeedback.clear();
    state = _firstState();
  }
}
