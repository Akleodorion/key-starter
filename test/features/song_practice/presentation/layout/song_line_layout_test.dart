import 'package:flutter_test/flutter_test.dart';
import 'package:key_starter/core/models/two_staff_event.dart';
import 'package:key_starter/features/song_practice/domain/entities/song.dart';
import 'package:key_starter/features/song_practice/domain/entities/song_event.dart';
import 'package:key_starter/features/song_practice/domain/entities/song_measure.dart';
import 'package:key_starter/features/song_practice/presentation/layout/song_line_layout.dart';

Song songWithMeasures(int measureCount, {List<SongEvent> events = const []}) =>
    Song(
      title: 'Essai',
      measures: [
        for (var index = 0; index < measureCount; index++)
          SongMeasure(
            number: index + 1,
            startDivisions: index * 8,
            durationDivisions: 8,
          ),
      ],
      events: events,
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
}
