import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:key_starter/core/enums/note_state.dart';
import 'package:key_starter/core/input/input_event.dart';
import 'package:key_starter/core/input/input_source_provider.dart';
import 'package:key_starter/core/utils/note_utils.dart';
import 'package:key_starter/core/utils/tempo_timeline.dart';
import 'package:key_starter/features/chord_recognition/presentation/providers/chord_tempo_exercise_config.dart';
import 'package:key_starter/features/chord_recognition/presentation/providers/chord_tempo_exercise_state.dart';

final chordTempoExerciseProvider = NotifierProvider.autoDispose
    .family<
      ChordTempoExerciseNotifier,
      ChordTempoExerciseState,
      ChordTempoExerciseConfig
    >((config) => ChordTempoExerciseNotifier(config));

/// Durée de regroupement des Note On MIDI en un accord : le MIDI n'a pas de
/// message « accord », seulement des Note On à quelques millisecondes d'écart.
const _detectionWindow = Duration(milliseconds: 100);

/// Partie de l'exercice Tempo Accords : la chronologie démarre à la
/// construction du notifier. Un accord est daté par sa première note et jugé
/// à la fin du regroupement. Le premier accord dans la fenêtre d'un temps le
/// décide ; un accord hors fenêtre est une erreur sur le prochain temps encore
/// ouvert ; un temps sans accord est raté à la fermeture de sa fenêtre.
class ChordTempoExerciseNotifier extends Notifier<ChordTempoExerciseState> {
  final ChordTempoExerciseConfig _config;
  final DateTime Function() _now;
  final Random _random;
  final TempoTimeline timeline;

  late final DateTime _startTime;
  Duration _pausedDuration = Duration.zero;
  DateTime? _pausedAt;
  Timer? _windowCloseTimer;
  Timer? _detectionTimer;
  Duration? _pendingChordStart;
  final Set<int> _pendingSteps = {};
  int _nextWindowToClose = 0;
  int _correctCount = 0;
  int _currentStreak = 0;
  int _bestStreak = 0;
  final List<int> _timingOffsetsMs = [];

  ChordTempoExerciseNotifier(
    this._config, {
    DateTime Function()? now,
    Random? random,
  }) : _now = now ?? DateTime.now,
       _random = random ?? Random(),
       timeline = TempoTimeline(
         bpm: _config.bpm,
         noteCount: _config.settings.noteCount,
       );

  /// Temps de jeu écoulé depuis le début du décompte, pauses exclues : figé
  /// pendant une pause.
  Duration get elapsed => _elapsedAt(_pausedAt ?? _now());

  bool get isPaused => _pausedAt != null;

  Duration _elapsedAt(DateTime time) =>
      time.difference(_startTime) - _pausedDuration;

  /// Accord que la barre vise en ce moment : celui dont la fenêtre est
  /// ouverte, sinon le prochain encore ouvert. Null une fois tout décidé.
  List<int>? get currentTargetChord {
    final currentState = state;
    if (currentState is! ChordTempoExerciseRunning) return null;
    final targetIndex = _targetIndexAt(currentState, elapsed);
    return targetIndex == null ? null : currentState.chordSteps[targetIndex];
  }

  @override
  ChordTempoExerciseState build() {
    final subscription = ref
        .read(inputSourceProvider)
        .events
        .listen(_onInputEvent);
    ref.onDispose(() {
      subscription.cancel();
      _windowCloseTimer?.cancel();
      _detectionTimer?.cancel();
    });

    _startTime = _now();
    _scheduleNextWindowClose();
    final chordCount = _config.settings.noteCount;
    return ChordTempoExerciseRunning(
      chordSteps: _generateChords(),
      chordStates: List.filled(chordCount, NoteState.idle),
    );
  }

  void simulateMidi(List<int> midiNumbers) {
    for (final midiNumber in midiNumbers) {
      _onNoteOn(midiNumber, elapsed);
    }
  }

  /// Suspend la chronologie (clavier débranché) : la barre s'arrête, aucune
  /// fenêtre ne se ferme, l'accord en cours de regroupement est abandonné et
  /// les notes jouées sont ignorées.
  void pause() {
    if (isPaused || state is! ChordTempoExerciseRunning) return;
    _pausedAt = _now();
    _windowCloseTimer?.cancel();
    _detectionTimer?.cancel();
    _detectionTimer = null;
    _pendingChordStart = null;
    _pendingSteps.clear();
  }

  /// Reprend la chronologie là où elle s'était arrêtée.
  void resume() {
    final pausedAt = _pausedAt;
    if (pausedAt == null) return;
    _pausedDuration += _now().difference(pausedAt);
    _pausedAt = null;
    _scheduleNextWindowClose();
  }

  void _onInputEvent(InputEvent event) {
    if (event is NotePlayed) {
      _onNoteOn(event.midiNumber, _elapsedAt(event.attackTime));
    }
  }

  List<List<int>> _generateChords() {
    final settings = _config.settings;
    final maxRoot = max(settings.minNoteStep, settings.maxNoteStep - 4);
    final range = maxRoot - settings.minNoteStep + 1;
    return List.generate(settings.noteCount, (_) {
      final root = settings.minNoteStep + _random.nextInt(range);
      return [root, root + 2, root + 4];
    });
  }

  void _onNoteOn(int midiNumber, Duration playedAt) {
    if (isPaused) return;
    if (_pendingChordStart == null && timeline.isCountIn(playedAt)) return;
    final step = diatonicStepFromMidi(midiNumber);
    if (step == null) return;

    _pendingChordStart ??= playedAt;
    _pendingSteps.add(step);
    _detectionTimer ??= Timer(_detectionWindow, _evaluatePendingChord);
  }

  void _evaluatePendingChord() {
    final chordStart = _pendingChordStart!;
    final playedSteps = {..._pendingSteps};
    _detectionTimer = null;
    _pendingChordStart = null;
    _pendingSteps.clear();

    _closeWindowsBefore(chordStart);
    final currentState = state;
    if (currentState is ChordTempoExerciseRunning) {
      _judgeChord(currentState, playedSteps, chordStart);
    }
    _closeWindowsBefore(elapsed);
    _scheduleNextWindowClose();
  }

  void _judgeChord(
    ChordTempoExerciseRunning running,
    Set<int> playedSteps,
    Duration chordStart,
  ) {
    final windowIndex = timeline.windowIndexAt(chordStart);
    if (windowIndex != null) {
      if (running.chordStates[windowIndex] != NoteState.idle) return;
      final isCorrect = setEquals(
        playedSteps,
        running.chordSteps[windowIndex].toSet(),
      );
      if (isCorrect) {
        final offset = chordStart - timeline.noteTime(windowIndex);
        _timingOffsetsMs.add((offset.inMicroseconds / 1000).round());
      }
      _resolve(windowIndex, isCorrect: isCorrect);
      return;
    }

    final targetIndex = _targetIndexAt(running, chordStart);
    if (targetIndex != null) _resolve(targetIndex, isCorrect: false);
  }

  int? _targetIndexAt(ChordTempoExerciseRunning running, Duration at) {
    final windowIndex = timeline.windowIndexAt(at);
    if (windowIndex != null &&
        running.chordStates[windowIndex] == NoteState.idle) {
      return windowIndex;
    }
    for (var index = 0; index < running.total; index++) {
      final isOpen =
          running.chordStates[index] == NoteState.idle &&
          timeline.windowClose(index) >= at;
      if (isOpen) return index;
    }
    return null;
  }

  void _resolve(int index, {required bool isCorrect}) {
    final currentState = state;
    if (currentState is! ChordTempoExerciseRunning) return;

    if (isCorrect) {
      _correctCount++;
      _currentStreak++;
      _bestStreak = max(_bestStreak, _currentStreak);
    } else {
      _currentStreak = 0;
    }
    final chordStates = [...currentState.chordStates];
    chordStates[index] = isCorrect ? NoteState.correct : NoteState.wrong;
    state = currentState.copyWith(chordStates: chordStates);
  }

  /// Marque ratés les temps restés sans accord dont la fenêtre s'est fermée
  /// avant [at], puis termine la partie si c'était le dernier.
  void _closeWindowsBefore(Duration at) {
    while (_nextWindowToClose < timeline.noteCount &&
        timeline.windowClose(_nextWindowToClose) < at) {
      final currentState = state;
      if (currentState is ChordTempoExerciseRunning &&
          currentState.chordStates[_nextWindowToClose] == NoteState.idle) {
        _resolve(_nextWindowToClose, isCorrect: false);
      }
      _nextWindowToClose++;
    }
    if (_nextWindowToClose == timeline.noteCount) _complete();
  }

  /// Programme la fermeture de la prochaine fenêtre. Un accord en cours de
  /// regroupement la reporte : c'est son jugement qui refermera les fenêtres.
  void _scheduleNextWindowClose() {
    _windowCloseTimer?.cancel();
    if (_nextWindowToClose >= timeline.noteCount) return;
    const justAfterClosing = Duration(microseconds: 1);
    final delay =
        timeline.windowClose(_nextWindowToClose) - elapsed + justAfterClosing;
    _windowCloseTimer = Timer(delay, () {
      if (_pendingChordStart != null) return;
      _closeWindowsBefore(elapsed);
      _scheduleNextWindowClose();
    });
  }

  void _complete() {
    if (state is! ChordTempoExerciseRunning) return;
    _windowCloseTimer?.cancel();
    _detectionTimer?.cancel();
    state = ChordTempoExerciseCompleted(
      correctCount: _correctCount,
      totalChords: timeline.noteCount,
      avgTimingOffsetMs: _timingOffsetsMs.isEmpty
          ? null
          : (_timingOffsetsMs.reduce((sum, offset) => sum + offset) /
                    _timingOffsetsMs.length)
                .round(),
      bestStreak: _bestStreak,
    );
  }
}
