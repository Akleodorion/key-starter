import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:key_starter/core/input/input_event.dart';
import 'package:key_starter/core/input/input_source_provider.dart';
import 'package:key_starter/core/models/two_staff_event.dart';
import 'package:key_starter/core/utils/two_staff_judgement.dart';
import 'package:key_starter/features/song_practice/presentation/providers/playable_events.dart';
import 'package:key_starter/features/song_practice/presentation/providers/song_play_config.dart';
import 'package:key_starter/features/song_practice/presentation/providers/song_play_notifier.dart';
import 'package:key_starter/features/song_practice/presentation/providers/song_tempo_play_state.dart';
import 'package:key_starter/features/song_practice/presentation/timing/song_tempo_timeline.dart';

final songTempoPlayProvider = NotifierProvider.autoDispose
    .family<SongTempoPlayNotifier, SongTempoPlayState, SongPlayConfig>(
      (config) => SongTempoPlayNotifier(config),
    );

/// Section d'un morceau jouée au tempo : la chronologie démarre à la
/// construction du notifier. Les touches jouées dans la fenêtre d'un
/// événement sont regroupées : il passe juste dès qu'elles correspondent aux
/// notes attendues, sinon il est jugé à la fermeture de sa fenêtre (faux s'il
/// n'a pas été joué). Une touche hors de toute fenêtre rend faux le prochain
/// événement encore ouvert. Au bout de la section, message de reprise puis
/// nouveau décompte.
class SongTempoPlayNotifier extends Notifier<SongTempoPlayState> {
  final SongPlayConfig _config;
  final DateTime Function() _now;
  final SongTempoTimeline timeline;

  late DateTime _startTime;
  DateTime? _pausedAt;
  int _nextWindowToClose = 0;
  int _errorCount = 0;
  Map<int, TwoStaffVerdict> _judgedVerdicts = const {};
  final Map<int, Set<int>> _pressedByPosition = {};
  Timer? _windowCloseTimer;
  Timer? _endTimer;
  Timer? _retryTimer;

  SongTempoPlayNotifier(this._config, {DateTime Function()? now})
    : _now = now ?? DateTime.now,
      timeline = SongTempoTimeline(
        song: _config.song,
        section: _config.section,
        judgedEventIndices: playableEventIndices(
          _config.song,
          _config.hands,
          _config.section,
        ),
        bpm: _config.bpm!,
      );

  /// Temps écoulé depuis le début du décompte ; figé pendant une pause.
  Duration get elapsed => (_pausedAt ?? _now()).difference(_startTime);

  @override
  SongTempoPlayState build() {
    final subscription = ref
        .read(inputSourceProvider)
        .events
        .listen(_onInputEvent);
    ref.onDispose(() {
      subscription.cancel();
      _cancelTimers();
    });
    return _start();
  }

  /// Suspend la section (clavier débranché) : la barre s'arrête, aucune
  /// fenêtre ne se ferme et les touches jouées sont ignorées.
  void pause() {
    if (_pausedAt != null) return;
    _pausedAt = _now();
    _cancelTimers();
  }

  /// Fait repartir la section du décompte, couleurs effacées.
  void resume() {
    if (_pausedAt == null) return;
    state = _start();
  }

  SongTempoPlayRunning _start() {
    _cancelTimers();
    _startTime = _now();
    _pausedAt = null;
    _nextWindowToClose = 0;
    _errorCount = 0;
    _judgedVerdicts = const {};
    _pressedByPosition.clear();
    _scheduleNextWindowClose();
    _endTimer = Timer(timeline.endTime, _endSection);
    return const SongTempoPlayRunning(errorCount: 0);
  }

  void _onInputEvent(InputEvent inputEvent) {
    if (inputEvent is NotePlayed) {
      _onNotePlayed(
        inputEvent.midiNumber,
        inputEvent.attackTime.difference(_startTime),
      );
    }
  }

  void _onNotePlayed(int midiNumber, Duration playedAt) {
    if (_pausedAt != null || state is! SongTempoPlayRunning) return;
    // La fenêtre du premier événement s'ouvre pendant la fin du décompte.
    final isBeforeFirstWindow =
        timeline.eventCount == 0 || playedAt < timeline.windowOpen(0);
    if (isBeforeFirstWindow) return;
    _closeWindowsBefore(playedAt);

    final position = timeline.windowPositionAt(playedAt);
    if (position != null) {
      if (_isJudged(position)) return;
      final pressed = _pressedByPosition.putIfAbsent(position, () => {})
        ..add(midiNumber);
      final verdict = judgeTwoStaffEvent(_expectedAt(position), pressed);
      if (verdict.isCorrect) _resolve(position, verdict);
      return;
    }

    final targetPosition = _nextOpenPosition(playedAt);
    if (targetPosition != null) {
      _resolve(
        targetPosition,
        _mistimedVerdict(_expectedAt(targetPosition), midiNumber),
      );
    }
  }

  /// Verdict d'un événement visé par une touche jouée hors de sa fenêtre :
  /// chaque portée qui attendait des notes est fausse, comme celle qui reçoit
  /// la touche.
  TwoStaffVerdict _mistimedVerdict(TwoStaffEvent expected, int midiNumber) {
    final verdict = judgeTwoStaffEvent(expected, {midiNumber});
    return TwoStaffVerdict(
      treble: StaffPartVerdict(
        isCorrect: verdict.treble.isCorrect && expected.trebleSteps.isEmpty,
        playedMidiNumbers: verdict.treble.playedMidiNumbers,
      ),
      bass: StaffPartVerdict(
        isCorrect: verdict.bass.isCorrect && expected.bassSteps.isEmpty,
        playedMidiNumbers: verdict.bass.playedMidiNumbers,
      ),
    );
  }

  TwoStaffEvent _expectedAt(int position) => expectedNotes(
    _config.song.events[timeline.eventIndexAt(position)],
    _config.hands,
  );

  bool _isJudged(int position) =>
      _judgedVerdicts.containsKey(timeline.eventIndexAt(position));

  int? _nextOpenPosition(Duration at) {
    for (
      var position = _nextWindowToClose;
      position < timeline.eventCount;
      position++
    ) {
      if (!_isJudged(position) && timeline.windowClose(position) >= at) {
        return position;
      }
    }
    return null;
  }

  void _resolve(int position, TwoStaffVerdict verdict) {
    final currentState = state;
    if (currentState is! SongTempoPlayRunning) return;
    if (!verdict.isCorrect) _errorCount++;
    _judgedVerdicts = {
      ..._judgedVerdicts,
      timeline.eventIndexAt(position): verdict,
    };
    state = currentState.copyWith(
      errorCount: _errorCount,
      judgedVerdicts: _judgedVerdicts,
    );
  }

  /// Juge, sur les touches regroupées, les événements encore ouverts dont la
  /// fenêtre s'est fermée avant [at].
  void _closeWindowsBefore(Duration at) {
    while (_nextWindowToClose < timeline.eventCount &&
        timeline.windowClose(_nextWindowToClose) < at) {
      if (!_isJudged(_nextWindowToClose)) {
        _resolve(
          _nextWindowToClose,
          judgeTwoStaffEvent(
            _expectedAt(_nextWindowToClose),
            _pressedByPosition[_nextWindowToClose] ?? const {},
          ),
        );
      }
      _nextWindowToClose++;
    }
  }

  void _scheduleNextWindowClose() {
    _windowCloseTimer?.cancel();
    if (_nextWindowToClose >= timeline.eventCount) return;
    const justAfterClosing = Duration(microseconds: 1);
    final delay =
        timeline.windowClose(_nextWindowToClose) - elapsed + justAfterClosing;
    _windowCloseTimer = Timer(delay, () {
      _closeWindowsBefore(elapsed);
      _scheduleNextWindowClose();
    });
  }

  // Une section terminée reprend toujours du décompte après le message de
  // reprise : on n'en sort qu'en quittant la page.
  void _endSection() {
    _windowCloseTimer?.cancel();
    _closeWindowsBefore(timeline.endTime + timeline.countInDuration);
    state = SongTempoPlayRetrying(errorCount: _errorCount);
    _retryTimer = Timer(sectionRetryDelay, () => state = _start());
  }

  void _cancelTimers() {
    _windowCloseTimer?.cancel();
    _endTimer?.cancel();
    _retryTimer?.cancel();
  }
}
