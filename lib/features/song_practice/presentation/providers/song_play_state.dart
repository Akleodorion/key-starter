import 'package:equatable/equatable.dart';
import 'package:key_starter/core/enums/note_state.dart';
import 'package:key_starter/core/utils/two_staff_judgement.dart';
import 'package:key_starter/features/song_practice/domain/entities/song_event.dart';

sealed class SongPlayState extends Equatable {
  const SongPlayState();
}

class SongPlayRunning extends SongPlayState {
  /// Indice de [currentEvent] dans les événements du morceau.
  final int currentEventIndex;
  final SongEvent currentEvent;
  final NoteState noteState;
  final TwoStaffVerdict? verdict;
  final int errorCount;

  /// Verdict de chaque événement déjà joué, par indice dans le morceau.
  final Map<int, TwoStaffVerdict> judgedVerdicts;

  const SongPlayRunning({
    required this.currentEventIndex,
    required this.currentEvent,
    required this.noteState,
    required this.errorCount,
    this.judgedVerdicts = const {},
    this.verdict,
  });

  SongPlayRunning copyWith({
    int? currentEventIndex,
    SongEvent? currentEvent,
    NoteState? noteState,
    TwoStaffVerdict? verdict,
    int? errorCount,
    Map<int, TwoStaffVerdict>? judgedVerdicts,
  }) => SongPlayRunning(
    currentEventIndex: currentEventIndex ?? this.currentEventIndex,
    currentEvent: currentEvent ?? this.currentEvent,
    noteState: noteState ?? this.noteState,
    verdict: verdict ?? this.verdict,
    errorCount: errorCount ?? this.errorCount,
    judgedVerdicts: judgedVerdicts ?? this.judgedVerdicts,
  );

  @override
  List<Object?> get props => [
    currentEventIndex,
    currentEvent,
    noteState,
    verdict,
    errorCount,
    judgedVerdicts,
  ];
}

class SongPlayFinished extends SongPlayState {
  final int errorCount;

  const SongPlayFinished({required this.errorCount});

  @override
  List<Object?> get props => [errorCount];
}
