import 'package:flutter_test/flutter_test.dart';
import 'package:key_starter/core/models/two_staff_event.dart';
import 'package:key_starter/features/song_practice/domain/entities/song.dart';
import 'package:key_starter/features/song_practice/domain/entities/song_event.dart';
import 'package:key_starter/features/song_practice/domain/entities/song_measure.dart';
import 'package:key_starter/features/song_practice/domain/entities/song_section.dart';
import 'package:key_starter/features/song_practice/presentation/timing/song_tempo_timeline.dart';

SongEvent trebleNoteAt(int measureNumber, int onsetDivisions) => SongEvent(
  measureNumber: measureNumber,
  onsetDivisions: onsetDivisions,
  notes: const TwoStaffEvent(trebleSteps: [0], bassSteps: []),
);

/// Deux mesures de 4/4, 4 divisions par noire : noires, puis une double
/// croche (temps 8 et 9), puis la mesure 2.
Song songWith({int beatsPerMeasure = 4, int beatUnit = 4}) => Song(
  title: 'Essai',
  divisionsPerQuarter: 4,
  beatsPerMeasure: beatsPerMeasure,
  beatUnit: beatUnit,
  measures: const [
    SongMeasure(number: 1, startDivisions: 0, durationDivisions: 16),
    SongMeasure(number: 2, startDivisions: 16, durationDivisions: 16),
  ],
  events: [
    trebleNoteAt(1, 0),
    trebleNoteAt(1, 4),
    trebleNoteAt(1, 8),
    trebleNoteAt(1, 9),
    trebleNoteAt(1, 12),
    trebleNoteAt(2, 16),
  ],
);

const wholeSong = SongSection(firstMeasureNumber: 1, lastMeasureNumber: 2);

Duration ms(int milliseconds) => Duration(milliseconds: milliseconds);

void main() {
  group('SongTempoTimeline', () {
    SongTempoTimeline timelineFor({
      Song? song,
      SongSection section = wholeSong,
      List<int> judgedEventIndices = const [0, 1, 2, 3, 4, 5],
      int bpm = 60,
    }) => SongTempoTimeline(
      song: song ?? songWith(),
      section: section,
      judgedEventIndices: judgedEventIndices,
      bpm: bpm,
    );

    group('décompte', () {
      test('dure une mesure et compte ses temps à rebours', () {
        //arrange
        final sut = timelineFor();

        //act
        //assert
        expect(sut.countInDuration, ms(4000));
        expect(sut.countInBeatAt(Duration.zero), 4);
        expect(sut.countInBeatAt(ms(3999)), 1);
        expect(sut.countInBeatAt(ms(4000)), isNull);
        expect(sut.isCountIn(ms(3999)), isTrue);
        expect(sut.isCountIn(ms(4000)), isFalse);
      });

      test('suit le chiffrage : trois temps en 3/4', () {
        //arrange
        final sut = timelineFor(song: songWith(beatsPerMeasure: 3));

        //act
        //assert
        expect(sut.countInDuration, ms(3000));
        expect(sut.countInBeatAt(Duration.zero), 3);
      });

      test('compte des croches en 6/8, le tempo restant en noires', () {
        //arrange
        final sut = timelineFor(
          song: songWith(beatsPerMeasure: 6, beatUnit: 8),
        );

        //act
        //assert
        expect(sut.countInDuration, ms(3000));
        expect(sut.countInBeatAt(Duration.zero), 6);
        expect(sut.countInBeatAt(ms(2999)), 1);
      });
    });

    group('eventTime', () {
      test(
        'place chaque événement jugé après le décompte, selon son temps',
        () {
          //arrange
          final sut = timelineFor();

          //act
          //assert
          expect(sut.eventCount, 6);
          expect(sut.eventTime(0), ms(4000));
          expect(sut.eventTime(1), ms(5000));
          expect(sut.eventTime(3), ms(6250));
          expect(sut.eventTime(5), ms(8000));
        },
      );

      test('suit le tempo', () {
        //arrange
        final sut = timelineFor(bpm: 120);

        //act
        //assert
        expect(sut.eventTime(1), ms(2000 + 500));
      });

      test('part de la première mesure de la section', () {
        //arrange
        final sut = timelineFor(
          section: const SongSection(
            firstMeasureNumber: 2,
            lastMeasureNumber: 2,
          ),
          judgedEventIndices: const [5],
        );

        //act
        //assert
        expect(sut.eventIndexAt(0), 5);
        expect(sut.eventTime(0), ms(4000));
      });
    });

    group('fenêtres', () {
      test('ouvre ±¼ de temps autour d\'un événement isolé', () {
        //arrange
        final sut = timelineFor();

        //act
        //assert
        expect(sut.windowOpen(1), ms(4750));
        expect(sut.windowClose(1), ms(5250));
      });

      test(
        'réduit chaque côté à la moitié de l\'écart avec l\'événement voisin',
        () {
          //arrange
          final sut = timelineFor();

          //act
          //assert
          expect(sut.windowOpen(2), ms(5750));
          expect(sut.windowClose(2), ms(6125));
          expect(sut.windowOpen(3), ms(6125));
          expect(sut.windowClose(3), ms(6500));
        },
      );

      test('ne tient compte que des événements jugés', () {
        //arrange
        final sut = timelineFor(judgedEventIndices: const [0, 1, 2, 4, 5]);

        //act
        //assert
        expect(sut.windowClose(2), ms(6250));
      });

      test('trouve l\'événement dont la fenêtre contient un instant', () {
        //arrange
        final sut = timelineFor();

        //act
        //assert
        expect(sut.windowPositionAt(ms(3700)), isNull);
        expect(sut.windowPositionAt(ms(3750)), 0);
        expect(sut.windowPositionAt(ms(4400)), isNull);
        expect(sut.windowPositionAt(ms(6100)), 2);
        expect(sut.windowPositionAt(ms(6200)), 3);
      });
    });

    group('barre', () {
      test('attend au début de la section pendant le décompte', () {
        //arrange
        final sut = timelineFor(
          section: const SongSection(
            firstMeasureNumber: 2,
            lastMeasureNumber: 2,
          ),
          judgedEventIndices: const [5],
        );

        //act
        //assert
        expect(sut.barDivisionsAt(ms(1000)), 16);
      });

      test('avance au tempo et s\'arrête au bout de la section', () {
        //arrange
        final sut = timelineFor();

        //act
        //assert
        expect(sut.barDivisionsAt(ms(4500)), closeTo(2, 1e-9));
        expect(sut.barDivisionsAt(ms(20000)), 32);
      });

      test('termine la section au bout de sa dernière mesure', () {
        //arrange
        final sut = timelineFor(
          section: const SongSection(
            firstMeasureNumber: 1,
            lastMeasureNumber: 1,
          ),
          judgedEventIndices: const [0, 1, 2, 3, 4],
        );

        //act
        //assert
        expect(sut.endTime, ms(8000));
      });
    });
  });
}
