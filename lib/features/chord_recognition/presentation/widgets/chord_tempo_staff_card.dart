import 'package:flutter/material.dart';
import 'package:key_starter/core/enums/clef_mode.dart';
import 'package:key_starter/core/enums/note_state.dart';
import 'package:key_starter/core/theme/app_color_theme.dart';
import 'package:key_starter/core/widgets/tempo_count_in_label.dart';
import 'package:key_starter/core/widgets/tempo_staff_lines.dart';

/// Carte des portées de Tempo Accords : les deux lignes se partagent toute
/// la hauteur disponible, avec le décompte par-dessus.
class ChordTempoStaffCard extends StatelessWidget {
  final List<List<int>> chordSteps;
  final List<NoteState> chordStates;
  final ClefMode clef;
  final double topLine;
  final int barLine;
  final double barFraction;
  final int? countInBeat;

  const ChordTempoStaffCard({
    super.key,
    required this.chordSteps,
    required this.chordStates,
    required this.clef,
    required this.topLine,
    required this.barLine,
    required this.barFraction,
    required this.countInBeat,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColorTheme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border.all(color: colors.line),
        borderRadius: BorderRadius.circular(20),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) => Stack(
          alignment: Alignment.center,
          children: [
            TempoStaffLines(
              noteGroups: chordSteps,
              noteStates: chordStates,
              clef: clef,
              topLine: topLine,
              barLine: barLine,
              barFraction: barFraction,
              lineHeight: constraints.maxHeight / 2,
            ),
            TempoCountInLabel(beat: countInBeat),
          ],
        ),
      ),
    );
  }
}
