import 'package:equatable/equatable.dart';
import 'package:key_starter/features/chord_chart/domain/entities/chord_quality.dart';
import 'package:key_starter/features/chord_chart/domain/entities/spelled_note.dart';

/// L'accord de grille d'une case : sa fondamentale orthographiée, sa qualité
/// et, au plus l'un des deux, son renversement imposé (`C(2)`) ou sa basse
/// imposée (`D/F#`).
class ChordSymbol extends Equatable {
  final SpelledNote root;
  final ChordQuality quality;

  /// Renversement imposé : 1 (deuxième note de l'accord à la basse) ou 2
  /// (troisième note), `null` s'il est libre.
  final int? inversion;

  /// Basse imposée (`/X`), `null` sinon.
  final SpelledNote? bass;

  const ChordSymbol({
    required this.root,
    required this.quality,
    this.inversion,
    this.bass,
  }) : assert(inversion == null || inversion == 1 || inversion == 2),
       assert(inversion == null || bass == null);

  /// Classe de note de la fondamentale (0 = Do … 11 = Si).
  int get rootPitchClass => root.pitchClass;

  /// Classes de notes de l'accord (0 = Do … 11 = Si).
  Set<int> get pitchClasses => {
    for (final semitones in quality.semitonesFromRoot)
      (rootPitchClass + semitones) % 12,
  };

  /// Classe de la note attendue à la basse : la basse imposée, sinon la
  /// fondamentale.
  int get bassPitchClass => (bass ?? root).pitchClass;

  /// Classe de la note de l'accord désignée par [inversion], `null` sans
  /// renversement imposé.
  int? get inversionPitchClass {
    final position = inversion;
    if (position == null) return null;
    return (rootPitchClass + quality.semitonesFromRoot[position]) % 12;
  }

  @override
  List<Object?> get props => [root, quality, inversion, bass];
}
