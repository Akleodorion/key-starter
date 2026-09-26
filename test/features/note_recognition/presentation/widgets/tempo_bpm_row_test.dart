import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:key_starter/core/theme/app_theme.dart';
import 'package:key_starter/features/note_recognition/presentation/widgets/tempo_bpm_row.dart';

void main() {
  Future<void> pumpBpmRow(WidgetTester tester) => tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        theme: AppTheme.light(),
        home: const Scaffold(body: TempoBpmRow()),
      ),
    ),
  );

  group('TempoBpmRow', () {
    testWidgets('affiche le tempo par défaut', (tester) async {
      //arrange
      //act
      await pumpBpmRow(tester);

      //assert
      expect(find.text('Tempo'), findsOneWidget);
      expect(find.text('60'), findsOneWidget);
    });

    testWidgets('augmente le tempo de 5 BPM', (tester) async {
      //arrange
      await pumpBpmRow(tester);

      //act
      await tester.tap(find.byIcon(Icons.add_rounded));
      await tester.pump();

      //assert
      expect(find.text('65'), findsOneWidget);
    });

    testWidgets('diminue le tempo de 5 BPM', (tester) async {
      //arrange
      await pumpBpmRow(tester);

      //act
      await tester.tap(find.byIcon(Icons.remove_rounded));
      await tester.pump();

      //assert
      expect(find.text('55'), findsOneWidget);
    });
  });
}
