import 'package:equatable/equatable.dart';
import 'package:key_starter/features/chord_recognition/domain/entities/chord_inversion.dart';

/// Paramètres figés d'une série sans partition (Accords simples ou
/// Renversements simples), choisis avant le lancement.
class SimpleChordExerciseConfig extends Equatable {
  final int chordCount;

  /// Positions tirées au hasard : l'état fondamental seul pour Accords
  /// simples, un ou deux renversements pour Renversements simples.
  final Set<ChordInversion> inversions;

  const SimpleChordExerciseConfig({
    required this.chordCount,
    required this.inversions,
  });

  bool get isInversionPractice =>
      !inversions.contains(ChordInversion.rootPosition);

  @override
  List<Object?> get props => [chordCount, inversions];
}
