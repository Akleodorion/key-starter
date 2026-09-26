import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:key_starter/core/widgets/entry_card.dart';
import 'package:key_starter/core/widgets/primary_icon_button.dart';
import 'package:key_starter/features/note_recognition/presentation/widgets/simple_note_black_keys_toggle_row.dart';
import 'package:key_starter/features/note_recognition/presentation/widgets/simple_note_note_count_row.dart';
import 'package:key_starter/injection_container.dart';
import 'package:key_starter/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Exercice Notes simples - 10 notes', () {
    testWidgets(
      'joue 10 notes (bonnes et mauvaises réponses), affiche le récap, puis quitte',
      (tester) async {
        //arrange
        await _startSimpleNoteExerciseWithTenNotes(tester);
        await _answerTenNotesAlternately(tester);

        //assert - le récap s'affiche avec 50% de bonnes réponses (5 correctes / 10)
        expect(find.text('Lecture · notes simples'), findsOneWidget);
        expect(find.text('RÉSULTAT'), findsOneWidget);
        expect(find.text('50'), findsOneWidget);

        //act - quitter via le bouton Retour
        await tester.tap(find.text('Retour'));
        await tester.pumpAndSettle();

        //assert - retour sur la page de réglages Notes simples, récap disparu
        expect(find.text('Lancer'), findsOneWidget);
        expect(find.text('Lecture · notes simples'), findsNothing);
      },
    );

    testWidgets(
      'relance le même exercice via Refaire, avec le même nombre de notes',
      (tester) async {
        //arrange
        await _startSimpleNoteExerciseWithTenNotes(tester);
        await _answerTenNotesAlternately(tester);

        //act - relancer via Refaire
        await tester.tap(find.text('Refaire'));
        await tester.pumpAndSettle();

        //assert - nouvel exercice : repart à la note 1 sur un total de 10
        expect(find.text('Lecture · 1 / 10'), findsOneWidget);
        expect(find.text('Lecture · notes simples'), findsNothing);
      },
    );

    testWidgets(
      'touches noires activées : 10 bonnes réponses donnent un récap à 100%',
      (tester) async {
        //arrange
        await _startSimpleNoteExerciseWithTenNotes(
          tester,
          includeBlackKeys: true,
        );

        //act - répondre juste aux 10 notes, touches noires comprises
        for (var noteIndex = 0; noteIndex < 10; noteIndex++) {
          await tester.tap(find.text('Juste'));
          await tester.pump(const Duration(milliseconds: 700));
        }
        await tester.pumpAndSettle();

        //assert
        expect(find.text('Lecture · notes simples'), findsOneWidget);
        expect(find.text('100'), findsOneWidget);
      },
    );
  });
}

Future<void> _startSimpleNoteExerciseWithTenNotes(
  WidgetTester tester, {
  bool includeBlackKeys = false,
}) async {
  if (sl.isRegistered<SharedPreferences>()) {
    await sl.reset();
  }
  SharedPreferences.setMockInitialValues({});
  await initDependencies();
  await tester.pumpWidget(const ProviderScope(child: KeyStarterApp()));
  await tester.pumpAndSettle();

  //act - Accueil -> Notes
  await tester.tap(
    find.descendant(
      of: find.ancestor(
        of: find.text('Notes'),
        matching: find.byType(EntryCard),
      ),
      matching: find.byType(PrimaryIconButton),
    ),
  );
  await tester.pumpAndSettle();

  //act - Notes -> Notes simples
  await tester.tap(
    find.descendant(
      of: find.ancestor(
        of: find.text('Notes simples'),
        matching: find.byType(EntryCard),
      ),
      matching: find.byType(PrimaryIconButton),
    ),
  );
  await tester.pumpAndSettle();

  //act - réduire le nombre de notes de 15 (défaut) à 10
  await tester.tap(
    find.descendant(
      of: find.byType(SimpleNoteNoteCountRow),
      matching: find.byIcon(Icons.remove_rounded),
    ),
  );
  await tester.pumpAndSettle();

  //assert
  expect(
    find.descendant(
      of: find.byType(SimpleNoteNoteCountRow),
      matching: find.text('10'),
    ),
    findsOneWidget,
  );

  if (includeBlackKeys) {
    //act - activer les touches noires
    await tester.tap(
      find.descendant(
        of: find.byType(SimpleNoteBlackKeysToggleRow),
        matching: find.byType(Switch),
      ),
    );
    await tester.pumpAndSettle();
  }

  //act - lancer l'exercice
  await tester.tap(find.text('Lancer'));
  await tester.pumpAndSettle();
}

Future<void> _answerTenNotesAlternately(WidgetTester tester) async {
  //act - répondre aux 10 notes en alternant bonnes (Juste) et mauvaises (Faux) ;
  // 700ms couvre le retour visuel (500ms) + une marge.
  for (var noteIndex = 0; noteIndex < 10; noteIndex++) {
    final answerCorrectly = noteIndex.isEven;
    await tester.tap(find.text(answerCorrectly ? 'Juste' : 'Faux'));
    await tester.pump(const Duration(milliseconds: 700));
  }
  await tester.pumpAndSettle();
}
