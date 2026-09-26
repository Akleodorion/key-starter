import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:key_starter/core/theme/app_theme.dart';
import 'package:key_starter/core/widgets/tempo_count_in_label.dart';

void main() {
  Future<void> pumpCountInLabel(WidgetTester tester, {required int? beat}) =>
      tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          home: Scaffold(body: TempoCountInLabel(beat: beat)),
        ),
      );

  group('TempoCountInLabel', () {
    testWidgets('affiche le temps restant du décompte', (tester) async {
      //arrange
      //act
      await pumpCountInLabel(tester, beat: 3);

      //assert
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('ne montre rien une fois la barre partie', (tester) async {
      //arrange
      //act
      await pumpCountInLabel(tester, beat: null);

      //assert
      expect(find.byType(Text), findsNothing);
    });
  });
}
