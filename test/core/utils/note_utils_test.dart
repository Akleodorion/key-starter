import 'package:flutter_test/flutter_test.dart';
import 'package:key_starter/core/enums/note_language.dart';
import 'package:key_starter/core/utils/note_utils.dart';

void main() {
  group('pitchClassLabel', () {
    test('nomme les touches noires en dièses, en français', () {
      //arrange
      const blackKeyMidiNumbers = [61, 63, 66, 68, 70];

      //act
      final labels = blackKeyMidiNumbers
          .map((midiNumber) => pitchClassLabel(midiNumber, NoteLanguage.fr))
          .toList();

      //assert
      expect(labels, ['Do♯', 'Ré♯', 'Fa♯', 'Sol♯', 'La♯']);
    });

    test('nomme les touches noires en dièses, en anglais', () {
      //arrange
      const blackKeyMidiNumbers = [61, 63, 66, 68, 70];

      //act
      final labels = blackKeyMidiNumbers
          .map((midiNumber) => pitchClassLabel(midiNumber, NoteLanguage.en))
          .toList();

      //assert
      expect(labels, ['C♯', 'D♯', 'F♯', 'G♯', 'A♯']);
    });

    test('nomme une touche blanche sans altération ni octave', () {
      //arrange
      const g2MidiNumber = 43;

      //act
      final label = pitchClassLabel(g2MidiNumber, NoteLanguage.fr);

      //assert
      expect(label, 'Sol');
    });
  });
}
