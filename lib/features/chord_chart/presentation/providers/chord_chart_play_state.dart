import 'package:equatable/equatable.dart';
import 'package:key_starter/core/enums/note_state.dart';

sealed class ChordChartPlayState extends Equatable {
  const ChordChartPlayState();
}

class ChordChartPlayRunning extends ChordChartPlayState {
  /// Indice de la case en cours parmi toutes les cases de la grille.
  final int currentCellIndex;
  final NoteState cellState;
  final int errorCount;

  /// Résultat de chaque case déjà jouée (juste ou non), par indice de case.
  final Map<int, bool> cellResults;

  const ChordChartPlayRunning({
    required this.currentCellIndex,
    required this.cellState,
    required this.errorCount,
    this.cellResults = const {},
  });

  ChordChartPlayRunning copyWith({
    int? currentCellIndex,
    NoteState? cellState,
    int? errorCount,
    Map<int, bool>? cellResults,
  }) => ChordChartPlayRunning(
    currentCellIndex: currentCellIndex ?? this.currentCellIndex,
    cellState: cellState ?? this.cellState,
    errorCount: errorCount ?? this.errorCount,
    cellResults: cellResults ?? this.cellResults,
  );

  @override
  List<Object?> get props => [
    currentCellIndex,
    cellState,
    errorCount,
    cellResults,
  ];
}

/// La grille vient de se terminer, avec ou sans erreur : elle va reprendre
/// du début.
class ChordChartPlayRetrying extends ChordChartPlayState {
  final int errorCount;

  const ChordChartPlayRetrying({required this.errorCount});

  @override
  List<Object?> get props => [errorCount];
}
