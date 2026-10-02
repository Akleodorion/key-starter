import 'package:flutter_test/flutter_test.dart';
import 'package:key_starter/core/models/two_staff_event.dart';
import 'package:key_starter/core/utils/two_staff_judgement.dart';

void main() {
  const c4MidiNumber = 60;
  const c3MidiNumber = 48;

  group('judgeTwoStaffEvent', () {
    test('juge les deux portées justes quand chaque note est jouée', () {
      //arrange
      const event = TwoStaffEvent(trebleSteps: [0], bassSteps: [-7]);

      //act
      final sut = judgeTwoStaffEvent(event, {c3MidiNumber, c4MidiNumber});

      //assert
      expect(sut.treble.isCorrect, isTrue);
      expect(sut.bass.isCorrect, isTrue);
      expect(sut.isCorrect, isTrue);
    });

    test(
      'attribue une touche fausse au-dessus du point de partage à la clé de sol',
      () {
        //arrange
        const event = TwoStaffEvent(trebleSteps: [0], bassSteps: [-7]);
        const d4MidiNumber = 62;

        //act
        final sut = judgeTwoStaffEvent(event, {c3MidiNumber, d4MidiNumber});

        //assert
        expect(sut.treble.isCorrect, isFalse);
        expect(sut.treble.playedMidiNumbers, {d4MidiNumber});
        expect(sut.bass.isCorrect, isTrue);
        expect(sut.isCorrect, isFalse);
      },
    );

    test(
      'attribue une touche fausse sous le point de partage à la clé de fa',
      () {
        //arrange
        const event = TwoStaffEvent(trebleSteps: [0], bassSteps: [-7]);
        const b3MidiNumber = 59;
        const e3MidiNumber = 52;

        //act
        final sut = judgeTwoStaffEvent(event, {b3MidiNumber, e3MidiNumber});

        //assert
        expect(sut.treble.isCorrect, isFalse);
        expect(sut.treble.playedMidiNumbers, {b3MidiNumber});
        expect(sut.bass.isCorrect, isFalse);
        expect(sut.bass.playedMidiNumbers, {e3MidiNumber});
      },
    );

    test('juge fausse une portée dont l\'accord est incomplet', () {
      //arrange
      const event = TwoStaffEvent(trebleSteps: [0], bassSteps: [-7, -5, -3]);
      const e3MidiNumber = 52;

      //act
      final sut = judgeTwoStaffEvent(event, {
        c4MidiNumber,
        c3MidiNumber,
        e3MidiNumber,
      });

      //assert
      expect(sut.treble.isCorrect, isTrue);
      expect(sut.bass.isCorrect, isFalse);
      expect(sut.bass.playedMidiNumbers, {c3MidiNumber, e3MidiNumber});
    });

    test(
      'juge fausse la portée d\'une touche noire et la garde dans les touches jouées',
      () {
        //arrange
        const event = TwoStaffEvent(trebleSteps: [0], bassSteps: [-7]);
        const cSharp4MidiNumber = 61;

        //act
        final sut = judgeTwoStaffEvent(event, {
          c3MidiNumber,
          cSharp4MidiNumber,
        });

        //assert
        expect(sut.treble.isCorrect, isFalse);
        expect(sut.treble.playedMidiNumbers, {cSharp4MidiNumber});
        expect(sut.bass.isCorrect, isTrue);
      },
    );
  });
}
