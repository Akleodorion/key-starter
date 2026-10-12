import 'package:equatable/equatable.dart';
import 'package:key_starter/features/chord_chart/domain/entities/chord_quality.dart';

/// L'accord de grille d'une case : sa fondamentale (classe de note, 0 = Do)
/// et sa qualité.
class ChordSymbol extends Equatable {
  final int rootPitchClass;
  final ChordQuality quality;

  const ChordSymbol({required this.rootPitchClass, required this.quality});

  /// Classes de notes de l'accord (0 = Do … 11 = Si).
  Set<int> get pitchClasses => {
    for (final semitones in quality.semitonesFromRoot)
      (rootPitchClass + semitones) % 12,
  };

  /// Classe de la note attendue à la basse.
  int get bassPitchClass => rootPitchClass;

  @override
  List<Object?> get props => [rootPitchClass, quality];
}
