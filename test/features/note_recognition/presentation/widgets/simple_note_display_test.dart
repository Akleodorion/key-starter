import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:key_starter/core/enums/note_language.dart';
import 'package:key_starter/core/enums/note_state.dart';
import 'package:key_starter/core/theme/app_theme.dart';
import 'package:key_starter/features/note_recognition/presentation/widgets/simple_note_display.dart';

void main() {
  Future<void> pumpDisplay(
    WidgetTester tester, {
    required int noteIndex,
    required NoteLanguage language,
  }) => tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light(),
      home: Scaffold(
        body: SimpleNoteDisplay(
          noteIndex: noteIndex,
          noteState: NoteState.idle,
          language: language,
        ),
      ),
    ),
  );

  group('SimpleNoteDisplay', () {
    testWidgets('affiche le nom français de la note, sans octave', (
      tester,
    ) async {
      //arrange
      const solNoteIndex = 4;

      //act
      await pumpDisplay(
        tester,
        noteIndex: solNoteIndex,
        language: NoteLanguage.fr,
      );

      //assert
      expect(find.text('Sol'), findsOneWidget);
    });

    testWidgets('affiche le nom anglais de la note, sans octave', (
      tester,
    ) async {
      //arrange
      const solNoteIndex = 4;

      //act
      await pumpDisplay(
        tester,
        noteIndex: solNoteIndex,
        language: NoteLanguage.en,
      );

      //assert
      expect(find.text('G'), findsOneWidget);
    });
  });
}
