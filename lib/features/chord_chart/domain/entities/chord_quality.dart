/// Qualité d'un accord de grille : les intervalles, en demi-tons depuis la
/// fondamentale, de ses notes, dans l'ordre de l'accord.
enum ChordQuality {
  major([0, 4, 7]),
  minor([0, 3, 7]),
  dominantSeventh([0, 4, 7, 10]),
  minorSeventh([0, 3, 7, 10]),
  majorSeventh([0, 4, 7, 11]),
  suspendedSecond([0, 2, 7]),
  suspendedFourth([0, 5, 7]);

  final List<int> semitonesFromRoot;

  const ChordQuality(this.semitonesFromRoot);
}
