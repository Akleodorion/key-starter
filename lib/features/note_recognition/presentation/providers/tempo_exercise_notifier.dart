import 'dart:async';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:key_starter/core/enums/note_state.dart';
import 'package:key_starter/core/input/input_event.dart';
import 'package:key_starter/core/input/input_source_provider.dart';
import 'package:key_starter/core/utils/note_utils.dart';
import 'package:key_starter/features/note_recognition/domain/entities/tempo_timeline.dart';
import 'package:key_starter/features/note_recognition/presentation/providers/tempo_exercise_config.dart';
import 'package:key_starter/features/note_recognition/presentation/providers/tempo_exercise_state.dart';

final tempoExerciseProvider = NotifierProvider.autoDispose
    .family<TempoExerciseNotifier, TempoExerciseState, TempoExerciseConfig>(
      (config) => TempoExerciseNotifier(config),
    );

/// Partie de l'exercice Tempo : la chronologie démarre à la construction du
/// notifier. Le premier appui dans la fenêtre d'une note la décide ; un appui
/// hors fenêtre est une erreur sur la prochaine note encore ouverte ; une note
/// sans appui est ratée à la fermeture de sa fenêtre.
class TempoExerciseNotifier extends Notifier<TempoExerciseState> {
  final TempoExerciseConfig _config;
  final DateTime Function() _now;
  final Random _random;
  final TempoTimeline timeline;

  late final DateTime _startTime;
  Timer? _windowCloseTimer;
  int _nextWindowToClose = 0;
  int _correctCount = 0;
  int _currentStreak = 0;
  int _bestStreak = 0;
  final List<int> _timingOffsetsMs = [];

  TempoExerciseNotifier(
    this._config, {
    DateTime Function()? now,
    Random? random,
  }) : _now = now ?? DateTime.now,
       _random = random ?? Random(),
       timeline = TempoTimeline(
         bpm: _config.bpm,
         noteCount: _config.settings.noteCount,
       );

  /// Temps écoulé depuis le début du décompte.
  Duration get elapsed => _now().difference(_startTime);

  /// Note que la barre vise en ce moment : celle dont la fenêtre est ouverte,
  /// sinon la prochaine encore ouverte. Null une fois tout décidé.
  int? get currentTargetStep {
    final currentState = state;
    if (currentState is! TempoExerciseRunning) return null;
    final targetIndex = _targetIndexAt(currentState, elapsed);
    return targetIndex == null ? null : currentState.noteSteps[targetIndex];
  }

  @override
  TempoExerciseState build() {
    final subscription = ref
        .read(inputSourceProvider)
        .events
        .listen(_onInputEvent);
    ref.onDispose(() {
      subscription.cancel();
      _windowCloseTimer?.cancel();
    });

    _startTime = _now();
    _scheduleNextWindowClose();
    final noteCount = _config.settings.noteCount;
    return TempoExerciseRunning(
      noteSteps: _generateSteps(),
      noteStates: List.filled(noteCount, NoteState.idle),
    );
  }

  void simulateMidi(int midiNumber) => _onNotePlayed(midiNumber, elapsed);

  void _onInputEvent(InputEvent event) {
    if (event is NotePlayed) {
      _onNotePlayed(event.midiNumber, event.attackTime.difference(_startTime));
    }
  }

  List<int> _generateSteps() {
    final settings = _config.settings;
    final range = settings.maxNoteStep - settings.minNoteStep + 1;
    return List.generate(
      settings.noteCount,
      (_) => settings.minNoteStep + _random.nextInt(range),
    );
  }

  void _onNotePlayed(int midiNumber, Duration playedAt) {
    if (timeline.isCountIn(playedAt)) return;
    _closeWindowsBefore(playedAt);
    final currentState = state;
    if (currentState is! TempoExerciseRunning) return;

    final windowIndex = timeline.windowIndexAt(playedAt);
    if (windowIndex != null) {
      if (currentState.noteStates[windowIndex] != NoteState.idle) return;
      final isCorrect =
          diatonicStepFromMidi(midiNumber) ==
          currentState.noteSteps[windowIndex];
      if (isCorrect) {
        final offset = playedAt - timeline.noteTime(windowIndex);
        _timingOffsetsMs.add((offset.inMicroseconds / 1000).round());
      }
      _resolve(windowIndex, isCorrect: isCorrect);
      return;
    }

    final targetIndex = _targetIndexAt(currentState, playedAt);
    if (targetIndex != null) _resolve(targetIndex, isCorrect: false);
  }

  int? _targetIndexAt(TempoExerciseRunning running, Duration at) {
    final windowIndex = timeline.windowIndexAt(at);
    if (windowIndex != null &&
        running.noteStates[windowIndex] == NoteState.idle) {
      return windowIndex;
    }
    for (var index = 0; index < running.total; index++) {
      final isOpen =
          running.noteStates[index] == NoteState.idle &&
          timeline.windowClose(index) >= at;
      if (isOpen) return index;
    }
    return null;
  }

  void _resolve(int index, {required bool isCorrect}) {
    final currentState = state;
    if (currentState is! TempoExerciseRunning) return;

    if (isCorrect) {
      _correctCount++;
      _currentStreak++;
      _bestStreak = max(_bestStreak, _currentStreak);
    } else {
      _currentStreak = 0;
    }
    final noteStates = [...currentState.noteStates];
    noteStates[index] = isCorrect ? NoteState.correct : NoteState.wrong;
    state = currentState.copyWith(noteStates: noteStates);
  }

  /// Marque ratées les notes restées sans appui dont la fenêtre s'est fermée
  /// avant [at], puis termine la partie si c'était la dernière.
  void _closeWindowsBefore(Duration at) {
    while (_nextWindowToClose < timeline.noteCount &&
        timeline.windowClose(_nextWindowToClose) < at) {
      final currentState = state;
      if (currentState is TempoExerciseRunning &&
          currentState.noteStates[_nextWindowToClose] == NoteState.idle) {
        _resolve(_nextWindowToClose, isCorrect: false);
      }
      _nextWindowToClose++;
    }
    if (_nextWindowToClose == timeline.noteCount) _complete();
  }

  void _scheduleNextWindowClose() {
    if (_nextWindowToClose >= timeline.noteCount) return;
    const justAfterClosing = Duration(microseconds: 1);
    final delay =
        timeline.windowClose(_nextWindowToClose) - elapsed + justAfterClosing;
    _windowCloseTimer = Timer(delay, () {
      _closeWindowsBefore(elapsed);
      _scheduleNextWindowClose();
    });
  }

  void _complete() {
    if (state is! TempoExerciseRunning) return;
    _windowCloseTimer?.cancel();
    state = TempoExerciseCompleted(
      correctCount: _correctCount,
      totalNotes: timeline.noteCount,
      avgTimingOffsetMs: _timingOffsetsMs.isEmpty
          ? null
          : (_timingOffsetsMs.reduce((sum, offset) => sum + offset) /
                    _timingOffsetsMs.length)
                .round(),
      bestStreak: _bestStreak,
    );
  }
}
