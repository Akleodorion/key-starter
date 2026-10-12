import 'package:flutter_test/flutter_test.dart';
import 'package:key_starter/features/chord_chart/domain/entities/accidental.dart';
import 'package:key_starter/features/chord_chart/domain/entities/note_letter.dart';
import 'package:key_starter/features/chord_chart/domain/entities/spelled_note.dart';

void main() {
  group('SpelledNote', () {
    group('pitchClass', () {
      test('passe de Do à Si pour Do bémol', () {
        //arrange
        const sut = SpelledNote(NoteLetter.c, Accidental.flat);

        //act
        final pitchClass = sut.pitchClass;

        //assert
        expect(pitchClass, 11);
      });

      test('passe de Si à Do pour Si dièse', () {
        //arrange
        const sut = SpelledNote(NoteLetter.b, Accidental.sharp);

        //act
        final pitchClass = sut.pitchClass;

        //assert
        expect(pitchClass, 0);
      });
    });
  });
}
