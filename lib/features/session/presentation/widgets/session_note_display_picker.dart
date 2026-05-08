import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:key_starter/core/enums/note_language.dart';
import 'package:key_starter/core/widgets/note_display_picker.dart';
import 'package:key_starter/features/session/presentation/providers/session_setup_notifier.dart';
import 'package:key_starter/features/session/presentation/providers/session_setup_state.dart';

/// Implémentation de [NoteDisplayPicker] liée à [sessionSetupNotifierProvider].
class SessionNoteDisplayPicker extends NoteDisplayPicker {
  const SessionNoteDisplayPicker({super.key});

  @override
  NoteLanguage? value(WidgetRef ref) {
    final state = ref.watch(sessionSetupNotifierProvider);
    return state is SessionSetupLoaded ? state.noteLanguage : null;
  }

  @override
  void onChanged(WidgetRef ref, NoteLanguage? lang) =>
      ref.read(sessionSetupNotifierProvider.notifier).setNoteLanguage(lang);
}
