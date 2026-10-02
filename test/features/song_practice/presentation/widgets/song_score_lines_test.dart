import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:key_starter/core/enums/note_state.dart';
import 'package:key_starter/core/models/two_staff_event.dart';
import 'package:key_starter/core/theme/app_theme.dart';
import 'package:key_starter/features/song_practice/domain/entities/song.dart';
import 'package:key_starter/features/song_practice/domain/entities/song_event.dart';
import 'package:key_starter/features/song_practice/domain/entities/song_measure.dart';
import 'package:key_starter/features/song_practice/presentation/widgets/song_score_line.dart';
import 'package:key_starter/features/song_practice/presentation/widgets/song_score_lines.dart';

/// Six mesures (trois lignes), une note par mesure.
final song = Song(
  title: 'Essai',
  measures: [
    for (var index = 0; index < 6; index++)
      SongMeasure(
        number: index + 1,
        startDivisions: index * 8,
        durationDivisions: 8,
      ),
  ],
  events: [
    for (var index = 0; index < 6; index++)
      SongEvent(
        measureNumber: index + 1,
        onsetDivisions: index * 8,
        notes: const TwoStaffEvent(trebleSteps: [0], bassSteps: []),
      ),
  ],
);

void main() {
  const lineHeight = 120.0;

  Future<void> pumpLines(
    WidgetTester tester, {
    required int currentEventIndex,
  }) => tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light(),
      home: Scaffold(
        body: SongScoreLines(
          song: song,
          judgedVerdicts: const {},
          currentEventIndex: currentEventIndex,
          feedbackState: NoteState.idle,
          trebleMuted: false,
          bassMuted: false,
          lineHeight: lineHeight,
        ),
      ),
    ),
  );

  Map<int, double> visibleLineTops(WidgetTester tester) {
    final origin = tester.getTopLeft(find.byType(SongScoreLines)).dy;
    return {
      for (final element in find.byType(SongScoreLine).evaluate())
        (element.widget as SongScoreLine).line.firstMeasureNumber:
            tester.getTopLeft(find.byWidget(element.widget)).dy - origin,
    };
  }

  group('SongScoreLines', () {
    testWidgets('montre la ligne en cours en haut et la suivante en dessous', (
      tester,
    ) async {
      //act
      await pumpLines(tester, currentEventIndex: 0);

      //assert
      expect(visibleLineTops(tester), {1: 0.0, 3: lineHeight});
    });

    testWidgets(
      'fait remonter les lignes quand le repère passe à la ligne suivante',
      (tester) async {
        //arrange
        await pumpLines(tester, currentEventIndex: 1);

        //act
        await pumpLines(tester, currentEventIndex: 2);
        await tester.pumpAndSettle();

        //assert
        expect(visibleLineTops(tester), {3: 0.0, 5: lineHeight});
      },
    );
  });
}
