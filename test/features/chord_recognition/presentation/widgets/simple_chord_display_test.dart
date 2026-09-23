import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:key_starter/core/enums/note_language.dart';
import 'package:key_starter/core/enums/note_state.dart';
import 'package:key_starter/core/theme/app_theme.dart';
import 'package:key_starter/features/chord_recognition/presentation/widgets/simple_chord_display.dart';

void main() {
  Future<void> pumpDisplay(
    WidgetTester tester, {
    required int rootIndex,
    required NoteLanguage language,
  }) => tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light(),
      home: Scaffold(
        body: SimpleChordDisplay(
          rootIndex: rootIndex,
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
            await pumpDisplay(tester, rootIndex: rootIndex, language: language);

            //assert
            expect(find.text(labels[rootIndex]), findsOneWidget);
          },
        );
      }
    }
  });
}
