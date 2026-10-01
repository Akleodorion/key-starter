import 'package:equatable/equatable.dart';
import 'package:key_starter/core/utils/note_utils.dart';
import 'package:key_starter/features/chord_recognition/domain/entities/chord_inversion.dart';

/// Consigne d'accord : une triade diatonique de Do majeur, désignée par sa
/// fondamentale, à jouer dans une position donnée.
class ChordPrompt extends Equatable {
  static const _chordDegreeOffsets = [0, 2, 4];

  final int rootIndex;
  final ChordInversion inversion;

  const ChordPrompt({required this.rootIndex, required this.inversion});

  /// Les trois notes en position serrée, de la basse vers l'aigu, la
  /// fondamentale prise dans l'octave de Do 4.
  List<int> get midiNumbers {
    final bassOffset = inversion.bassDegreeOffset;
    final steps = [
      for (final degreeOffset in _chordDegreeOffsets)
        rootIndex +
            (degreeOffset < bassOffset ? degreeOffset + 7 : degreeOffset),
    ]..sort();
    return steps.map(midiFromDiatonicStep).toList();
  }

  /// Vrai si les touches jouées, de la plus grave à la plus aiguë, forment
  /// exactement cet accord dans cette position, à n'importe quelle octave.
  bool isPlayedBy(List<int> sortedMidiNumbers) {
    final expectedMidiNumbers = midiNumbers;
    if (sortedMidiNumbers.length != expectedMidiNumbers.length) return false;
    final octaveShift = sortedMidiNumbers.first - expectedMidiNumbers.first;
    if (octaveShift % 12 != 0) return false;
    for (var position = 0; position < sortedMidiNumbers.length; position++) {
      if (sortedMidiNumbers[position] !=
          expectedMidiNumbers[position] + octaveShift) {
        return false;
      }
    }
    return true;
  }

  @override
  List<Object?> get props => [rootIndex, inversion];
}
