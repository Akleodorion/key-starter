import 'package:key_starter/features/song_practice/domain/entities/note_value.dart';

/// Glyphes SMuFL de la police Bravura pour écrire les figures d'un morceau.
/// Un glyphe se dessine avec une taille de police de 4 interlignes, sa
/// ligne de base posée sur la hauteur qu'il désigne.

/// Point d'augmentation.
const augmentationDotGlyph = '';

/// Tête de note : carrée, ronde, blanche, puis tête pleine.
String noteHeadGlyph(NoteType noteType) => switch (noteType) {
  NoteType.breve => '',
  NoteType.whole => '',
  NoteType.half => '',
  _ => '',
};

/// Crochet d'une note seule, de la croche à la 1024e ; null jusqu'à la
/// noire.
String? flagGlyph(NoteType noteType, {required bool stemUp}) {
  if (noteType.flagCount == 0) return null;
  final codePoint = 0xE240 + (noteType.flagCount - 1) * 2 + (stemUp ? 0 : 1);
  return String.fromCharCode(codePoint);
}

/// Silence, de la bâton de pause (carrée) au silence de 1024e.
String restGlyph(NoteType noteType) =>
    String.fromCharCode(0xE4E2 + noteType.index);

/// Ligne de la portée (1 en bas, 5 en haut) où se pose la ligne de base du
/// silence : la pause pend sous la 4e ligne, les autres partent du milieu.
int restBaselineLine(NoteType noteType) => noteType == NoteType.whole ? 4 : 3;
