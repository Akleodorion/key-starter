import 'package:equatable/equatable.dart';
import 'package:key_starter/features/song_practice/domain/entities/note_value.dart';

enum StemDirection { up, down }

/// Rôle d'une note dans une barre de ligature, pour un niveau de barre.
enum BeamMark { begin, continued, end, forwardHook, backwardHook }

/// Comment s'écrit le groupe de notes d'une portée à un instant : sa
/// valeur, le sens de sa hampe donné par la partition (null s'il n'est pas
/// écrit) et sa place dans chaque niveau de barre de ligature (le premier
/// élément pour la barre des croches, le deuxième pour celle des doubles…).
class StaffNotation extends Equatable {
  final NoteValue value;
  final StemDirection? stemDirection;
  final List<BeamMark> beams;

  const StaffNotation({
    required this.value,
    this.stemDirection,
    this.beams = const [],
  });

  @override
  List<Object?> get props => [value, stemDirection, beams];
}
