import 'package:flutter_test/flutter_test.dart';
import 'package:key_starter/features/chord_recognition/domain/entities/chord_inversion.dart';
import 'package:key_starter/features/chord_recognition/domain/entities/chord_prompt.dart';

void main() {
  group('ChordPrompt', () {
    group('midiNumbers', () {
      test('empile Do Mi Sol à l\'état fondamental', () {
        //arrange
        const sut = ChordPrompt(
          rootIndex: 0,
          inversion: ChordInversion.rootPosition,
        );

        //act
        final midiNumbers = sut.midiNumbers;

        //assert
        expect(midiNumbers, [60, 64, 67]);
      });

      test('met la tierce à la basse au 1er renversement : Mi Sol Do', () {
        //arrange
        const sut = ChordPrompt(rootIndex: 0, inversion: ChordInversion.first);

        //act
        final midiNumbers = sut.midiNumbers;

        //assert
        expect(midiNumbers, [64, 67, 72]);
      });

      test('met la quinte à la basse au 2e renversement : Sol Do Mi', () {
        //arrange
        const sut = ChordPrompt(rootIndex: 0, inversion: ChordInversion.second);

        //act
        final midiNumbers = sut.midiNumbers;

        //assert
        expect(midiNumbers, [67, 72, 76]);
      });

      test('passe l\'octave pour Si au 2e renversement : Fa Si Ré', () {
        //arrange
        const sut = ChordPrompt(rootIndex: 6, inversion: ChordInversion.second);

        //act
        final midiNumbers = sut.midiNumbers;

        //assert
        expect(midiNumbers, [77, 83, 86]);
      });
    });

    group('isPlayedBy', () {
      const sut = ChordPrompt(rootIndex: 1, inversion: ChordInversion.first);

      test('accepte Fa La Ré, dans n\'importe quelle octave', () {
        //act
        final results = [
          sut.isPlayedBy([65, 69, 74]),
          sut.isPlayedBy([41, 45, 50]),
        ];

        //assert
        expect(results, [true, true]);
      });

      test('refuse l\'état fondamental du même accord', () {
        //act
        final result = sut.isPlayedBy([62, 65, 69]);

        //assert
        expect(result, isFalse);
      });

      test('refuse l\'autre renversement du même accord', () {
        //act
        final result = sut.isPlayedBy([69, 74, 77]);

        //assert
        expect(result, isFalse);
      });

      test('refuse le renversement étalé sur plusieurs octaves', () {
        //act
        final result = sut.isPlayedBy([65, 74, 81]);

        //assert
        expect(result, isFalse);
      });

      test('refuse une note doublée', () {
        //act
        final result = sut.isPlayedBy([65, 69, 74, 77]);

        //assert
        expect(result, isFalse);
      });

      test('refuse un accord incomplet ou aucune touche', () {
        //act
        final results = [
          sut.isPlayedBy([65, 69]),
          sut.isPlayedBy([]),
        ];

        //assert
        expect(results, [false, false]);
      });
    });
  });
}
