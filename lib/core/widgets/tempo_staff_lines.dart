import 'dart:math';

import 'package:flutter/material.dart';
import 'package:key_starter/core/enums/clef_mode.dart';
import 'package:key_starter/core/enums/note_state.dart';
import 'package:key_starter/core/utils/tempo_timeline.dart';
import 'package:key_starter/core/widgets/tempo_staff_line.dart';

/// Deux lignes de portée visibles, la ligne en cours en haut et la suivante
/// en dessous. Quand [topLine] passe de k à k + 1, les lignes remontent :
/// celle du haut s'efface et la nouvelle apparaît en bas.
class TempoStaffLines extends StatelessWidget {
  static const int _visibleLineCount = 2;

  final List<List<int>> noteGroups;
  final List<NoteState> noteStates;
  final ClefMode clef;
  final double topLine;
  final int barLine;
  final double barFraction;
  final double lineHeight;

  const TempoStaffLines({
    super.key,
    required this.noteGroups,
    required this.noteStates,
    required this.clef,
    required this.topLine,
    required this.barLine,
    required this.barFraction,
    this.lineHeight = 100,
  });

  @override
  Widget build(BuildContext context) {
    const notesPerLine = TempoTimeline.notesPerLine;
    final lineCount = (noteGroups.length / notesPerLine).ceil();
    final firstLine = topLine.floor();
    final lastLine = min(topLine.ceil() + _visibleLineCount - 1, lineCount - 1);

    return SizedBox(
      height: lineHeight * _visibleLineCount,
      child: ClipRect(
        child: Stack(
          children: [
            for (var lineIndex = firstLine; lineIndex <= lastLine; lineIndex++)
              Positioned(
                key: ValueKey(lineIndex),
                left: 0,
                right: 0,
                top: (lineIndex - topLine) * lineHeight,
                height: lineHeight,
                child: Opacity(
                  opacity: _opacityAt(lineIndex - topLine),
                  child: TempoStaffLine(
                    noteGroups: _slice(noteGroups, lineIndex),
                    noteStates: _slice(noteStates, lineIndex),
                    clef: clef,
                    barFraction: lineIndex == barLine ? barFraction : null,
                    height: lineHeight,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Opacité selon la position de la ligne, en lignes depuis le haut : pleine
  /// sur les deux emplacements visibles, en fondu au-dessus et en dessous.
  double _opacityAt(double position) {
    if (position < 0) return (1 + position).clamp(0, 1);
    if (position > _visibleLineCount - 1) {
      return (_visibleLineCount - position).clamp(0, 1);
    }
    return 1;
  }

  List<T> _slice<T>(List<T> items, int lineIndex) {
    const notesPerLine = TempoTimeline.notesPerLine;
    final start = lineIndex * notesPerLine;
    return items.sublist(start, min(start + notesPerLine, items.length));
  }
}
