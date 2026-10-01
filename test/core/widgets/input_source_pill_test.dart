import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:key_starter/core/input/input_source_kind.dart';
import 'package:key_starter/core/input/input_source_provider.dart';
import 'package:key_starter/core/providers/midi_connection_provider.dart';
import 'package:key_starter/core/theme/app_theme.dart';
import 'package:key_starter/core/widgets/input_source_pill.dart';

void main() {
  Future<void> pumpPill(
    WidgetTester tester, {
    required InputSourceKind kind,
    String? midiDeviceName,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          activeInputSourceKindProvider.overrideWithValue(kind),
          midiConnectionProvider.overrideWith(
            (ref) => Stream.value(midiDeviceName),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const Scaffold(body: InputSourcePill()),
        ),
      ),
    );
    await tester.pump();
  }

  group('InputSourcePill', () {
    testWidgets('affiche le clavier MIDI connecté', (tester) async {
      //arrange

      //act
      await pumpPill(
        tester,
        kind: InputSourceKind.midi,
        midiDeviceName: 'Synthé',
      );

      //assert
      expect(find.text('MIDI · Synthé'), findsOneWidget);
    });

    testWidgets('tronque un nom d\'appareil trop long', (tester) async {
      //arrange

      //act
      await pumpPill(
        tester,
        kind: InputSourceKind.midi,
        midiDeviceName: 'Digital Piano Bluetooth',
      );

      //assert
      expect(find.text('MIDI · Digital Piano B…'), findsOneWidget);
    });

    testWidgets('affiche le micro en repli', (tester) async {
      //arrange

      //act
      await pumpPill(tester, kind: InputSourceKind.microphone);

      //assert
      expect(find.text('Micro'), findsOneWidget);
    });

    testWidgets('signale l\'absence d\'entrée', (tester) async {
      //arrange

      //act
      await pumpPill(tester, kind: InputSourceKind.none);

      //assert
      expect(find.text('Aucune entrée'), findsOneWidget);
    });
  });
}
