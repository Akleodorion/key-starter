import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:key_starter/core/enums/note_state.dart';
import 'package:key_starter/core/models/two_staff_event.dart';
import 'package:key_starter/core/theme/app_theme.dart';
import 'package:key_starter/core/utils/two_staff_judgement.dart';
import 'package:key_starter/features/song_practice/domain/entities/song.dart';
import 'package:key_starter/features/song_practice/domain/entities/song_event.dart';
import 'package:key_starter/features/song_practice/domain/entities/song_measure.dart';
import 'package:key_starter/features/song_practice/domain/entities/song_section.dart';
import 'package:key_starter/features/song_practice/presentation/layout/score_line_note.dart';
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
