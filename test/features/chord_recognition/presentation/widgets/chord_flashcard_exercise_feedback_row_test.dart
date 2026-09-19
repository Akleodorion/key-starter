import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:key_starter/core/enums/note_language.dart';
import 'package:key_starter/core/enums/note_state.dart';
import 'package:key_starter/core/theme/app_theme.dart';
import 'package:key_starter/features/chord_recognition/presentation/widgets/chord_flashcard_exercise_feedback_row.dart';

void main() {
  Future<void> pumpFeedbackRow(
    WidgetTester tester, {
    required List<int>? playedSteps,
    required NoteState noteState,
  }) => tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light(),
      home: Scaffold(
        body: ChordFlashcardExerciseFeedbackRow(
          playedSteps: playedSteps,
          noteState: noteState,
          language: NoteLanguage.fr,
        ),
      ),
    ),
  );

  group('ChordFlashcardExerciseFeedbackRow', () {
    testWidgets(
      'n\'affiche rien quand aucune note n\'a été jouée (null ou liste vide)',
      (tester) async {
        //act
        await pumpFeedbackRow(
          tester,
          playedSteps: null,
          noteState: NoteState.idle,
        );

        //assert
        expect(find.byType(Icon), findsNothing);

        //act
        await pumpFeedbackRow(
          tester,
          playedSteps: const [],
          noteState: NoteState.idle,
        );

        //assert
        expect(find.byType(Icon), findsNothing);
      },
    );

    testWidgets(
      'affiche les notes jouées jointes et "joué" quand l\'accord est correct',
      (tester) async {
        //act
        await pumpFeedbackRow(
          tester,
          playedSteps: const [0, 2, 4],
          noteState: NoteState.correct,
        );

        //assert
        expect(find.text('Do 4 · Mi 4 · Sol 4'), findsOneWidget);
        expect(find.text(' · joué · suivant…'), findsOneWidget);
      },
    );

    testWidgets(
      'affiche les notes jouées jointes et "faux" quand l\'accord est incorrect',
      (tester) async {
        //act
        await pumpFeedbackRow(
          tester,
          playedSteps: const [1, 2, 4],
          noteState: NoteState.wrong,
        );

        //assert
        expect(find.text('Ré 4 · Mi 4 · Sol 4'), findsOneWidget);
        expect(find.text(' · faux · suivant…'), findsOneWidget);
      },
    );
  });
}
