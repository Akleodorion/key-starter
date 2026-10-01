import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:key_starter/core/widgets/entry_card.dart';
import 'package:key_starter/core/widgets/primary_icon_button.dart';
import 'package:key_starter/features/chord_recognition/presentation/providers/chord_tempo_exercise_notifier.dart';
import 'package:key_starter/features/chord_recognition/presentation/widgets/chord_tempo_bpm_row.dart';
import 'package:key_starter/features/chord_recognition/presentation/widgets/chord_tempo_chord_count_row.dart';
import 'package:key_starter/features/chord_recognition/presentation/widgets/chord_tempo_running_view.dart';
import 'package:key_starter/injection_container.dart';
import 'package:key_starter/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'connected_midi_keyboard.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Exercice Tempo Accords - clé de Sol, 10 accords', () {
    testWidgets(
      'sans rien jouer à 120 BPM, tous les accords sont ratés et le récap n\'a pas d\'écart',
      (tester) async {
        //arrange
        await _openChordTempoSettingsWithTenChords(tester);

        //act - passer de 60 à 120 BPM
        for (var step = 0; step < 12; step++) {
          await tester.tap(
            find.descendant(
              of: find.byType(ChordTempoBpmRow),
              matching: find.byIcon(Icons.add_rounded),
            ),
          );
          await tester.pump();
        }

        //assert
        expect(
          find.descendant(
            of: find.byType(ChordTempoBpmRow),
            matching: find.text('120'),
          ),
          findsOneWidget,
        );

        //act - lancer, ne rien jouer jusqu'à la fin (2 s de décompte + 5 s)
        await tester.tap(find.text('Lancer'));
        await _waitForRecap(tester);

        //assert - récap à 0 %, sans écart au temps
        expect(find.text('Accords · tempo'), findsOneWidget);
        expect(find.text('ÉCART MOYEN'), findsOneWidget);
        expect(find.text('—'), findsOneWidget);
      },
    );

    testWidgets(
      'en jouant « Juste » sur chaque temps à 60 BPM, le récap affiche 100 %',
      (tester) async {
        //arrange
        await _openChordTempoSettingsWithTenChords(tester);
        await tester.tap(find.text('Lancer'));
        await tester.pump();
        await tester.pump();

        //act - cliquer « Juste » au moment où la barre croise chaque accord
        final runningView = find.byType(ChordTempoRunningView);
        final config = tester.widget<ChordTempoRunningView>(runningView).config;
        final notifier = ProviderScope.containerOf(
          tester.element(runningView),
        ).read(chordTempoExerciseProvider(config).notifier);
        for (var chordIndex = 0; chordIndex < 10; chordIndex++) {
          final chordTime = notifier.timeline.noteTime(chordIndex);
          while (notifier.elapsed < chordTime) {
            await tester.pump(const Duration(milliseconds: 10));
          }
          await tester.tap(find.text('Juste'));
          await tester.pump();
        }
        await _waitForRecap(tester);

        //assert - récap à 100 %, avec une meilleure série de 10
        expect(find.text('Accords · tempo'), findsOneWidget);
        expect(find.text('100'), findsOneWidget);
        expect(find.text('10'), findsOneWidget);
      },
    );
  });
}

Future<void> _openChordTempoSettingsWithTenChords(WidgetTester tester) async {
  if (sl.isRegistered<SharedPreferences>()) {
    await sl.reset();
  }
  SharedPreferences.setMockInitialValues({});
  await initDependencies();
  await tester.pumpWidget(
    ProviderScope(
      overrides: connectedMidiKeyboardOverrides,
      child: const KeyStarterApp(),
    ),
  );
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

  //act - Accords -> Tempo
  final tempoButton = find.descendant(
    of: find.ancestor(of: find.text('Tempo'), matching: find.byType(EntryCard)),
    matching: find.byType(PrimaryIconButton),
  );
  await tester.ensureVisible(tempoButton);
  await tester.pumpAndSettle();
  await tester.tap(tempoButton);
  await tester.pumpAndSettle();

  //act - réduire le nombre d'accords de 20 (défaut) à 10
  for (var step = 0; step < 2; step++) {
    await tester.tap(
      find.descendant(
        of: find.byType(ChordTempoChordCountRow),
        matching: find.byIcon(Icons.remove_rounded),
      ),
    );
    await tester.pump();
  }

  //assert
  expect(
    find.descendant(
      of: find.byType(ChordTempoChordCountRow),
      matching: find.text('10'),
    ),
    findsOneWidget,
  );
}

/// Laisse la barre avancer (la vue se redessine sans cesse, donc pas de
/// pumpAndSettle) jusqu'à l'affichage du récap.
Future<void> _waitForRecap(WidgetTester tester) async {
  const timeout = Duration(seconds: 20);
  final stopwatch = Stopwatch()..start();
  while (find.text('RÉSULTAT').evaluate().isEmpty &&
      stopwatch.elapsed < timeout) {
    await tester.pump(const Duration(milliseconds: 100));
  }
  await tester.pumpAndSettle();
}
