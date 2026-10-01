import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:key_starter/core/enums/clef_mode.dart';
import 'package:key_starter/core/enums/note_state.dart';
import 'package:key_starter/core/theme/app_theme.dart';
import 'package:key_starter/core/widgets/tempo_staff_line.dart';
import 'package:key_starter/core/widgets/tempo_staff_lines.dart';

void main() {
  // 10 notes : lignes de 4, 4 et 2 notes.
  const noteGroups = [
    [0],
    [1],
    [2],
    [3],
    [4],
    [5],
    [6],
    [0],
    [1],
    [2],
  ];
  final noteStates = List.filled(noteGroups.length, NoteState.idle);

  Future<void> pumpStaffLines(
    WidgetTester tester, {
    required double topLine,
    int barLine = 0,
    double barFraction = 0,
  }) => tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light(),
      home: Scaffold(
        body: TempoStaffLines(
          noteGroups: noteGroups,
          noteStates: noteStates,
          clef: ClefMode.treble,
          topLine: topLine,
          barLine: barLine,
          barFraction: barFraction,
        ),
      ),
    ),
  );

  Finder lineFinder(int lineIndex) => find.descendant(
    of: find.byKey(ValueKey(lineIndex)),
    matching: find.byType(TempoStaffLine),
  );

  double opacityOf(WidgetTester tester, int lineIndex) => tester
      .widget<Opacity>(
        find.descendant(
          of: find.byKey(ValueKey(lineIndex)),
          matching: find.byType(Opacity),
        ),
      )
      .opacity;

  group('TempoStaffLines', () {
    testWidgets('affiche la ligne en cours et la suivante', (tester) async {
      //arrange
      //act
      await pumpStaffLines(tester, topLine: 0);

      //assert
      expect(lineFinder(0), findsOneWidget);
      expect(lineFinder(1), findsOneWidget);
      expect(lineFinder(2), findsNothing);
      expect(opacityOf(tester, 0), 1);
      expect(opacityOf(tester, 1), 1);
    });

    testWidgets('répartit les notes par ligne de 4', (tester) async {
      //arrange
      //act
      await pumpStaffLines(tester, topLine: 1);

      //assert
      final secondLine = tester.widget<TempoStaffLine>(lineFinder(1));
      final lastLine = tester.widget<TempoStaffLine>(lineFinder(2));
      expect(secondLine.noteGroups, [
        [4],
        [5],
        [6],
        [0],
      ]);
      expect(lastLine.noteGroups, [
        [1],
        [2],
      ]);
    });

    testWidgets(
      'fond la ligne qui sort et celle qui entre pendant la remontée',
      (tester) async {
        //arrange
        //act
        await pumpStaffLines(tester, topLine: 0.5);

        //assert
        expect(opacityOf(tester, 0), 0.5);
        expect(opacityOf(tester, 1), 1);
        expect(opacityOf(tester, 2), 0.5);
      },
    );

    testWidgets('laisse le bas vide sur la dernière ligne', (tester) async {
      //arrange
      //act
      await pumpStaffLines(tester, topLine: 2);

      //assert
      expect(lineFinder(2), findsOneWidget);
      expect(lineFinder(3), findsNothing);
    });

    testWidgets('ne met la barre que sur sa ligne', (tester) async {
      //arrange
      //act
      await pumpStaffLines(tester, topLine: 0, barLine: 0, barFraction: 0.5);

      //assert
      expect(tester.widget<TempoStaffLine>(lineFinder(0)).barFraction, 0.5);
      expect(tester.widget<TempoStaffLine>(lineFinder(1)).barFraction, isNull);
    });
  });
}
