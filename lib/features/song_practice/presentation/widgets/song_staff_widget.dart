import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:key_starter/core/enums/clef_mode.dart';
import 'package:key_starter/core/enums/note_state.dart';
import 'package:key_starter/core/models/two_staff_event.dart';
import 'package:key_starter/core/widgets/grand_staff_widget.dart';
import 'package:key_starter/features/song_practice/presentation/providers/hand_selection.dart';
import 'package:key_starter/features/song_practice/presentation/providers/song_play_config.dart';
import 'package:key_starter/features/song_practice/presentation/providers/song_play_notifier.dart';
import 'package:key_starter/features/song_practice/presentation/providers/song_play_state.dart';

/// Implémentation de [GrandStaffWidget] liée à [songPlayProvider].
class SongStaffWidget extends GrandStaffWidget {
  final SongPlayConfig config;

  const SongStaffWidget({super.key, required this.config});

  SongPlayRunning? _running(WidgetRef ref) {
    final state = ref.watch(songPlayProvider(config));
    return state is SongPlayRunning ? state : null;
  }

  @override
  TwoStaffEvent? event(WidgetRef ref) => _running(ref)?.currentEvent.notes;

  @override
  NoteState noteState(WidgetRef ref, ClefMode clef) {
    final verdict = _running(ref)?.verdict;
    if (verdict == null || isStaffMuted(ref, clef)) return NoteState.idle;
    final staffVerdict = clef == ClefMode.treble
        ? verdict.treble
        : verdict.bass;
    return staffVerdict.isCorrect ? NoteState.correct : NoteState.wrong;
  }

  @override
  bool isStaffMuted(WidgetRef ref, ClefMode clef) => switch (config.hands) {
    HandSelection.both => false,
    HandSelection.rightOnly => clef == ClefMode.bass,
    HandSelection.leftOnly => clef == ClefMode.treble,
  };
}
