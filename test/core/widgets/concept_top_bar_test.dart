import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:key_starter/core/input/input_source_kind.dart';
import 'package:key_starter/core/input/input_source_provider.dart';
import 'package:key_starter/core/theme/app_theme.dart';
import 'package:key_starter/core/widgets/concept_top_bar.dart';

void main() {
  group('ConceptTopBar', () {
    testWidgets(
      'tient sans dépassement sur un Galaxy Note 10 en portrait avec « Aucune entrée », police agrandie à 130 %',
      (tester) async {
        //arrange
        tester.view.devicePixelRatio = 2;
        tester.view.physicalSize = const Size(412, 869) * 2;
        addTearDown(tester.view.reset);

        //act
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              activeInputSourceKindProvider.overrideWithValue(
                InputSourceKind.none,
              ),
            ],
            child: MaterialApp(
              theme: AppTheme.light(),
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(textScaler: const TextScaler.linear(1.3)),
                child: child!,
              ),
              home: const Scaffold(
                body: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: ConceptTopBar(title: 'Accords'),
                ),
              ),
            ),
          ),
        );

        //assert
        expect(tester.takeException(), isNull);
        expect(find.text('Accords'), findsOneWidget);
        expect(find.text('Aucune entrée'), findsOneWidget);
      },
    );
  });
}
