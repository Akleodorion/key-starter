import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:key_starter/core/enums/note_state.dart';
import 'package:key_starter/core/widgets/note_feedback_motion.dart';

void main() {
  late double lastScale;
  late double lastShift;

  Future<void> pumpMotion(WidgetTester tester, NoteState noteState) =>
      tester.pumpWidget(
        NoteFeedbackMotion(
          noteState: noteState,
          builder: (context, scale, shift) {
            lastScale = scale;
            lastShift = shift;
            return const SizedBox();
          },
        ),
      );

  group('NoteFeedbackMotion', () {
    testWidgets('ne bouge pas la note au repos', (tester) async {
      //arrange
      //act
      await pumpMotion(tester, NoteState.idle);

      //assert
      expect(lastScale, 1);
      expect(lastShift, 0);
    });

    testWidgets('fait gonfler une note qui devient juste, puis la ramène', (
      tester,
    ) async {
      //arrange
      await pumpMotion(tester, NoteState.idle);

      //act
      await pumpMotion(tester, NoteState.correct);
      await tester.pump(const Duration(milliseconds: 200));
      final midScale = lastScale;
      await tester.pump(const Duration(milliseconds: 250));

      //assert
      expect(midScale, greaterThan(1.2));
      expect(lastScale, 1);
    });

    testWidgets('fait trembler une note qui devient fausse, puis la replace', (
      tester,
    ) async {
      //arrange
      await pumpMotion(tester, NoteState.idle);

      //act
      await pumpMotion(tester, NoteState.wrong);
      await tester.pump(const Duration(milliseconds: 50));
      final midShift = lastShift;
      await tester.pump(const Duration(milliseconds: 400));

      //assert
      expect(midShift, isNot(0));
      expect(lastShift, 0);
    });
  });
}
