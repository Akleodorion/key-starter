import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:key_starter/core/enums/clef_mode.dart';
import 'package:key_starter/core/enums/note_state.dart';
import 'package:key_starter/core/theme/app_colors.dart';
import 'package:key_starter/core/theme/app_theme.dart';
import 'package:key_starter/core/widgets/tempo_staff_line.dart';

void main() {
  const noteGroups = [
    [0],
    [2],
    [4],
    [6],
  ];

  Future<void> pumpStaffLine(
    WidgetTester tester, {
    required List<NoteState> noteStates,
    double? barFraction,
  }) => tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light(),
      home: Scaffold(
        body: TempoStaffLine(
          noteGroups: noteGroups,
          noteStates: noteStates,
          clef: ClefMode.treble,
          barFraction: barFraction,
        ),
      ),
    ),
  );

  TempoStaffLinePainter readPainter(WidgetTester tester) =>
      tester
              .widget<CustomPaint>(
                find.descendant(
                  of: find.byType(TempoStaffLine),
                  matching: find.byWidgetPredicate(
                    (widget) =>
                        widget is CustomPaint &&
                        widget.painter is TempoStaffLinePainter,
                  ),
                ),
              )
              .painter
          as TempoStaffLinePainter;

  const allIdle = [
    NoteState.idle,
    NoteState.idle,
    NoteState.idle,
    NoteState.idle,
  ];

  group('TempoStaffLine', () {
    testWidgets('dessine les notes de la ligne, sans effet au repos', (
      tester,
    ) async {
      //arrange
      //act
      await pumpStaffLine(tester, noteStates: allIdle);

      //assert
      final painter = readPainter(tester);
      expect(painter.noteGroups, noteGroups);
      expect(painter.noteScales, everyElement(1.0));
      expect(painter.noteShifts, everyElement(0.0));
    });

    testWidgets('fait gonfler en vert une note juste, puis la ramène', (
      tester,
    ) async {
      //arrange
      await pumpStaffLine(tester, noteStates: allIdle);

      //act
      await pumpStaffLine(
        tester,
        noteStates: const [
          NoteState.idle,
          NoteState.correct,
          NoteState.idle,
          NoteState.idle,
        ],
      );
      await tester.pump(const Duration(milliseconds: 200));
      final midAnimation = readPainter(tester);
      await tester.pump(const Duration(milliseconds: 250));
      final afterAnimation = readPainter(tester);

      //assert
      expect(midAnimation.noteColors[1], AppColors.stateGreen);
      expect(midAnimation.noteScales[1], greaterThan(1.2));
      expect(midAnimation.noteShifts[1], 0);
      expect(midAnimation.noteScales[0], 1);
      expect(afterAnimation.noteScales[1], 1);
    });

    testWidgets('fait trembler en rouge une note fausse ou ratée', (
      tester,
    ) async {
      //arrange
      await pumpStaffLine(tester, noteStates: allIdle);

      //act
      await pumpStaffLine(
        tester,
        noteStates: const [
          NoteState.wrong,
          NoteState.idle,
          NoteState.idle,
          NoteState.idle,
        ],
      );
      await tester.pump(const Duration(milliseconds: 50));
      final midAnimation = readPainter(tester);
      await tester.pump(const Duration(milliseconds: 400));
      final afterAnimation = readPainter(tester);

      //assert
      expect(midAnimation.noteColors[0], AppColors.stateRed);
      expect(midAnimation.noteShifts[0], isNot(0));
      expect(midAnimation.noteScales[0], 1);
      expect(afterAnimation.noteShifts[0], 0);
    });

    testWidgets('dessine la barre seulement sur la ligne qui la porte', (
      tester,
    ) async {
      //arrange
      await pumpStaffLine(tester, noteStates: allIdle, barFraction: 0.25);
      final withBar = readPainter(tester);

      //act
      await pumpStaffLine(tester, noteStates: allIdle);

      //assert
      expect(withBar.barFraction, 0.25);
      expect(readPainter(tester).barFraction, isNull);
    });
  });

  group('TempoStaffLinePainter', () {
    TempoStaffLinePainter painterFor(List<List<int>> noteGroups) =>
        TempoStaffLinePainter(
          noteGroups: noteGroups,
          noteColors: List.filled(noteGroups.length, Colors.black),
          noteScales: List.filled(noteGroups.length, 1),
          noteShifts: List.filled(noteGroups.length, 0),
          barFraction: null,
          clef: ClefMode.treble,
          lineColor: Colors.black,
          lineGap: 10,
        );

    test('should repaint when a chord of the line changes', () {
      //arrange
      final previous = painterFor([
        [0, 2, 4],
      ]);
      final sut = painterFor([
        [1, 3, 5],
      ]);

      //act
      final shouldRepaint = sut.shouldRepaint(previous);

      //assert
      expect(shouldRepaint, isTrue);
    });

    test('should not repaint when the chords are the same', () {
      //arrange
      final previous = painterFor([
        [0, 2, 4],
      ]);
      final sut = painterFor([
        [0, 2, 4],
      ]);

      //act
      final shouldRepaint = sut.shouldRepaint(previous);

      //assert
      expect(shouldRepaint, isFalse);
    });
  });
}
