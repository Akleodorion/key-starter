import 'package:equatable/equatable.dart';
import 'package:key_starter/features/song_practice/domain/entities/note_value.dart';

/// Un silence tel qu'il est dessiné sur une ligne de partition : sa
/// position (0 à 1), sa portée et sa valeur (null pour une mesure entière).
class ScoreLineRest extends Equatable {
  final double position;
  final bool isBass;
  final NoteValue? value;

  const ScoreLineRest({
    required this.position,
    required this.isBass,
    required this.value,
  });

  @override
  List<Object?> get props => [position, isBass, value];
}
