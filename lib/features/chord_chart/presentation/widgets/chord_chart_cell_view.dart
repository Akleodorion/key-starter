import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:key_starter/core/enums/note_language.dart';
import 'package:key_starter/core/providers/notation_language_provider.dart';
import 'package:key_starter/core/theme/app_color_theme.dart';
import 'package:key_starter/core/theme/app_colors.dart';
import 'package:key_starter/core/utils/note_utils.dart';
import 'package:key_starter/core/widgets/display_text.dart';
import 'package:key_starter/features/chord_chart/domain/entities/chord_quality.dart';
import 'package:key_starter/features/chord_chart/domain/entities/chord_symbol.dart';
import 'package:key_starter/features/chord_chart/presentation/models/chord_chart_cell_status.dart';

/// Indice, dans les noms de notes, de chaque classe de note naturelle.
const _naturalNoteIndexes = {0: 0, 2: 1, 4: 2, 5: 3, 7: 4, 9: 5, 11: 6};

/// Nom d'un accord de grille dans la notation choisie : `Am` ou `Lam`.
String chordChartLabel(ChordSymbol chord, NoteLanguage language) {
  final noteNames = language == NoteLanguage.fr ? noteNamesFr : noteNamesEn;
  final root = noteNames[_naturalNoteIndexes[chord.rootPitchClass]!];
  final suffix = chord.quality == ChordQuality.minor ? 'm' : '';
  return '$root$suffix';
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
