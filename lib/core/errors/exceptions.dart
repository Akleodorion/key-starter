class SharedPreferencesException implements Exception {
  const SharedPreferencesException();
}

/// Une partition contient un élément que le lecteur ne sait pas encore jouer
/// juste ; [reason] est affichable à l'utilisateur.
class UnsupportedSongException implements Exception {
  final String reason;

  const UnsupportedSongException(this.reason);
}

/// Le fichier d'un morceau est introuvable ou n'est pas un MusicXML lisible.
class SongFileException implements Exception {
  const SongFileException();
}

/// Une grille contient un élément que le lecteur ne sait pas encore lire ;
/// [reason] est affichable à l'utilisateur.
class UnsupportedChordChartException implements Exception {
  final String reason;

  const UnsupportedChordChartException(this.reason);
}

/// Le fichier d'une grille est introuvable ou illisible.
class ChordChartFileException implements Exception {
  const ChordChartFileException();
}
