import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:key_starter/core/enums/note_language.dart';
import 'package:key_starter/core/enums/note_state.dart';
import 'package:key_starter/core/theme/app_theme.dart';
import 'package:key_starter/features/chord_recognition/domain/entities/chord_inversion.dart';
import 'package:key_starter/features/chord_recognition/domain/entities/chord_prompt.dart';
import 'package:key_starter/features/chord_recognition/presentation/widgets/simple_chord_display.dart';

void main() {
  Future<void> pumpDisplay(
    WidgetTester tester, {
    required ChordPrompt chord,
    required NoteLanguage language,
  }) => tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light(),
      home: Scaffold(
        body: SimpleChordDisplay(
          chord: chord,
          noteState: NoteState.idle,
          language: language,
        ),
      ),
    ),
  );

  group('SimpleChordDisplay', () {
    const expectedLabels = {
      NoteLanguage.fr: ['|Do', '|Rém', '|Mim', '|Fa', '|Sol', '|Lam', '|Sim'],
      NoteLanguage.en: ['|C', '|Dm', '|Em', '|F', '|G', '|Am', '|Bm'],
    };

    for (final MapEntry(key: language, value: labels)
        in expectedLabels.entries) {
      for (var rootIndex = 0; rootIndex < labels.length; rootIndex++) {
        testWidgets(
          'affiche ${labels[rootIndex]} pour la fondamentale $rootIndex (${language.name})',
          (tester) async {
            //act
            await pumpDisplay(
              tester,
              chord: ChordPrompt(
                rootIndex: rootIndex,
                inversion: ChordInversion.rootPosition,
              ),
              language: language,
            );

            //assert
            expect(find.text(labels[rootIndex]), findsOneWidget);
          },
        );
      }
    }

    const expectedInversionLabels = {
      (0, ChordInversion.first, NoteLanguage.fr): '|Do(1)',
      (1, ChordInversion.second, NoteLanguage.fr): '|Rém(2)',
      (6, ChordInversion.first, NoteLanguage.fr): '|Sim(1)',
      (4, ChordInversion.second, NoteLanguage.en): '|G(2)',
      (5, ChordInversion.first, NoteLanguage.en): '|Am(1)',
    };

    for (final MapEntry(key: (rootIndex, inversion, language), value: label)
        in expectedInversionLabels.entries) {
      testWidgets('affiche $label, renversement après le suffixe m', (
        tester,
      ) async {
        //act
        await pumpDisplay(
          tester,
          chord: ChordPrompt(rootIndex: rootIndex, inversion: inversion),
          language: language,
        );

        //assert
        expect(find.text(label), findsOneWidget);
      });
    }
  });
}
