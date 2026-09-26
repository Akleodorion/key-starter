import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:key_starter/core/theme/app_theme.dart';
import 'package:key_starter/features/note_recognition/presentation/providers/simple_note_black_keys_notifier.dart';
import 'package:key_starter/features/note_recognition/presentation/widgets/simple_note_black_keys_toggle_row.dart';

void main() {
  late ProviderContainer container;

  setUp(() => container = ProviderContainer());

  tearDown(() => container.dispose());

  Future<void> pumpToggleRow(WidgetTester tester) => tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: AppTheme.light(),
        home: const Scaffold(body: SimpleNoteBlackKeysToggleRow()),
      ),
    ),
  );

  group('SimpleNoteBlackKeysToggleRow', () {
    testWidgets('affiche le libellé et la mention des dièses', (tester) async {
      //act
      await pumpToggleRow(tester);

      //assert
      expect(find.text('Touches noires'), findsOneWidget);
      expect(find.text('inclut les dièses (Do♯, Fa♯…)'), findsOneWidget);
    });

    testWidgets('active les touches noires quand on bascule le switch', (
      tester,
    ) async {
      //arrange
      await pumpToggleRow(tester);

      //act
      await tester.tap(find.byType(Switch));
      await tester.pump();

      //assert
      expect(container.read(simpleNoteBlackKeysProvider), isTrue);
    });
  });
}
