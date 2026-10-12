/// Qualité d'un accord de grille : les intervalles, en demi-tons depuis la
/// fondamentale, de ses notes.
enum ChordQuality {
  major([0, 4, 7]),
  minor([0, 3, 7]);

  final List<int> semitonesFromRoot;

  const ChordQuality(this.semitonesFromRoot);
}
