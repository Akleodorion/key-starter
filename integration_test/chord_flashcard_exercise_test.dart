import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:key_starter/core/widgets/entry_card.dart';
import 'package:key_starter/core/widgets/primary_icon_button.dart';
import 'package:key_starter/features/chord_recognition/presentation/widgets/chord_flashcard_note_count_row.dart';
import 'package:key_starter/injection_container.dart';
import 'package:key_starter/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Exercice Accords - clé de Sol, 10 accords', () {
    testWidgets(
      'joue 10 accords (bonnes et mauvaises réponses), affiche le récap, puis quitte',
      (tester) async {
        //arrange
        await _startChordFlashcardExerciseWithTenChords(tester);
        await _answerTenChordsAlternately(tester);

        //assert - le récap s'affiche avec 50% de bonnes réponses (5 correctes / 10)
        expect(find.text('Lecture · accords'), findsOneWidget);
        expect(find.text('RÉSULTAT'), findsOneWidget);
        expect(find.text('50'), findsOneWidget);

        //act - quitter via le bouton Retour
        await tester.tap(find.text('Retour'));
        await tester.pumpAndSettle();

        //assert - retour sur la page de réglages Accords, récap disparu
        expect(find.text('Lancer'), findsOneWidget);
        expect(find.text('Lecture · accords'), findsNothing);
      },
    );

    testWidgets(
      'relance le même exercice via Refaire, avec les mêmes paramètres (clé de Sol, 10 accords)',
      (tester) async {
        //arrange
        await _startChordFlashcardExerciseWithTenChords(tester);
        await _answerTenChordsAlternately(tester);

        //assert - récap affiché avant de relancer
        expect(find.text('50'), findsOneWidget);

        //act - relancer via Refaire
        await tester.tap(find.text('Refaire'));
        await tester.pumpAndSettle();

        //assert - nouvel exercice avec les mêmes paramètres : repart à l'accord 1 sur un total de 10
        expect(find.text('Lecture · 1 / 10'), findsOneWidget);
        expect(find.text('Lecture · accords'), findsNothing);

        //act - dérouler à nouveau les 10 accords pour confirmer que l'exercice
        // fonctionne à l'identique avec les mêmes paramètres
        await _answerTenChordsAlternately(tester);

        //assert - un nouveau récap s'affiche avec le même résultat (mêmes
        // paramètres, même schéma de réponses)
        expect(find.text('Lecture · accords'), findsOneWidget);
        expect(find.text('50'), findsOneWidget);
      },
    );
  });
}

Future<void> _startChordFlashcardExerciseWithTenChords(
  WidgetTester tester,
) async {
  if (sl.isRegistered<SharedPreferences>()) {
    await sl.reset();
  }
  SharedPreferences.setMockInitialValues({});
  await initDependencies();
  await tester.pumpWidget(const ProviderScope(child: KeyStarterApp()));
  await tester.pumpAndSettle();

  //act - Accueil -> Accords
  await tester.tap(
    find.descendant(
      of: find.ancestor(
        of: find.text('Accords'),
        matching: find.byType(EntryCard),
      ),
      matching: find.byType(PrimaryIconButton),
    ),
  );
  await tester.pumpAndSettle();

  //act - Accords -> Flashcard
  await tester.tap(
    find.descendant(
      of: find.ancestor(
        of: find.text('Flashcard'),
        matching: find.byType(EntryCard),
      ),
      matching: find.byType(PrimaryIconButton),
    ),
  );
  await tester.pumpAndSettle();

  //assert - la clé de Sol est sélectionnée par défaut
  expect(find.text('Sol'), findsOneWidget);

  //act - réduire le nombre d'accords de 15 (défaut) à 10
  await tester.tap(
    find.descendant(
      of: find.byType(ChordFlashcardNoteCountRow),
      matching: find.byIcon(Icons.remove_rounded),
    ),
  );
  await tester.pumpAndSettle();

  //assert
  expect(
    find.descendant(
      of: find.byType(ChordFlashcardNoteCountRow),
      matching: find.text('10'),
    ),
    findsOneWidget,
  );

  //act - lancer l'exercice
  await tester.tap(find.text('Lancer'));
  await tester.pumpAndSettle();
}

Future<void> _answerTenChordsAlternately(WidgetTester tester) async {
  //act - répondre aux 10 accords en alternant bons (Juste) et mauvais (Faux) ;
  // 400ms couvre la fenêtre de détection MIDI (100ms) + le délai d'avancement
  // (200ms) + une marge.
  for (var chordIndex = 0; chordIndex < 10; chordIndex++) {
    final answerCorrectly = chordIndex.isEven;
    await tester.tap(find.text(answerCorrectly ? 'Juste' : 'Faux'));
    await tester.pump(const Duration(milliseconds: 400));
  }
  await tester.pumpAndSettle();
}
