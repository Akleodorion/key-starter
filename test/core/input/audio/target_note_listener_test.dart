import 'package:flutter_test/flutter_test.dart';
import 'package:key_starter/core/input/audio/target_note_listener.dart';

import 'synthetic_piano.dart';

void main() {
  const c4 = 60;
  const d4 = 62;
  const c5 = 72;
  const a2 = 45;
  const e6 = 88;

  late SyntheticPiano piano;
  late TargetNoteListener sut;

  setUp(() {
    piano = SyntheticPiano();
    sut = TargetNoteListener();
  });

  group('TargetNoteListener', () {
    group('pushSamples', () {
      for (final target in [a2, c4, e6]) {
        test('valide la note cible jouée ($target)', () {
          //arrange
          sut.listenFor({target});

          //act
          final result = sut.pushSamples(piano.inRoom(piano.note([target])));

          //assert
          expect(result?.isCorrect, isTrue);
        });
      }

      test('rapporte la note entendue quand une autre note est jouée', () {
        //arrange
        sut.listenFor({c4});

        //act
        final result = sut.pushSamples(piano.inRoom(piano.note([d4])));

        //assert
        expect(result?.heardNote, d4);
      });

      test('ne valide pas la cible jouée à l\'octave du dessus', () {
        //arrange
        sut.listenFor({c4});

        //act
        final result = sut.pushSamples(piano.inRoom(piano.note([c5])));

        //assert
        expect(result?.isCorrect, isNot(isTrue));
      });

      test('ignore le bruit de pièce seul', () {
        //arrange
        sut.listenFor({c4});

        //act
        final result = sut.pushSamples(
          piano.roomNoise(3 * syntheticSampleRate),
        );

        //assert
        expect(result, isNull);
      });

      test('ignore une note jouée sous le seuil d\'écoute de -55 dB', () {
        //arrange
        sut.listenFor({c4});
        final quietNote = piano.note([c4], peak: 0.0008);

        //act
        final result = sut.pushSamples([
          ...List.filled(syntheticSampleRate, 0.0),
          ...quietNote,
          ...List.filled(syntheticSampleRate ~/ 2, 0.0),
        ]);

        //assert
        expect(result, isNull);
      });

      test(
        'valide une note jouée doucement (crête à -40 dB) dans une pièce calme',
        () {
          //arrange
          sut.listenFor({c4});
          final softNote = piano.note([c4], peak: 0.01);

          //act
          final result = sut.pushSamples([
            ...piano.roomNoise(syntheticSampleRate, level: 0.0001),
            ...softNote,
            ...piano.roomNoise(syntheticSampleRate ~/ 2, level: 0.0001),
          ]);

          //assert
          expect(result?.isCorrect, isTrue);
        },
      );

      test('ne revalide pas la résonance d\'une note déjà jugée', () {
        //arrange
        final played = piano.note([c4]);
        final signal = piano.inRoom(played);
        const firstHalf = syntheticSampleRate + syntheticSampleRate ~/ 2;
        sut.listenFor({c4});
        final firstResult = sut.pushSamples(signal.sublist(0, firstHalf));

        //act
        sut.listenFor({c4});
        final resonanceResult = sut.pushSamples(signal.sublist(firstHalf));

        //assert
        expect(firstResult?.isCorrect, isTrue);
        expect(resonanceResult, isNull);
      });

      test('date l\'attaque entre 180 et 700 ms avant le verdict', () {
        //arrange
        sut.listenFor({c4});

        //act
        final result = sut.pushSamples(piano.inRoom(piano.note([c4])));

        //assert
        expect(result?.sinceAttack.inMilliseconds, inInclusiveRange(180, 700));
      });

      test('valide n\'importe quelle octave parmi plusieurs candidats', () {
        //arrange
        const c3 = 48;
        sut.listenFor({36, c3, c4, c5, 84});

        //act
        final result = sut.pushSamples(piano.inRoom(piano.note([c3])));

        //assert
        expect(
          result,
          NoteAttemptResult(
            heardNote: c3,
            isCorrect: true,
            sinceAttack: result!.sinceAttack,
          ),
        );
      });

      test('rapporte une autre note jouée parmi plusieurs candidats', () {
        //arrange
        sut.listenFor({36, 48, c4, c5, 84});

        //act
        final result = sut.pushSamples(piano.inRoom(piano.note([d4])));

        //assert
        expect(result?.isCorrect, isFalse);
        expect(result?.heardNote, d4);
      });

      test('n\'écoute plus après pause', () {
        //arrange
        sut.listenFor({c4});
        sut.pause();

        //act
        final result = sut.pushSamples(piano.inRoom(piano.note([c4])));

        //assert
        expect(result, isNull);
      });
    });
  });
}
