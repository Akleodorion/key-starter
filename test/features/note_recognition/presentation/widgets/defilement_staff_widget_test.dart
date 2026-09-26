import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:key_starter/core/enums/clef_mode.dart';
import 'package:key_starter/core/enums/note_state.dart';
import 'package:key_starter/core/theme/app_theme.dart';
import 'package:key_starter/features/note_recognition/presentation/providers/defilement_exercise_notifier.dart';
import 'package:key_starter/features/note_recognition/presentation/providers/defilement_exercise_state.dart';
import 'package:key_starter/features/note_recognition/presentation/providers/note_exercise_settings_state.dart';
import 'package:key_starter/features/note_recognition/presentation/widgets/defilement_staff_widget.dart';

class ScriptedDefilementNotifier extends DefilementExerciseNotifier {
  ScriptedDefilementNotifier(super.settings);

  @override
  DefilementExerciseState build() => const DefilementExerciseRunning(
    noteSteps: [0, 2, 4],
    currentIndex: 1,
    noteState: NoteState.idle,
  );

  void judgeCurrentNote(NoteState noteState) => state =
      (state as DefilementExerciseRunning).copyWith(noteState: noteState);
}

void main() {
  const settings = NoteExerciseSettings(
    clef: ClefMode.treble,
    noteCount: 3,
    minNoteStep: 0,
    maxNoteStep: 6,
  );

  late ProviderContainer container;

  Future<void> pumpStaff(WidgetTester tester) {
    container = ProviderContainer(
      overrides: [
        defilementExerciseProvider(
          settings,
        ).overrideWith(() => ScriptedDefilementNotifier(settings)),
      ],
    );
    addTearDown(container.dispose);
    return tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const Scaffold(body: DefilementStaffWidget(settings: settings)),
        ),
      ),
    );
  }

  ScriptedDefilementNotifier readNotifier() =>
      container.read(defilementExerciseProvider(settings).notifier)
          as ScriptedDefilementNotifier;

  DefilementScrollingStaffPainter readPainter(WidgetTester tester) =>
      tester
              .widget<CustomPaint>(
                find.byWidgetPredicate(
                  (widget) =>
                      widget is CustomPaint &&
                      widget.painter is DefilementScrollingStaffPainter,
                ),
              )
              .painter
          as DefilementScrollingStaffPainter;

  group('DefilementStaffWidget', () {
    testWidgets('dessine la note courante sans effet au repos', (tester) async {
      //arrange
      //act
      await pumpStaff(tester);

      //assert
      final painter = readPainter(tester);
      expect(painter.currentNoteScale, 1);
      expect(painter.currentNoteShift, 0);
    });

    testWidgets('fait gonfler la note courante quand elle est juste', (
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
      expect(midAnimation.currentNoteScale, greaterThan(1.2));
      expect(afterAnimation.currentNoteScale, 1);
    });

    testWidgets('fait trembler la note courante quand elle est fausse', (
      tester,
    ) async {
      //arrange
      await pumpStaff(tester);

      //act
      readNotifier().judgeCurrentNote(NoteState.wrong);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 20));
      final midAnimation = readPainter(tester);

      //assert
      expect(midAnimation.currentNoteShift, isNot(0));
      expect(midAnimation.currentNoteScale, 1);
    });
  });
}
