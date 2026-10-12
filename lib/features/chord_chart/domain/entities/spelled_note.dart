import 'package:equatable/equatable.dart';
import 'package:key_starter/features/chord_chart/domain/entities/accidental.dart';
import 'package:key_starter/features/chord_chart/domain/entities/note_letter.dart';

/// Note telle qu'écrite dans la grille : sa lettre et son altération
/// (F♯ et G♭ restent distincts).
class SpelledNote extends Equatable {
  final NoteLetter letter;
  final Accidental accidental;

  const SpelledNote(this.letter, [this.accidental = Accidental.natural]);

  /// Classe de note (0 = Do … 11 = Si).
  int get pitchClass =>
      (letter.naturalPitchClass + accidental.semitoneOffset) % 12;

  @override
  List<Object?> get props => [letter, accidental];
}
