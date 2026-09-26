import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:key_starter/core/enums/note_language.dart';
import 'package:key_starter/core/enums/note_state.dart';
import 'package:key_starter/core/theme/app_theme.dart';
import 'package:key_starter/features/note_recognition/presentation/widgets/simple_note_display.dart';

void main() {
  Future<void> pumpDisplay(
    WidgetTester tester, {
    required int pitchClass,
    required NoteLanguage language,
  }) => tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light(),
      home: Scaffold(
        body: SimpleNoteDisplay(
          pitchClass: pitchClass,
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
      const solPitchClass = 7;

      //act
      await pumpDisplay(
        tester,
        pitchClass: solPitchClass,
        language: NoteLanguage.fr,
      );

      //assert
      expect(find.text('Sol'), findsOneWidget);
    });

    testWidgets('affiche le nom anglais de la note, sans octave', (
      tester,
    ) async {
      //arrange
      const solPitchClass = 7;

      //act
      await pumpDisplay(
        tester,
        pitchClass: solPitchClass,
        language: NoteLanguage.en,
      );

      //assert
      expect(find.text('G'), findsOneWidget);
    });

    testWidgets('affiche une touche noire en dièse, sans octave', (
      tester,
    ) async {
      //arrange
      const fSharpPitchClass = 6;

      //act
      await pumpDisplay(
        tester,
        pitchClass: fSharpPitchClass,
        language: NoteLanguage.fr,
      );

      //assert
      expect(find.text('Fa♯'), findsOneWidget);
    });
  });
}
