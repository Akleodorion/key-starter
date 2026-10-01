import 'package:key_starter/features/chord_recognition/domain/entities/chord_inversion.dart';

/// Renversements tirés dans l'exercice Renversements simples.
enum ChordInversionChoice {
  first({ChordInversion.first}),
  second({ChordInversion.second}),
  both({ChordInversion.first, ChordInversion.second});

  final Set<ChordInversion> inversions;

  const ChordInversionChoice(this.inversions);
}
