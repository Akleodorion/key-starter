import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:key_starter/core/enums/clef_mode.dart';
import 'package:key_starter/core/widgets/staff_widget.dart';
import 'package:key_starter/features/session/presentation/providers/session_setup_notifier.dart';
import 'package:key_starter/features/session/presentation/providers/session_setup_state.dart';

/// Bandeau d'en-tête de la page de configuration.
class SessionSetupHeader extends ConsumerWidget {
  const SessionSetupHeader({super.key});

  /// Marche diatonique inférieure de référence par clef.
  /// +4 (quarte) donne la note affichée dans le preview de la portée.
  static const _bottomStep = {ClefMode.treble: 2, ClefMode.bass: -10};

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(sessionSetupNotifierProvider);
    final clef = state is SessionSetupLoaded ? state.clef : ClefMode.treble;
    final diatonicStep = _bottomStep[clef]! + 4;

    return Container(
      color: Colors.amber,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            color: Colors.black26,
            child: const Column(
              children: [
                Text("AUJOURD'HUI"),
                Text('Une session lecture', style: TextStyle(fontSize: 18)),
              ],
            ),
          ),
          Container(
            color: Colors.black26,
            child: StaffWidget(
              diatonicStep: diatonicStep,
              clef: clef,
              staffwidth: 175,
            ),
          ),
        ],
      ),
    );
  }
}
