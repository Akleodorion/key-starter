import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:key_starter/core/enums/note_state.dart';
import 'package:key_starter/core/models/two_staff_event.dart';
import 'package:key_starter/core/theme/app_theme.dart';
import 'package:key_starter/core/utils/two_staff_judgement.dart';
import 'package:key_starter/features/song_practice/domain/entities/song.dart';
import 'package:key_starter/features/song_practice/domain/entities/song_event.dart';
import 'package:key_starter/features/song_practice/domain/entities/note_value.dart';
import 'package:key_starter/features/song_practice/domain/entities/song_measure.dart';
import 'package:key_starter/features/song_practice/domain/entities/song_rest.dart';
import 'package:key_starter/features/song_practice/domain/entities/staff_notation.dart';
import 'package:key_starter/features/song_practice/domain/entities/song_section.dart';
import 'package:key_starter/features/song_practice/presentation/layout/score_line_note.dart';
import 'package:key_starter/features/song_practice/presentation/layout/score_line_rest.dart';
import 'package:key_starter/features/song_practice/presentation/layout/song_line_layout.dart';
import 'package:key_starter/features/song_practice/presentation/widgets/song_score_line.dart';

const song = Song(
  title: 'Essai',
  measures: [
    SongMeasure(number: 1, startDivisions: 0, durationDivisions: 8),
    SongMeasure(number: 2, startDivisions: 8, durationDivisions: 8),
  ],
  events: [
    SongEvent(
      measureNumber: 1,
      onsetDivisions: 0,
      notes: TwoStaffEvent(trebleSteps: [2], bassSteps: [-7, -3]),
    ),
    SongEvent(
      measureNumber: 1,
      onsetDivisions: 2,
      notes: TwoStaffEvent(trebleSteps: [1], bassSteps: []),
    ),
    SongEvent(
      measureNumber: 2,
      onsetDivisions: 8,
      notes: TwoStaffEvent(trebleSteps: [], bassSteps: [-3]),
    ),
  ],
);

const correctTrebleWrongBass = TwoStaffVerdict(
  treble: StaffPartVerdict(isCorrect: true, playedMidiNumbers: {64}),
  bass: StaffPartVerdict(isCorrect: false, playedMidiNumbers: {48}),
);

const wholeSong = SongSection(firstMeasureNumber: 1, lastMeasureNumber: 2);

void main() {
  group('SongScoreLine', () {
    testWidgets(
      'dessine chaque événement à sa place avec l\'état de chaque portée, et le repère sur l\'événement en cours',
      (tester) async {
        //arrange
        final line = layoutSongLines(song, measuresPerLine: 2).single;

        //act
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light(),
            home: Scaffold(
              body: SongScoreLine(
                line: line,
                song: song,
                measuresPerLine: 2,
                judgedVerdicts: const {0: correctTrebleWrongBass},
                currentEventIndex: 1,
                feedbackState: NoteState.idle,
                trebleMuted: false,
                bassMuted: false,
                section: wholeSong,
                height: 150,
              ),
            ),
          ),
        );

        //assert
        final sut = tester
            .widgetList<CustomPaint>(find.byType(CustomPaint))
            .map((customPaint) => customPaint.painter)
            .whereType<SongScoreLinePainter>()
            .single;
        expect(sut.notes, const [
          ScoreLineNote(
            position: 0,
            trebleSteps: [2],
            bassSteps: [-7, -3],
            trebleState: NoteState.correct,
            bassState: NoteState.wrong,
          ),
          ScoreLineNote(
            position: 0.125,
            trebleSteps: [1],
            bassSteps: [],
            trebleState: NoteState.idle,
            bassState: NoteState.idle,
          ),
          ScoreLineNote(
            position: 0.5,
            trebleSteps: [],
            bassSteps: [-3],
            trebleState: NoteState.idle,
            bassState: NoteState.idle,
          ),
        ]);
        expect(sut.cursorPosition, 0.125);
        expect(sut.firstMeasureNumber, 1);
      },
    );

    testWidgets('dessine la barre du tempo à sa position dans la ligne', (
      tester,
    ) async {
      //arrange
      final line = layoutSongLines(song, measuresPerLine: 2).single;

      //act
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          home: Scaffold(
            body: SongScoreLine(
              line: line,
              song: song,
              measuresPerLine: 2,
              judgedVerdicts: const {},
              currentEventIndex: null,
              barPosition: 0.3,
              feedbackState: NoteState.idle,
              trebleMuted: false,
              bassMuted: false,
              section: wholeSong,
              height: 150,
            ),
          ),
        ),
      );

      //assert
      final sut = tester
          .widgetList<CustomPaint>(find.byType(CustomPaint))
          .map((customPaint) => customPaint.painter)
          .whereType<SongScoreLinePainter>()
          .single;
      expect(sut.cursorPosition, 0.3);
    });

    testWidgets('transmet au dessin la notation et les silences de la ligne', (
      tester,
    ) async {
      //arrange
      const notation = StaffNotation(
        value: NoteValue(NoteType.half, dotCount: 1),
        stemDirection: StemDirection.down,
      );
      const notatedSong = Song(
        title: 'Essai',
        measures: [
          SongMeasure(number: 1, startDivisions: 0, durationDivisions: 8),
        ],
        events: [
          SongEvent(
            measureNumber: 1,
            onsetDivisions: 0,
            notes: TwoStaffEvent(trebleSteps: [2], bassSteps: []),
            trebleNotation: notation,
          ),
        ],
        rests: [
          SongRest(
            measureNumber: 1,
            onsetDivisions: 6,
            isBass: false,
            value: NoteValue(NoteType.quarter),
          ),
          SongRest(
            measureNumber: 1,
            onsetDivisions: 0,
            isBass: true,
            value: null,
          ),
        ],
      );
      final line = layoutSongLines(notatedSong, measuresPerLine: 2).single;

      //act
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          home: Scaffold(
            body: SongScoreLine(
              line: line,
              song: notatedSong,
              measuresPerLine: 2,
              judgedVerdicts: const {},
              currentEventIndex: null,
              feedbackState: NoteState.idle,
              trebleMuted: false,
              bassMuted: false,
              section: wholeSong,
              height: 150,
            ),
          ),
        ),
      );

      //assert
      final sut = tester
          .widgetList<CustomPaint>(find.byType(CustomPaint))
          .map((customPaint) => customPaint.painter)
          .whereType<SongScoreLinePainter>()
          .single;
      expect(sut.notes.single.trebleNotation, notation);
      expect(sut.rests, const [
        ScoreLineRest(
          position: 0.375,
          isBass: false,
          value: NoteValue(NoteType.quarter),
        ),
        ScoreLineRest(position: 0.25, isBass: true, value: null),
      ]);
    });

    testWidgets(
      'dessine sans erreur toutes les figures, les points, les ligatures et les silences',
      (tester) async {
        //arrange
        const divisionsPerQuarter = 256;
        int divisionsOf(NoteType noteType) =>
            (noteType.quarters * divisionsPerQuarter).round();
        final events = <SongEvent>[];
        final rests = <SongRest>[];
        var onset = 0;
        for (final (index, noteType) in NoteType.values.indexed) {
          final beams = noteType.flagCount == 0
              ? const <BeamMark>[]
              : [
                  BeamMark.begin,
                  for (var level = 2; level <= noteType.flagCount; level++)
                    BeamMark.forwardHook,
                ];
          events.add(
            SongEvent(
              measureNumber: 1,
              onsetDivisions: onset,
              notes: TwoStaffEvent(
                trebleSteps: [index - 4, index + 2],
                bassSteps: [-10 - index],
              ),
              trebleNotation: StaffNotation(
                value: NoteValue(noteType, dotCount: index % 4),
                stemDirection: index.isEven
                    ? StemDirection.up
                    : StemDirection.down,
                beams: beams,
              ),
              bassNotation: StaffNotation(value: NoteValue(noteType)),
            ),
          );
          rests.add(
            SongRest(
              measureNumber: 1,
              onsetDivisions: onset,
              isBass: true,
              value: NoteValue(noteType, dotCount: index % 3),
            ),
          );
          onset += divisionsOf(noteType);
        }
        events.add(
          SongEvent(
            measureNumber: 1,
            onsetDivisions: onset,
            notes: const TwoStaffEvent(trebleSteps: [4], bassSteps: []),
            trebleNotation: const StaffNotation(
              value: NoteValue(NoteType.eighth),
              beams: [BeamMark.end],
            ),
          ),
        );
        final measureDuration = onset + divisionsOf(NoteType.eighth);
        final figuresSong = Song(
          title: 'Figures',
          divisionsPerQuarter: divisionsPerQuarter,
          measures: [
            SongMeasure(
              number: 1,
              startDivisions: 0,
              durationDivisions: measureDuration,
            ),
            SongMeasure(
              number: 2,
              startDivisions: measureDuration,
              durationDivisions: measureDuration,
            ),
          ],
          events: events,
          rests: [
            ...rests,
            SongRest(
              measureNumber: 2,
              onsetDivisions: measureDuration,
              isBass: false,
              value: null,
            ),
          ],
        );
        final line = layoutSongLines(figuresSong, measuresPerLine: 2).single;

        //act
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light(),
            home: Scaffold(
              body: SongScoreLine(
                line: line,
                song: figuresSong,
                measuresPerLine: 2,
                judgedVerdicts: const {},
                currentEventIndex: 3,
                feedbackState: NoteState.idle,
                trebleMuted: false,
                bassMuted: true,
                section: wholeSong,
                height: 200,
              ),
            ),
          ),
        );

        //assert
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('grise la portée de la main non travaillée, sans la juger', (
      tester,
    ) async {
      //arrange
      final line = layoutSongLines(song, measuresPerLine: 2).single;

      //act
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          home: Scaffold(
            body: SongScoreLine(
              line: line,
              song: song,
              measuresPerLine: 2,
              judgedVerdicts: const {0: correctTrebleWrongBass},
              currentEventIndex: 1,
              feedbackState: NoteState.idle,
              trebleMuted: false,
              bassMuted: true,
              section: wholeSong,
              height: 150,
            ),
          ),
        ),
      );

      //assert
      final sut = tester
          .widgetList<CustomPaint>(find.byType(CustomPaint))
          .map((customPaint) => customPaint.painter)
          .whereType<SongScoreLinePainter>()
          .single;
      expect(sut.bassMuted, isTrue);
      expect(sut.notes.first.bassState, NoteState.idle);
      expect(sut.notes.first.trebleState, NoteState.correct);
    });

    testWidgets('teinte seulement les mesures de la section sur cette ligne', (
      tester,
    ) async {
      //arrange
      final line = layoutSongLines(song, measuresPerLine: 2).single;

      //act
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          home: Scaffold(
            body: SongScoreLine(
              line: line,
              song: song,
              measuresPerLine: 2,
              judgedVerdicts: const {},
              currentEventIndex: 2,
              feedbackState: NoteState.idle,
              trebleMuted: false,
              bassMuted: false,
              section: const SongSection(
                firstMeasureNumber: 2,
                lastMeasureNumber: 5,
              ),
              height: 150,
            ),
          ),
        ),
      );

      //assert
      final sut = tester
          .widgetList<CustomPaint>(find.byType(CustomPaint))
          .map((customPaint) => customPaint.painter)
          .whereType<SongScoreLinePainter>()
          .single;
      expect(sut.sectionSlots, [1]);
    });
  });
}
