import 'package:equatable/equatable.dart';
import 'package:key_starter/core/enums/note_state.dart';
import 'package:key_starter/core/utils/two_staff_judgement.dart';
import 'package:key_starter/features/song_practice/domain/entities/song_event.dart';

sealed class SongPlayState extends Equatable {
  const SongPlayState();
}

class SongPlayRunning extends SongPlayState {
  final SongEvent currentEvent;
  final NoteState noteState;
  final TwoStaffVerdict? verdict;
  final int errorCount;

  const SongPlayRunning({
    required this.currentEvent,
    required this.noteState,
    required this.errorCount,
    this.verdict,
  });

  SongPlayRunning copyWith({
    SongEvent? currentEvent,
    NoteState? noteState,
    TwoStaffVerdict? verdict,
    int? errorCount,
  }) => SongPlayRunning(
    currentEvent: currentEvent ?? this.currentEvent,
    noteState: noteState ?? this.noteState,
    verdict: verdict ?? this.verdict,
    errorCount: errorCount ?? this.errorCount,
  );

  @override
  List<Object?> get props => [currentEvent, noteState, verdict, errorCount];
}

class SongPlayFinished extends SongPlayState {
  final int errorCount;

  const SongPlayFinished({required this.errorCount});

  @override
  List<Object?> get props => [errorCount];
}
