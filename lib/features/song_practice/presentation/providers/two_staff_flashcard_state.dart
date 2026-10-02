import 'package:equatable/equatable.dart';
import 'package:key_starter/core/enums/note_state.dart';
import 'package:key_starter/core/models/two_staff_event.dart';
import 'package:key_starter/core/utils/two_staff_judgement.dart';

sealed class TwoStaffFlashcardState extends Equatable {
  const TwoStaffFlashcardState();
}

class TwoStaffFlashcardRunning extends TwoStaffFlashcardState {
  final TwoStaffEvent event;
  final NoteState noteState;
  final TwoStaffVerdict? verdict;

  const TwoStaffFlashcardRunning({
    required this.event,
    required this.noteState,
    this.verdict,
  });

  TwoStaffFlashcardRunning copyWith({
    TwoStaffEvent? event,
    NoteState? noteState,
    TwoStaffVerdict? verdict,
  }) => TwoStaffFlashcardRunning(
    event: event ?? this.event,
    noteState: noteState ?? this.noteState,
    verdict: verdict ?? this.verdict,
  );

  @override
  List<Object?> get props => [event, noteState, verdict];
}
