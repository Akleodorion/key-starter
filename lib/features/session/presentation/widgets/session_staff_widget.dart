import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:key_starter/core/enums/clef_mode.dart';
import 'package:key_starter/core/widgets/staff_widget.dart';
import 'package:key_starter/features/session/presentation/providers/session_setup_notifier.dart';
import 'package:key_starter/features/session/presentation/providers/session_setup_state.dart';

/// Implémentation de [StaffWidget] liée à [sessionSetupNotifierProvider].
///
/// Affiche une note de prévisualisation (+4 degrés diatoniques depuis la
/// ligne inférieure de la clef) qui reflète la clef sélectionnée.
class SessionStaffWidget extends StaffWidget {
  const SessionStaffWidget({super.key, super.staffwidth});

  // _bottomStep (référence interne de _StaffPainter) + 4 (quarte diatonique)
  static const _previewStep = {ClefMode.treble: 6, ClefMode.bass: -6};

  SessionSetupLoaded? _loaded(WidgetRef ref) {
    final state = ref.watch(sessionSetupNotifierProvider);
    return state is SessionSetupLoaded ? state : null;
  }

  @override
  ClefMode clef(WidgetRef ref) => _loaded(ref)?.clef ?? ClefMode.treble;

  @override
  int? diatonicStep(WidgetRef ref) => _previewStep[clef(ref)];

  @override
  NoteState noteState(WidgetRef ref) => NoteState.idle;
}
