import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:key_starter/core/widgets/entry_card.dart';
import 'package:key_starter/core/widgets/primary_icon_button.dart';
import 'package:key_starter/features/chord_recognition/presentation/widgets/simple_chord_count_row.dart';
import 'package:key_starter/injection_container.dart';
import 'package:key_starter/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Exercice Accords simples - 10 accords', () {
    testWidgets(
      'joue 10 accords (bonnes et mauvaises réponses), affiche le récap, puis quitte',
      (tester) async {
        //arrange
        await _startSimpleChordExerciseWithTenChords(tester);
        await _answerTenChordsAlternately(tester);

        //assert - le récap s'affiche avec 50% de bonnes réponses (5 correctes / 10)
        expect(find.text('Lecture · accords simples'), findsOneWidget);
        expect(find.text('RÉSULTAT'), findsOneWidget);
        expect(find.text('50'), findsOneWidget);

        //act - quitter via le bouton Retour
        await tester.tap(find.text('Retour'));
        await tester.pumpAndSettle();

        //assert - retour sur la page de réglages Accords simples, récap disparu
        expect(find.text('Lancer'), findsOneWidget);
        expect(find.text('Lecture · accords simples'), findsNothing);
      },
    );

    testWidgets(
      'relance le même exercice via Refaire, avec le même nombre d\'accords',
      (tester) async {
        //arrange
        await _startSimpleChordExerciseWithTenChords(tester);
        await _answerTenChordsAlternately(tester);

        //act - relancer via Refaire
        await tester.tap(find.text('Refaire'));
        await tester.pumpAndSettle();

        //assert - nouvel exercice : repart à l'accord 1 sur un total de 10
        expect(find.text('Lecture · 1 / 10'), findsOneWidget);
        expect(find.text('Lecture · accords simples'), findsNothing);
      },
    );
  });
}

Future<void> _startSimpleChordExerciseWithTenChords(WidgetTester tester) async {
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

  //act - Accords -> Accords simples
  await tester.tap(
    find.descendant(
      of: find.ancestor(
        of: find.text('Accords simples'),
        matching: find.byType(EntryCard),
      ),
      matching: find.byType(PrimaryIconButton),
    ),
  );
  await tester.pumpAndSettle();

  //act - réduire le nombre d'accords de 15 (défaut) à 10
  await tester.tap(
    find.descendant(
      of: find.byType(SimpleChordCountRow),
      matching: find.byIcon(Icons.remove_rounded),
    ),
  );
  await tester.pumpAndSettle();

  //assert
  expect(
    find.descendant(
      of: find.byType(SimpleChordCountRow),
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
  // 800ms couvre la fenêtre de détection (100ms) + le retour visuel (500ms) + une marge.
  for (var chordIndex = 0; chordIndex < 10; chordIndex++) {
    final answerCorrectly = chordIndex.isEven;
    await tester.tap(find.text(answerCorrectly ? 'Juste' : 'Faux'));
    await tester.pump(const Duration(milliseconds: 800));
  }
  await tester.pumpAndSettle();
}
