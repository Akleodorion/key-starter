/// Position d'un accord : quelle note de la triade est à la basse.
enum ChordInversion {
  rootPosition(bassDegreeOffset: 0),
  first(bassDegreeOffset: 2),
  second(bassDegreeOffset: 4);

  /// Écart diatonique entre la fondamentale et la note de basse
  /// (0 = fondamentale, 2 = tierce, 4 = quinte).
  final int bassDegreeOffset;

  const ChordInversion({required this.bassDegreeOffset});
}
