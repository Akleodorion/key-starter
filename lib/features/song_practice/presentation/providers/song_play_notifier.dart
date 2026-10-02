import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:key_starter/core/enums/note_state.dart';
import 'package:key_starter/core/input/input_event.dart';
import 'package:key_starter/core/input/input_source_provider.dart';
import 'package:key_starter/core/utils/held_keys_tracker.dart';
import 'package:key_starter/core/utils/note_feedback_motion.dart';
import 'package:key_starter/core/utils/two_staff_judgement.dart';
import 'package:key_starter/features/song_practice/presentation/providers/playable_events.dart';
import 'package:key_starter/features/song_practice/presentation/providers/song_play_config.dart';
import 'package:key_starter/features/song_practice/presentation/providers/song_play_state.dart';

final songPlayProvider = NotifierProvider.autoDispose
    .family<SongPlayNotifier, SongPlayState, SongPlayConfig>(
      (config) => SongPlayNotifier(config),
    );

/// Durée du message de reprise entre la fin d'une section ratée et son
/// nouveau départ.
const sectionRetryDelay = Duration(milliseconds: 1500);

class SongPlayNotifier extends Notifier<SongPlayState> {
  final SongPlayConfig _config;
  int _playablePosition = 0;
  int _errorCount = 0;
  Map<int, TwoStaffVerdict> _judgedVerdicts = const {};
  late HeldKeysTracker _tracker;
  Timer? _advanceTimer;
  Timer? _retryTimer;
  final Set<int> _pressedDuringFeedback = {};

  SongPlayNotifier(this._config);

  late final List<int> _playableEventIndices = playableEventIndices(
    _config.song,
    _config.hands,
    _config.section,
  );

  @override
  SongPlayState build() {
    final subscription = ref
        .read(inputSourceProvider)
        .events
        .listen(_onInputEvent);
    ref.onDispose(() {
      subscription.cancel();
      _advanceTimer?.cancel();
      _retryTimer?.cancel();
    });
    return _firstState();
  }

  SongPlayState _firstState() {
    _playablePosition = 0;
    _errorCount = 0;
    _judgedVerdicts = const {};
    if (_playableEventIndices.isEmpty) {
      return const SongPlayFinished();
    }
    return _startEvent();
  }

  SongPlayRunning _startEvent() {
    final eventIndex = _playableEventIndices[_playablePosition];
    final event = _config.song.events[eventIndex];
    final expected = expectedNotes(event, _config.hands);
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
    final expected = expectedNotes(currentState.currentEvent, _config.hands);
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
      _endSection();
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

  // Une section ratée reprend du début après le message de reprise ; une
  // section jouée sans erreur est réussie.
  void _endSection() {
    if (_errorCount == 0) {
      state = const SongPlayFinished();
      return;
    }
    state = SongPlayRetrying(errorCount: _errorCount);
    _retryTimer = Timer(sectionRetryDelay, () {
      _retryTimer = null;
      state = _firstState();
    });
  }

  /// Reprend la section au premier événement, compteur d'erreurs à zéro.
  void restart() {
    _advanceTimer?.cancel();
    _advanceTimer = null;
    _retryTimer?.cancel();
    _retryTimer = null;
    _pressedDuringFeedback.clear();
    state = _firstState();
  }
}
