import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:key_starter/core/widgets/session_notes_slider.dart';
import 'package:key_starter/features/session/presentation/providers/session_setup_notifier.dart';
import 'package:key_starter/features/session/presentation/providers/session_setup_state.dart';

/// Implémentation de [SessionNotesSlider] liée à [sessionSetupNotifierProvider].
class SessionTotalNotesSlider extends SessionNotesSlider {
  const SessionTotalNotesSlider({super.key});

  @override
  int value(WidgetRef ref) {
    final state = ref.watch(sessionSetupNotifierProvider);
    return state is SessionSetupLoaded ? state.totalNotes : 20;
  }

  @override
  void onChanged(WidgetRef ref, int n) =>
      ref.read(sessionSetupNotifierProvider.notifier).setTotalNotes(n);
}
