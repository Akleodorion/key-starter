import 'dart:math';

import 'package:flutter/material.dart';
import 'package:key_starter/core/enums/note_state.dart';
import 'package:key_starter/core/utils/two_staff_judgement.dart';
import 'package:key_starter/features/song_practice/domain/entities/song.dart';
import 'package:key_starter/features/song_practice/domain/entities/song_section.dart';
import 'package:key_starter/features/song_practice/presentation/layout/song_line_layout.dart';
import 'package:key_starter/features/song_practice/presentation/widgets/song_score_line.dart';

/// Nombre de mesures par ligne de partition.
const songMeasuresPerLine = 2;

const _visibleLineCount = 2;
const _scrollDuration = Duration(milliseconds: 300);

/// La partition d'un morceau, deux lignes visibles : celle de l'événement en
/// cours en haut, la suivante en dessous. Quand le repère passe à la ligne
/// suivante, les lignes remontent : celle du haut s'efface et la nouvelle
/// apparaît en bas.
class SongScoreLines extends StatelessWidget {
  final Song song;
  final Map<int, TwoStaffVerdict> judgedVerdicts;
  final int currentEventIndex;
  final NoteState feedbackState;
  final bool trebleMuted;
  final bool bassMuted;
  final SongSection section;
  final double lineHeight;

  const SongScoreLines({
    super.key,
    required this.song,
    required this.judgedVerdicts,
    required this.currentEventIndex,
    required this.feedbackState,
    required this.trebleMuted,
    required this.bassMuted,
    required this.section,
    required this.lineHeight,
  });

  @override
  Widget build(BuildContext context) {
    final lines = layoutSongLines(song, measuresPerLine: songMeasuresPerLine);
    final currentLineIndex = max(
      0,
      lines.indexWhere(
        (line) => line.events.any(
          (placedEvent) => placedEvent.eventIndex == currentEventIndex,
        ),
      ),
    );

    return SizedBox(
      height: lineHeight * _visibleLineCount,
      child: ClipRect(
        child: TweenAnimationBuilder<double>(
          tween: Tween(end: currentLineIndex.toDouble()),
          duration: _scrollDuration,
          curve: Curves.easeInOut,
          builder: (context, topLine, _) {
            final firstLine = topLine.floor();
            final lastLine = min(
              topLine.ceil() + _visibleLineCount - 1,
              lines.length - 1,
            );
            return Stack(
              children: [
                for (
                  var lineIndex = firstLine;
                  lineIndex <= lastLine;
                  lineIndex++
                )
                  Positioned(
                    key: ValueKey(lineIndex),
                    left: 0,
                    right: 0,
                    top: (lineIndex - topLine) * lineHeight,
                    height: lineHeight,
                    child: Opacity(
                      opacity: _opacityAt(lineIndex - topLine),
                      child: SongScoreLine(
                        line: lines[lineIndex],
                        song: song,
                        measuresPerLine: songMeasuresPerLine,
                        judgedVerdicts: judgedVerdicts,
                        currentEventIndex: lineIndex == currentLineIndex
                            ? currentEventIndex
                            : null,
                        feedbackState: feedbackState,
                        trebleMuted: trebleMuted,
                        bassMuted: bassMuted,
                        section: section,
                        height: lineHeight,
                      ),
                    ),
                  ),
              ],
            );
          },
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
}
