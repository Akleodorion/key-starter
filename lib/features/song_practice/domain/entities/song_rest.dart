import 'package:equatable/equatable.dart';
import 'package:key_starter/features/song_practice/domain/entities/note_value.dart';

/// Un silence d'une portée, à [onsetDivisions] dans la mesure
/// [measureNumber]. Un silence de mesure entière n'a pas de valeur écrite :
/// il se dessine comme une pause centrée dans la mesure.
class SongRest extends Equatable {
  final int measureNumber;
  final int onsetDivisions;
  final bool isBass;
  final NoteValue? value;

  const SongRest({
    required this.measureNumber,
    required this.onsetDivisions,
    required this.isBass,
    required this.value,
  });

  bool get isWholeMeasure => value == null;

  @override
  List<Object?> get props => [measureNumber, onsetDivisions, isBass, value];
}
