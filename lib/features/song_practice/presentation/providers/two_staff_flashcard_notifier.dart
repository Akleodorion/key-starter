import 'dart:async';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:key_starter/core/enums/note_state.dart';
import 'package:key_starter/core/input/input_event.dart';
import 'package:key_starter/core/input/input_source_provider.dart';
import 'package:key_starter/core/models/two_staff_event.dart';
import 'package:key_starter/core/utils/held_keys_tracker.dart';
import 'package:key_starter/core/utils/note_feedback_motion.dart';
import 'package:key_starter/core/utils/two_staff_judgement.dart';
import 'package:key_starter/features/song_practice/presentation/providers/two_staff_flashcard_state.dart';

final twoStaffFlashcardProvider =
    NotifierProvider.autoDispose<
      TwoStaffFlashcardNotifier,
      TwoStaffFlashcardState
    >(TwoStaffFlashcardNotifier.new);

const _trebleLowestStep = 0;
const _trebleHighestStep = 11;
const _bassLowestStep = -14;
const _bassHighestStep = -3;

/// Tire un événement deux portées : chaque portée reçoit, au hasard, une note
/// seule ou un accord à l'état fondamental dans sa tessiture fixe.
TwoStaffEvent drawTwoStaffEvent(Random random) => TwoStaffEvent(
  trebleSteps: _drawNoteGroup(random, _trebleLowestStep, _trebleHighestStep),
  bassSteps: _drawNoteGroup(random, _bassLowestStep, _bassHighestStep),
);

List<int> _drawNoteGroup(Random random, int lowestStep, int highestStep) {
  if (random.nextBool()) {
    return [lowestStep + random.nextInt(highestStep - lowestStep + 1)];
  }
  final highestRoot = highestStep - 4;
  final root = lowestStep + random.nextInt(highestRoot - lowestStep + 1);
  return [root, root + 2, root + 4];
}

class TwoStaffFlashcardNotifier extends Notifier<TwoStaffFlashcardState> {
  final Random _random = Random();
  late HeldKeysTracker _tracker;
  final Set<int> _heldMidiNumbers = {};
  Timer? _advanceTimer;

  @override
  TwoStaffFlashcardState build() {
    final subscription = ref
        .read(inputSourceProvider)
        .events
        .listen(_onInputEvent);
    ref.onDispose(() {
      subscription.cancel();
      _advanceTimer?.cancel();
    });
    return _startEvent();
  }

  TwoStaffFlashcardRunning _startEvent() {
    final event = drawTwoStaffEvent(_random);
    _tracker = HeldKeysTracker(
      expectedKeyCount: event.trebleSteps.length + event.bassSteps.length,
    );
    return TwoStaffFlashcardRunning(event: event, noteState: NoteState.idle);
  }

  void _onInputEvent(InputEvent inputEvent) {
    switch (inputEvent) {
      case NotePlayed(:final midiNumber):
        _heldMidiNumbers.add(midiNumber);
      case NoteReleased(:final midiNumber):
        _heldMidiNumbers.remove(midiNumber);
    }
    final currentState = state;
    if (currentState is! TwoStaffFlashcardRunning) return;
    if (currentState.noteState != NoteState.idle) {
      _advanceOnceAllKeysReleased();
      return;
    }
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

  void _judge(
    TwoStaffFlashcardRunning currentState,
    Set<int> playedMidiNumbers,
  ) {
    final verdict = judgeTwoStaffEvent(currentState.event, playedMidiNumbers);
    state = currentState.copyWith(
      noteState: verdict.isCorrect ? NoteState.correct : NoteState.wrong,
      verdict: verdict,
    );
    _advanceOnceAllKeysReleased();
  }

  void _advanceOnceAllKeysReleased() {
    if (_heldMidiNumbers.isNotEmpty || _advanceTimer != null) return;
    _advanceTimer = Timer(noteAdvanceDelay, () {
      _advanceTimer = null;
      state = _startEvent();
    });
  }
}
