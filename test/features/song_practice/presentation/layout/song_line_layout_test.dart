import 'package:flutter_test/flutter_test.dart';
import 'package:key_starter/core/models/two_staff_event.dart';
import 'package:key_starter/features/song_practice/domain/entities/song.dart';
import 'package:key_starter/features/song_practice/domain/entities/song_event.dart';
import 'package:key_starter/features/song_practice/domain/entities/note_value.dart';
import 'package:key_starter/features/song_practice/domain/entities/song_measure.dart';
import 'package:key_starter/features/song_practice/domain/entities/song_rest.dart';
import 'package:key_starter/features/song_practice/presentation/layout/song_line_layout.dart';

Song songWithMeasures(
  int measureCount, {
  List<SongEvent> events = const [],
  List<SongRest> rests = const [],
  int measureDuration = 8,
}) => Song(
  title: 'Essai',
  measures: [
    for (var index = 0; index < measureCount; index++)
      SongMeasure(
        number: index + 1,
        startDivisions: index * measureDuration,
        durationDivisions: measureDuration,
      ),
  ],
  events: events,
  rests: rests,
);

/// Une mesure de 32 divisions qui commence par quatre notes serrées (une
/// division d'écart), puis plus rien.
Song denseSong() => songWithMeasures(
  1,
  measureDuration: 32,
  events: [for (var onset = 0; onset < 4; onset++) trebleNoteAt(1, onset)],
);

SongEvent trebleNoteAt(int measureNumber, int onsetDivisions) => SongEvent(
  measureNumber: measureNumber,
  onsetDivisions: onsetDivisions,
  notes: const TwoStaffEvent(trebleSteps: [0], bassSteps: []),
);

void main() {
  group('layoutSongLines', () {
    test(
      'regroupe les mesures deux par deux, la dernière seule si impaire',
      () {
        //arrange
        final song = songWithMeasures(5);

        //act
        final sut = layoutSongLines(song, measuresPerLine: 2);

        //assert
        expect(sut.map((line) => line.firstMeasureNumber), [1, 3, 5]);
        expect(sut.map((line) => line.measureCount), [2, 2, 1]);
      },
    );

    test(
      'place chaque événement selon son temps, une mesure occupant une moitié de ligne',
      () {
        //arrange
        final song = songWithMeasures(
          3,
          events: [
            trebleNoteAt(1, 0),
            trebleNoteAt(2, 8),
            trebleNoteAt(2, 11),
            trebleNoteAt(2, 12),
            trebleNoteAt(3, 20),
          ],
        );

        //act
        final sut = layoutSongLines(song, measuresPerLine: 2);

        //assert
        expect(sut[0].events, const [
          PlacedSongEvent(eventIndex: 0, position: 0),
          PlacedSongEvent(eventIndex: 1, position: 0.5),
          PlacedSongEvent(eventIndex: 2, position: 0.6875),
          PlacedSongEvent(eventIndex: 3, position: 0.75),
        ]);
        expect(sut[1].events, const [
          PlacedSongEvent(eventIndex: 4, position: 0.25),
        ]);
      },
    );
  });

  group('layoutSongLines, espacement minimal', () {
    test(
      'écarte d\'au moins un douzième de mesure deux éléments trop proches',
      () {
        //arrange
        final song = denseSong();

        //act
        final sut = layoutSongLines(song, measuresPerLine: 1).single;

        //assert
        final positions = sut.events.map((placed) => placed.position).toList();
        expect(positions[0], 0);
        expect(positions[1], closeTo(1 / 12, 1e-9));
        expect(positions[2], closeTo(2 / 12, 1e-9));
        expect(positions[3], closeTo(3 / 12, 1e-9));
      },
    );

    test('répartit également les éléments d\'une mesure trop pleine', () {
      //arrange
      final song = songWithMeasures(
        1,
        measureDuration: 16,
        events: [
          for (var onset = 0; onset < 16; onset++) trebleNoteAt(1, onset),
        ],
      );

      //act
      final sut = layoutSongLines(song, measuresPerLine: 1).single;

      //assert
      for (var index = 0; index < 16; index++) {
        expect(sut.events[index].position, closeTo(index / 16, 1e-9));
      }
    });

    test(
      'place les silences selon leur temps, la mesure entière au milieu',
      () {
        //arrange
        final song = songWithMeasures(
          2,
          events: [trebleNoteAt(1, 0)],
          rests: const [
            SongRest(
              measureNumber: 1,
              onsetDivisions: 4,
              isBass: false,
              value: NoteValue(NoteType.half),
            ),
            SongRest(
              measureNumber: 2,
              onsetDivisions: 8,
              isBass: true,
              value: null,
            ),
          ],
        );

        //act
        final sut = layoutSongLines(song, measuresPerLine: 2).single;

        //assert
        expect(sut.rests, const [
          PlacedSongRest(restIndex: 0, position: 0.25),
          PlacedSongRest(restIndex: 1, position: 0.75),
        ]);
      },
    );
  });

  group('songLinePositionAt', () {
    for (final (divisions, lineIndex, fraction) in [
      (0.0, 0, 0.0),
      (4.0, 0, 0.25),
      (12.0, 0, 0.75),
      (16.0, 1, 0.0),
      (20.0, 1, 0.25),
      (32.0, 1, 1.0),
    ]) {
      test(
        'place le temps $divisions sur la ligne $lineIndex, à $fraction de sa largeur',
        () {
          //arrange
          final song = songWithMeasures(4);

          //act
          final sut = songLinePositionAt(song, divisions, measuresPerLine: 2);

          //assert
          expect(sut.lineIndex, lineIndex);
          expect(sut.fraction, closeTo(fraction, 1e-9));
        },
      );
    }
  });

  group('songLinePositionAt, espacement minimal', () {
    for (final (divisions, fraction) in [
      (2.0, 2 / 12),
      (2.5, 2.5 / 12),
      (17.5, 0.25 + (17.5 - 3) / 29 * 0.75),
    ]) {
      test('suit le placement des éléments au temps $divisions', () {
        //arrange
        final song = denseSong();

        //act
        final sut = songLinePositionAt(song, divisions, measuresPerLine: 1);

        //assert
        expect(sut.lineIndex, 0);
        expect(sut.fraction, closeTo(fraction, 1e-9));
      });
    }
  });
}
