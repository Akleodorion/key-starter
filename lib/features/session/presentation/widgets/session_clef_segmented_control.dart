import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:key_starter/core/enums/clef_mode.dart';
import 'package:key_starter/core/widgets/clef_segmented_control.dart';
import 'package:key_starter/features/session/presentation/providers/session_setup_notifier.dart';
import 'package:key_starter/features/session/presentation/providers/session_setup_state.dart';

/// Implémentation de [ClefSegmentedControl] liée à [sessionSetupNotifierProvider].
class SessionClefSegmentedControl extends ClefSegmentedControl {
  const SessionClefSegmentedControl({super.key});

  @override
  ClefMode value(WidgetRef ref) {
    final state = ref.watch(sessionSetupNotifierProvider);
    return state is SessionSetupLoaded ? state.clef : ClefMode.treble;
  }

  @override
  void onChanged(WidgetRef ref, ClefMode clef) =>
      ref.read(sessionSetupNotifierProvider.notifier).setClef(clef);
}
