import 'package:equatable/equatable.dart';

/// Figure de note ou de silence, de la carrée à la 1024e.
enum NoteType {
  breve(8),
  whole(4),
  half(2),
  quarter(1),
  eighth(1 / 2),
  sixteenth(1 / 4),
  thirtySecond(1 / 8),
  sixtyFourth(1 / 16),
  oneHundredTwentyEighth(1 / 32),
  twoHundredFiftySixth(1 / 64),
  fiveHundredTwelfth(1 / 128),
  oneThousandTwentyFourth(1 / 256);

  /// Durée sans point, en noires.
  final double quarters;

  const NoteType(this.quarters);

  /// Nombre de crochets ou de barres de ligature : 0 jusqu'à la noire, 1
  /// pour la croche… 8 pour la 1024e.
  int get flagCount =>
      index <= NoteType.quarter.index ? 0 : index - NoteType.quarter.index;

  /// Tête creuse (carrée, ronde, blanche) plutôt que pleine.
  bool get hasHollowHead => index <= NoteType.half.index;

  /// Une hampe à partir de la blanche.
  bool get hasStem => index >= NoteType.half.index;
}

/// Valeur écrite d'une note ou d'un silence : sa figure et ses points.
class NoteValue extends Equatable {
  final NoteType type;
  final int dotCount;

  const NoteValue(this.type, {this.dotCount = 0});

  @override
  List<Object?> get props => [type, dotCount];
}
