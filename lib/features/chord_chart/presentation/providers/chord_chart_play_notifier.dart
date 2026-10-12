import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:key_starter/core/enums/note_state.dart';
import 'package:key_starter/core/input/input_event.dart';
import 'package:key_starter/core/input/input_source_provider.dart';
import 'package:key_starter/core/utils/note_feedback_motion.dart';
import 'package:key_starter/features/chord_chart/domain/entities/chord_chart.dart';
import 'package:key_starter/features/chord_chart/presentation/judging/chord_attempt_tracker.dart';
import 'package:key_starter/features/chord_chart/presentation/providers/chord_chart_play_state.dart';

final chordChartPlayProvider = NotifierProvider.autoDispose
    .family<ChordChartPlayNotifier, ChordChartPlayState, ChordChart>(
      (chart) => ChordChartPlayNotifier(chart),
    );

/// Durée du message de reprise entre la fin de la grille et son nouveau
/// départ.
const chordChartRetryDelay = Duration(milliseconds: 1500);

/// Jeu d'une grille en tempo Libre : une frappe par case, à deux mains.
class ChordChartPlayNotifier extends Notifier<ChordChartPlayState> {
  final ChordChart _chart;
  final Set<int> _heldKeys = {};
  late ChordAttemptTracker _tracker;
  Timer? _advanceTimer;
  Timer? _retryTimer;

  ChordChartPlayNotifier(this._chart);

  @override
  ChordChartPlayState build() {
    final subscription = ref
        .read(inputSourceProvider)
        .events
        .listen(_onInputEvent);
    ref.onDispose(() {
      subscription.cancel();
      _advanceTimer?.cancel();
      _retryTimer?.cancel();
    });
    return _startCell(
      const ChordChartPlayRunning(
        currentCellIndex: 0,
        cellState: NoteState.idle,
        errorCount: 0,
      ),
    );
  }

  ChordChartPlayRunning _startCell(ChordChartPlayRunning running) {
    _tracker = ChordAttemptTracker(
      expected: _chart.cells[running.currentCellIndex].chord,
      alreadyHeld: _heldKeys,
    );
    return running;
  }

  void _onInputEvent(InputEvent event) {
    switch (event) {
      case NotePlayed(:final midiNumber):
        _heldKeys.add(midiNumber);
      case NoteReleased(:final midiNumber):
        _heldKeys.remove(midiNumber);
    }
    final running = state;
    if (running is! ChordChartPlayRunning ||
        running.cellState != NoteState.idle) {
      return;
    }
    final outcome = switch (event) {
      NotePlayed(:final midiNumber) => _tracker.press(midiNumber),
      NoteReleased(:final midiNumber) => _tracker.release(midiNumber),
    };
    switch (outcome) {
      case ChordAttemptPending():
        return;
      case ChordAttemptCorrect():
        _judge(running, isCorrect: true);
      case ChordAttemptWrong():
        _judge(running, isCorrect: false);
    }
  }

  void _judge(ChordChartPlayRunning running, {required bool isCorrect}) {
    state = running.copyWith(
      cellState: isCorrect ? NoteState.correct : NoteState.wrong,
      errorCount: running.errorCount + (isCorrect ? 0 : 1),
      cellResults: {
        ...running.cellResults,
        running.currentCellIndex: isCorrect,
      },
    );
    _advanceTimer = Timer(noteAdvanceDelay, _advance);
  }

  void _advance() {
    final running = state as ChordChartPlayRunning;
    final nextCellIndex = running.currentCellIndex + 1;
    if (nextCellIndex < _chart.cells.length) {
      state = _startCell(
        running.copyWith(
          currentCellIndex: nextCellIndex,
          cellState: NoteState.idle,
        ),
      );
      return;
    }
    state = ChordChartPlayRetrying(errorCount: running.errorCount);
    _retryTimer = Timer(
      chordChartRetryDelay,
      () => state = _startCell(
        const ChordChartPlayRunning(
          currentCellIndex: 0,
          cellState: NoteState.idle,
          errorCount: 0,
        ),
      ),
    );
  }
}
