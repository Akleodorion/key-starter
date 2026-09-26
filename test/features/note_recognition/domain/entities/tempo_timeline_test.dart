import 'package:flutter_test/flutter_test.dart';
import 'package:key_starter/features/note_recognition/domain/entities/tempo_timeline.dart';

void main() {
  const sut = TempoTimeline(bpm: 60, noteCount: 10);

  Duration milliseconds(int value) => Duration(milliseconds: value);

  group('TempoTimeline', () {
    group('beatDuration', () {
      test('dure une seconde à 60 BPM', () {
        //arrange
        //act
        final beatDuration = sut.beatDuration;

        //assert
        expect(beatDuration, milliseconds(1000));
      });

      test('dure une demi-seconde à 120 BPM', () {
        //arrange
        const fastTimeline = TempoTimeline(bpm: 120, noteCount: 10);

        //act
        final beatDuration = fastTimeline.beatDuration;

        //assert
        expect(beatDuration, milliseconds(500));
      });
    });

    group('noteTime', () {
      test('place chaque note au milieu de son temps, après le décompte', () {
        //arrange
        //act
        final firstNoteTime = sut.noteTime(0);
        final fourthNoteTime = sut.noteTime(3);

        //assert
        expect(firstNoteTime, milliseconds(4500));
        expect(fourthNoteTime, milliseconds(7500));
      });
    });

    group('windowIndexAt', () {
      test('trouve la note dont la fenêtre de ±25 % contient l\'instant', () {
        //arrange
        //act
        final atWindowOpening = sut.windowIndexAt(milliseconds(4250));
        final atWindowClosing = sut.windowIndexAt(milliseconds(4750));
        final insideSecondWindow = sut.windowIndexAt(milliseconds(5250));

        //assert
        expect(atWindowOpening, 0);
        expect(atWindowClosing, 0);
        expect(insideSecondWindow, 1);
      });

      test(
        'ne trouve aucune note entre deux fenêtres ou pendant le décompte',
        () {
          //arrange
          //act
          final betweenWindows = sut.windowIndexAt(milliseconds(5000));
          final justBeforeWindow = sut.windowIndexAt(milliseconds(4200));
          final duringCountIn = sut.windowIndexAt(milliseconds(2000));

          //assert
          expect(betweenWindows, isNull);
          expect(justBeforeWindow, isNull);
          expect(duringCountIn, isNull);
        },
      );
    });

    group('windowClose', () {
      test('ferme la fenêtre un quart de temps après la note', () {
        //arrange
        //act
        final firstWindowClose = sut.windowClose(0);

        //assert
        expect(firstWindowClose, milliseconds(4750));
      });
    });

    group('isCountIn', () {
      test('dure 4 temps avant le départ de la barre', () {
        //arrange
        //act
        final atStart = sut.isCountIn(milliseconds(0));
        final justBeforePlay = sut.isCountIn(milliseconds(3999));
        final atPlayStart = sut.isCountIn(milliseconds(4000));

        //assert
        expect(atStart, isTrue);
        expect(justBeforePlay, isTrue);
        expect(atPlayStart, isFalse);
      });
    });

    group('countInBeatAt', () {
      test('compte 4, 3, 2, 1 puis s\'arrête au départ de la barre', () {
        //arrange
        //act
        final beats = [
          0,
          1500,
          2000,
          3999,
          4000,
        ].map((value) => sut.countInBeatAt(milliseconds(value))).toList();

        //assert
        expect(beats, [4, 3, 2, 1, null]);
      });
    });

    group('lineCount', () {
      test('range 4 notes par ligne, la dernière pouvant être incomplète', () {
        //arrange
        //act
        final lineCount = sut.lineCount;

        //assert
        expect(lineCount, 3);
      });
    });

    group('barLineAt / barFractionAt', () {
      test(
        'laisse la barre au début de la première ligne pendant le décompte',
        () {
          //arrange
          const duringCountIn = Duration(milliseconds: 1000);

          //act
          final line = sut.barLineAt(duringCountIn);
          final fraction = sut.barFractionAt(duringCountIn);

          //assert
          expect(line, 0);
          expect(fraction, 0);
        },
      );

      test('fait avancer la barre d\'un quart de ligne par temps', () {
        //arrange
        //act
        final halfWayLine = sut.barLineAt(milliseconds(6000));
        final halfWayFraction = sut.barFractionAt(milliseconds(6000));
        final secondLine = sut.barLineAt(milliseconds(8000));
        final secondLineFraction = sut.barFractionAt(milliseconds(8000));

        //assert
        expect(halfWayLine, 0);
        expect(halfWayFraction, 0.5);
        expect(secondLine, 1);
        expect(secondLineFraction, 0);
      });

      test(
        's\'arrête après la dernière note, même sur une ligne incomplète',
        () {
          //arrange
          const afterEnd = Duration(milliseconds: 20000);

          //act
          final line = sut.barLineAt(afterEnd);
          final fraction = sut.barFractionAt(afterEnd);

          //assert
          expect(line, 2);
          expect(fraction, 0.5);
        },
      );
    });

    group('barNoteIndexAt', () {
      test(
        'suit le temps que traverse la barre, sans dépasser la dernière note',
        () {
          //arrange
          //act
          final indexes = [
            0,
            4999,
            5000,
            20000,
          ].map((value) => sut.barNoteIndexAt(milliseconds(value))).toList();

          //assert
          expect(indexes, [0, 0, 1, 9]);
        },
      );
    });

    group('topLineAt', () {
      test('garde la ligne en cours en haut hors transition', () {
        //arrange
        //act
        final topLine = sut.topLineAt(milliseconds(5000));

        //assert
        expect(topLine, 0);
      });

      test(
        'fait remonter les lignes pendant le demi-temps sans fenêtre, entre deux lignes',
        () {
          //arrange
          //act
          final atTransitionStart = sut.topLineAt(milliseconds(7750));
          final midTransition = sut.topLineAt(milliseconds(8000));
          final atTransitionEnd = sut.topLineAt(milliseconds(8250));
          final afterTransition = sut.topLineAt(milliseconds(9000));

          //assert
          expect(atTransitionStart, 0);
          expect(midTransition, 0.5);
          expect(atTransitionEnd, 1);
          expect(afterTransition, 1);
        },
      );

      test('ne dépasse jamais la dernière ligne', () {
        //arrange
        //act
        final topLine = sut.topLineAt(milliseconds(20000));

        //assert
        expect(topLine, 2);
      });
    });
  });
}
