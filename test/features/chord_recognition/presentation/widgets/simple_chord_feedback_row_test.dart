import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:key_starter/core/enums/note_language.dart';
import 'package:key_starter/core/enums/note_state.dart';
import 'package:key_starter/core/theme/app_theme.dart';
import 'package:key_starter/features/chord_recognition/presentation/widgets/simple_chord_feedback_row.dart';

void main() {
  Future<void> pumpFeedbackRow(
    WidgetTester tester, {
    required List<int> playedMidiNumbers,
    required NoteState noteState,
    NoteLanguage language = NoteLanguage.fr,
  }) => tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light(),
      home: Scaffold(
        body: SimpleChordFeedbackRow(
          playedMidiNumbers: playedMidiNumbers,
          noteState: noteState,
          language: language,
        ),
      ),
    ),
  );

  group('SimpleChordFeedbackRow', () {
    testWidgets('nomme les touches jouées, sans octave', (tester) async {
      //arrange
      const cMajorChordInOctave5 = [72, 76, 79];

      //act
      await pumpFeedbackRow(
        tester,
        playedMidiNumbers: cMajorChordInOctave5,
        noteState: NoteState.correct,
      );

      //assert
      expect(find.text('Do Mi Sol'), findsOneWidget);
      expect(find.text(' · joué · suivant…'), findsOneWidget);
    });

    testWidgets('nomme aussi les touches noires, en anglais', (tester) async {
      //arrange
      const playedWithBlackKey = [62, 66, 69];

      //act
      await pumpFeedbackRow(
        tester,
        playedMidiNumbers: playedWithBlackKey,
        noteState: NoteState.wrong,
        language: NoteLanguage.en,
      );

      //assert
      expect(find.text('D F♯ A'), findsOneWidget);
      expect(find.text(' · faux · suivant…'), findsOneWidget);
    });

    testWidgets('n\'affiche rien tant qu\'aucune touche n\'est jouée', (
      tester,
    ) async {
      //act
      await pumpFeedbackRow(
        tester,
        playedMidiNumbers: const [],
        noteState: NoteState.idle,
      );

      //assert
      expect(find.textContaining('suivant'), findsNothing);
    });
  });
}
