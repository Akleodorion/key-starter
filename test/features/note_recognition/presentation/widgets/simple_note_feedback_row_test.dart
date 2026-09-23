import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:key_starter/core/enums/note_language.dart';
import 'package:key_starter/core/enums/note_state.dart';
import 'package:key_starter/core/theme/app_theme.dart';
import 'package:key_starter/features/note_recognition/presentation/widgets/simple_note_feedback_row.dart';

void main() {
  Future<void> pumpFeedbackRow(
    WidgetTester tester, {
    required int? playedMidiNumber,
    required NoteState noteState,
    NoteLanguage language = NoteLanguage.fr,
  }) => tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light(),
      home: Scaffold(
        body: SimpleNoteFeedbackRow(
          playedMidiNumber: playedMidiNumber,
          noteState: noteState,
          language: language,
        ),
      ),
    ),
  );

  group('SimpleNoteFeedbackRow', () {
    testWidgets('nomme une touche blanche jouée, sans octave', (tester) async {
      //arrange
      const g5MidiNumber = 79;

      //act
      await pumpFeedbackRow(
        tester,
        playedMidiNumber: g5MidiNumber,
        noteState: NoteState.correct,
      );

      //assert
      expect(find.text('Sol'), findsOneWidget);
      expect(find.text(' · joué · suivante…'), findsOneWidget);
    });

    testWidgets('nomme une touche noire jouée, en français', (tester) async {
      //arrange
      const cSharp4MidiNumber = 61;

      //act
      await pumpFeedbackRow(
        tester,
        playedMidiNumber: cSharp4MidiNumber,
        noteState: NoteState.wrong,
      );

      //assert
      expect(find.text('Do♯'), findsOneWidget);
      expect(find.text(' · faux · suivante…'), findsOneWidget);
    });

    testWidgets('nomme une touche noire jouée, en anglais', (tester) async {
      //arrange
      const fSharp3MidiNumber = 54;

      //act
      await pumpFeedbackRow(
        tester,
        playedMidiNumber: fSharp3MidiNumber,
        noteState: NoteState.wrong,
        language: NoteLanguage.en,
      );

      //assert
      expect(find.text('F♯'), findsOneWidget);
    });

    testWidgets('n\'affiche rien tant qu\'aucune touche n\'est jouée', (
      tester,
    ) async {
      //act
      await pumpFeedbackRow(
        tester,
        playedMidiNumber: null,
        noteState: NoteState.idle,
      );

      //assert
      expect(find.textContaining('suivante'), findsNothing);
    });
  });
}
