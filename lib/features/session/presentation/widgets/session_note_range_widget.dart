import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:key_starter/core/enums/clef_mode.dart';
import 'package:key_starter/core/enums/note_language.dart';
import 'package:key_starter/core/widgets/note_range_widget.dart';
import 'package:key_starter/features/session/presentation/providers/session_setup_notifier.dart';
import 'package:key_starter/features/session/presentation/providers/session_setup_state.dart';

/// Implémentation de [NoteRangeWidget] liée à [sessionSetupNotifierProvider].
class SessionNoteRangeWidget extends NoteRangeWidget {
  const SessionNoteRangeWidget({super.key});

  SessionSetupLoaded? _state(WidgetRef ref) {
    final state = ref.watch(sessionSetupNotifierProvider);
    return state is SessionSetupLoaded ? state : null;
  }

  @override
  ClefMode clef(WidgetRef ref) => _state(ref)?.clef ?? ClefMode.treble;

  @override
  int minStep(WidgetRef ref) => _state(ref)?.minStep ?? 0;

  @override
  int maxStep(WidgetRef ref) => _state(ref)?.maxStep ?? 7;

  @override
  NoteLanguage language(WidgetRef ref) =>
      _state(ref)?.noteLanguage ?? NoteLanguage.fr;

  @override
  void onMinChanged(WidgetRef ref, int step) =>
      ref.read(sessionSetupNotifierProvider.notifier).setMinStep(step);

  @override
  void onMaxChanged(WidgetRef ref, int step) =>
      ref.read(sessionSetupNotifierProvider.notifier).setMaxStep(step);
}
