import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:key_starter/core/enums/clef_mode.dart';
import 'package:key_starter/core/enums/note_state.dart';
import 'package:key_starter/core/models/two_staff_event.dart';
import 'package:key_starter/core/widgets/grand_staff_widget.dart';
import 'package:key_starter/features/song_practice/presentation/providers/two_staff_flashcard_notifier.dart';
import 'package:key_starter/features/song_practice/presentation/providers/two_staff_flashcard_state.dart';

/// Implémentation de [GrandStaffWidget] liée à [twoStaffFlashcardProvider].
class TwoStaffFlashcardStaffWidget extends GrandStaffWidget {
  const TwoStaffFlashcardStaffWidget({super.key, super.height});

  TwoStaffFlashcardRunning? _running(WidgetRef ref) {
    final state = ref.watch(twoStaffFlashcardProvider);
    return state is TwoStaffFlashcardRunning ? state : null;
  }

  @override
  TwoStaffEvent? event(WidgetRef ref) => _running(ref)?.event;

  @override
  NoteState noteState(WidgetRef ref, ClefMode clef) {
    final verdict = _running(ref)?.verdict;
    if (verdict == null) return NoteState.idle;
    final staffVerdict = clef == ClefMode.treble
        ? verdict.treble
        : verdict.bass;
    return staffVerdict.isCorrect ? NoteState.correct : NoteState.wrong;
  }
}
