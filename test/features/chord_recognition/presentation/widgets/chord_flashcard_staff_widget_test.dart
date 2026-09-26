import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:key_starter/core/enums/clef_mode.dart';
import 'package:key_starter/core/enums/note_state.dart';
import 'package:key_starter/core/theme/app_theme.dart';
import 'package:key_starter/features/chord_recognition/presentation/providers/chord_flashcard_exercise_notifier.dart';
import 'package:key_starter/features/chord_recognition/presentation/providers/chord_flashcard_exercise_state.dart';
import 'package:key_starter/features/chord_recognition/presentation/widgets/chord_flashcard_staff_widget.dart';
import 'package:key_starter/features/note_recognition/presentation/providers/note_exercise_settings_state.dart';

class ScriptedChordFlashcardNotifier extends ChordFlashcardExerciseNotifier {
  ScriptedChordFlashcardNotifier(super.settings);

  @override
  ChordFlashcardExerciseState build() => const ChordFlashcardExerciseRunning(
    chordSteps: [
      [0, 2, 4],
    ],
    currentIndex: 0,
    noteState: NoteState.idle,
  );

  void judgeCurrentChord(NoteState noteState) => state =
      (state as ChordFlashcardExerciseRunning).copyWith(noteState: noteState);
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
        chordFlashcardExerciseProvider(
          settings,
        ).overrideWith(() => ScriptedChordFlashcardNotifier(settings)),
      ],
    );
    addTearDown(container.dispose);
    return tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const Scaffold(
            body: ChordFlashcardStaffWidget(settings: settings),
          ),
        ),
      ),
    );
  }

  ScriptedChordFlashcardNotifier readNotifier() =>
      container.read(chordFlashcardExerciseProvider(settings).notifier)
          as ScriptedChordFlashcardNotifier;

  ChordFlashcardStaffPainter readPainter(WidgetTester tester) =>
      tester
              .widget<CustomPaint>(
                find.byWidgetPredicate(
                  (widget) =>
                      widget is CustomPaint &&
                      widget.painter is ChordFlashcardStaffPainter,
                ),
              )
              .painter
          as ChordFlashcardStaffPainter;

  group('ChordFlashcardStaffWidget', () {
    testWidgets('dessine l\'accord sans effet au repos', (tester) async {
      //arrange
      //act
      await pumpStaff(tester);

      //assert
      final painter = readPainter(tester);
      expect(painter.chordScale, 1);
      expect(painter.chordShift, 0);
    });

    testWidgets('fait gonfler l\'accord quand il est juste, puis le ramène', (
      tester,
    ) async {
      //arrange
      await pumpStaff(tester);

      //act
      readNotifier().judgeCurrentChord(NoteState.correct);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      final midAnimation = readPainter(tester);
      await tester.pump(const Duration(milliseconds: 250));
      final afterAnimation = readPainter(tester);

      //assert
      expect(midAnimation.chordScale, greaterThan(1.2));
      expect(afterAnimation.chordScale, 1);
    });

    testWidgets('fait trembler l\'accord quand il est faux', (tester) async {
      //arrange
      await pumpStaff(tester);

      //act
      readNotifier().judgeCurrentChord(NoteState.wrong);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      final midAnimation = readPainter(tester);

      //assert
      expect(midAnimation.chordShift, isNot(0));
      expect(midAnimation.chordScale, 1);
    });
  });
}
