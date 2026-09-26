import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:key_starter/core/enums/clef_mode.dart';
import 'package:key_starter/core/enums/note_state.dart';
import 'package:key_starter/core/theme/app_theme.dart';
import 'package:key_starter/core/widgets/staff_widget.dart';
import 'package:key_starter/features/note_recognition/presentation/providers/flashcard_exercise_notifier.dart';
import 'package:key_starter/features/note_recognition/presentation/providers/flashcard_exercise_state.dart';
import 'package:key_starter/features/note_recognition/presentation/providers/note_exercise_settings_state.dart';
import 'package:key_starter/features/note_recognition/presentation/widgets/flashcard_staff_widget.dart';

class ScriptedFlashcardNotifier extends FlashcardExerciseNotifier {
  ScriptedFlashcardNotifier(super.settings);

  @override
  FlashcardExerciseState build() => const FlashcardExerciseRunning(
    noteSteps: [2],
    currentIndex: 0,
    noteState: NoteState.idle,
  );

  void judgeCurrentNote(NoteState noteState) => state =
      (state as FlashcardExerciseRunning).copyWith(noteState: noteState);
}

void main() {
  const settings = NoteExerciseSettings(
    clef: ClefMode.treble,
    noteCount: 1,
    minNoteStep: 0,
    maxNoteStep: 6,
  );

  late ProviderContainer container;

  Future<void> pumpStaff(WidgetTester tester) {
    container = ProviderContainer(
      overrides: [
        flashcardExerciseProvider(
          settings,
        ).overrideWith(() => ScriptedFlashcardNotifier(settings)),
      ],
    );
    addTearDown(container.dispose);
    return tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const Scaffold(body: FlashcardStaffWidget(settings: settings)),
        ),
      ),
    );
  }

  ScriptedFlashcardNotifier readNotifier() =>
      container.read(flashcardExerciseProvider(settings).notifier)
          as ScriptedFlashcardNotifier;

  StaffPainter readPainter(WidgetTester tester) =>
      tester
              .widget<CustomPaint>(
                find.byWidgetPredicate(
                  (widget) =>
                      widget is CustomPaint && widget.painter is StaffPainter,
                ),
              )
              .painter
          as StaffPainter;

  group('FlashcardStaffWidget', () {
    testWidgets('dessine la note sans effet au repos', (tester) async {
      //arrange
      //act
      await pumpStaff(tester);

      //assert
      final painter = readPainter(tester);
      expect(painter.noteScale, 1);
      expect(painter.noteShift, 0);
    });

    testWidgets('fait gonfler la note quand elle est juste, puis la ramène', (
      tester,
    ) async {
      //arrange
      await pumpStaff(tester);

      //act
      readNotifier().judgeCurrentNote(NoteState.correct);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 75));
      final midAnimation = readPainter(tester);
      await tester.pump(const Duration(milliseconds: 100));
      final afterAnimation = readPainter(tester);

      //assert
      expect(midAnimation.state, NoteState.correct);
      expect(midAnimation.noteScale, greaterThan(1.2));
      expect(afterAnimation.noteScale, 1);
    });

    testWidgets('fait trembler la note quand elle est fausse', (tester) async {
      //arrange
      await pumpStaff(tester);

      //act
      readNotifier().judgeCurrentNote(NoteState.wrong);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 20));
      final midAnimation = readPainter(tester);

      //assert
      expect(midAnimation.state, NoteState.wrong);
      expect(midAnimation.noteShift, isNot(0));
      expect(midAnimation.noteScale, 1);
    });
  });
}
