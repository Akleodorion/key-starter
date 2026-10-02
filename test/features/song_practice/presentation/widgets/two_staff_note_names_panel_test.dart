import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:key_starter/core/enums/note_language.dart';
import 'package:key_starter/core/models/two_staff_event.dart';
import 'package:key_starter/core/theme/app_theme.dart';
import 'package:key_starter/core/utils/two_staff_judgement.dart';
import 'package:key_starter/features/song_practice/presentation/widgets/two_staff_note_names_panel.dart';

void main() {
  const event = TwoStaffEvent(trebleSteps: [0], bassSteps: [-7, -5, -3]);

  Future<void> pumpPanel(
    WidgetTester tester, {
    TwoStaffVerdict? verdict,
    NoteLanguage language = NoteLanguage.fr,
  }) => tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light(),
      home: Scaffold(
        body: TwoStaffNoteNamesPanel(
          event: event,
          verdict: verdict,
          language: language,
        ),
      ),
    ),
  );

  group('TwoStaffNoteNamesPanel', () {
    testWidgets('affiche les notes attendues par main, octave comprise', (
      tester,
    ) async {
      //act
      await pumpPanel(tester);

      //assert
      expect(find.text('Main droite : Do 4'), findsOneWidget);
      expect(find.text('Main gauche : Do 3 · Mi 3 · Sol 3'), findsOneWidget);
      expect(find.textContaining('Joué'), findsNothing);
    });

    testWidgets('suit la langue de notation choisie', (tester) async {
      //act
      await pumpPanel(tester, language: NoteLanguage.en);

      //assert
      expect(find.text('Main droite : C 4'), findsOneWidget);
      expect(find.text('Main gauche : C 3 · E 3 · G 3'), findsOneWidget);
    });

    testWidgets(
      'affiche les touches détectées pour chaque main une fois jugé, touches noires comprises',
      (tester) async {
        //arrange
        const verdict = TwoStaffVerdict(
          treble: StaffPartVerdict(isCorrect: false, playedMidiNumbers: {61}),
          bass: StaffPartVerdict(
            isCorrect: true,
            playedMidiNumbers: {55, 48, 52},
          ),
        );

        //act
        await pumpPanel(tester, verdict: verdict);

        //assert
        expect(find.text('Joué : Do♯ 4'), findsOneWidget);
        expect(find.text('Joué : Do 3 · Mi 3 · Sol 3'), findsOneWidget);
      },
    );
  });
}
