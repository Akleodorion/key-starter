import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:key_starter/core/input/input_source_provider.dart';
import 'package:key_starter/core/widgets/midi_only_entry_card.dart';
import 'package:key_starter/features/chord_chart/presentation/models/chord_chart_cell_status.dart';
import 'package:key_starter/features/chord_chart/presentation/widgets/chord_chart_cell_view.dart';
import 'package:key_starter/injection_container.dart';
import 'package:key_starter/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../test/core/input/fake_input_source.dart';
import 'connected_midi_keyboard.dart';

const c3 = 48;
const e3 = 52;
const g3 = 55;
const d4 = 62;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Grilles d\'accords - tempo Libre', () {
    testWidgets(
      'ouvre la grille de démonstration depuis l\'accueil et la joue au clavier',
      (tester) async {
        //arrange
        final keyboard = FakeInputSource();
        if (sl.isRegistered<SharedPreferences>()) {
          await sl.reset();
        }
        SharedPreferences.setMockInitialValues({});
        await initDependencies();
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              ...connectedMidiKeyboardOverrides,
              inputSourceProvider.overrideWithValue(keyboard),
            ],
            child: const KeyStarterApp(),
          ),
        );
        await tester.pumpAndSettle();

        //act - Accueil -> Grilles d'accords -> grille de démonstration
        await _tapEntryCard(tester, 'Grilles d\'accords');
        await _tapEntryCard(tester, 'Do Sol Lam Fa');

        //assert - la grille lue depuis les assets s'affiche, en notation Do
        expect(find.text('Lam'), findsWidgets);
        expect(_statusOfCell(tester, 0), ChordChartCellStatus.current);

        //act - Do majeur juste (renversé, Do à la basse), puis une fausse note
        await _play(tester, keyboard, [c3, e3 + 12, g3]);
        await _play(tester, keyboard, [d4]);

        //assert
        expect(_statusOfCell(tester, 0), ChordChartCellStatus.correct);
        expect(_statusOfCell(tester, 1), ChordChartCellStatus.wrong);
        expect(_statusOfCell(tester, 2), ChordChartCellStatus.current);
      },
    );
  });
}

Future<void> _tapEntryCard(WidgetTester tester, String title) async {
  final card = find.descendant(
    of: find.ancestor(
      of: find.text(title),
      matching: find.byType(MidiOnlyEntryCard),
    ),
    matching: find.byType(GestureDetector),
  );
  await tester.ensureVisible(card);
  await tester.tap(card);
  await tester.pumpAndSettle();
}

Future<void> _play(
  WidgetTester tester,
  FakeInputSource keyboard,
  List<int> midiNumbers,
) async {
  midiNumbers.forEach(keyboard.play);
  midiNumbers.forEach(keyboard.release);
  // Sur l'appareil, le délai avant la case suivante court en temps réel.
  await tester.pump();
  await Future<void>.delayed(const Duration(milliseconds: 300));
  await tester.pumpAndSettle();
}

ChordChartCellStatus _statusOfCell(WidgetTester tester, int cellIndex) => tester
    .widgetList<ChordChartCellView>(find.byType(ChordChartCellView))
    .firstWhere((cellView) => cellView.cellIndex == cellIndex)
    .status;
