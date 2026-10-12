import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:key_starter/core/enums/note_language.dart';
import 'package:key_starter/core/providers/notation_language_provider.dart';
import 'package:key_starter/core/theme/app_color_theme.dart';
import 'package:key_starter/core/theme/app_colors.dart';
import 'package:key_starter/core/utils/note_utils.dart';
import 'package:key_starter/core/widgets/display_text.dart';
import 'package:key_starter/features/chord_chart/domain/entities/accidental.dart';
import 'package:key_starter/features/chord_chart/domain/entities/chord_quality.dart';
import 'package:key_starter/features/chord_chart/domain/entities/chord_symbol.dart';
import 'package:key_starter/features/chord_chart/domain/entities/note_letter.dart';
import 'package:key_starter/features/chord_chart/domain/entities/spelled_note.dart';
import 'package:key_starter/features/chord_chart/presentation/models/chord_chart_cell_status.dart';

/// Nom d'une note de grille avec son orthographe (`F♯`, `G♭`) ; [noteNames]
/// suit l'ordre de [NoteLetter], de Do à Si.
String _spelledNoteLabel(SpelledNote note, List<String> noteNames) {
  final accidental = switch (note.accidental) {
    Accidental.natural => '',
    Accidental.sharp => '♯',
    Accidental.flat => '♭',
  };
  return '${noteNames[note.letter.index]}$accidental';
}

/// Nom d'un accord de grille dans la notation choisie : `F♯m` ou `Fa♯m`.
String chordChartLabel(ChordSymbol chord, NoteLanguage language) {
  final noteNames = language == NoteLanguage.fr ? noteNamesFr : noteNamesEn;
  final root = _spelledNoteLabel(chord.root, noteNames);
  final suffix = switch (chord.quality) {
    ChordQuality.major => '',
    ChordQuality.minor => 'm',
    ChordQuality.dominantSeventh => '7',
    ChordQuality.minorSeventh => 'm7',
    ChordQuality.majorSeventh => 'maj7',
    ChordQuality.suspendedSecond => 'sus2',
    ChordQuality.suspendedFourth => 'sus4',
  };
  final inversion = chord.inversion;
  final inversionLabel = inversion == null ? '' : '($inversion)';
  final bass = chord.bass;
  final bassLabel = bass == null
      ? ''
      : '/${_spelledNoteLabel(bass, noteNames)}';
  return '$root$suffix$inversionLabel$bassLabel';
}

/// Une case de la grille : le nom de son accord, surligné quand c'est la case
/// à jouer, vert ou rouge une fois jouée.
class ChordChartCellView extends ConsumerWidget {
  final int cellIndex;
  final ChordSymbol chord;
  final ChordChartCellStatus status;

  const ChordChartCellView({
    super.key,
    required this.cellIndex,
    required this.chord,
    required this.status,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColorTheme.of(context);
    final language = ref.watch(notationLanguageProvider);
    final (background, border, text) = switch (status) {
      ChordChartCellStatus.pending => (
        colors.surface,
        colors.line,
        colors.text,
      ),
      ChordChartCellStatus.current => (
        AppColors.chordChartsTint,
        AppColors.chordChartsFg,
        colors.text,
      ),
      ChordChartCellStatus.correct => (
        colors.surface,
        AppColors.stateGreen,
        AppColors.stateGreen,
      ),
      ChordChartCellStatus.wrong => (
        colors.surface,
        AppColors.stateRed,
        AppColors.stateRed,
      ),
    };

    return Container(
      margin: const EdgeInsets.all(4),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: background,
        border: Border.all(color: border, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: DisplayText(
          chordChartLabel(chord, language),
          size: 32,
          color: text,
        ),
      ),
    );
  }
}
