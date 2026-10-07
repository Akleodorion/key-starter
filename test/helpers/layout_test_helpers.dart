import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:key_starter/core/theme/app_theme.dart';

/// Galaxy Note 10 : environ 412 × 869 points.
const galaxyNote10Portrait = Size(412, 869);
const galaxyNote10Landscape = Size(869, 412);

/// Police système agrandie avec laquelle Christian utilise l'app.
const enlargedTextScale = 1.3;

/// Les écrans sur lesquels toute mise en page doit tenir.
const galaxyNote10Screens = [
  ('portrait', galaxyNote10Portrait),
  ('paysage', galaxyNote10Landscape),
];

/// Affiche [home] dans l'app (thème clair) sur un écran de [screenSize] à la
/// police [textScale]. Les providers viennent de [container] s'il est donné,
/// sinon d'un nouveau scope avec [overrides].
Future<void> pumpOnScreen(
  WidgetTester tester,
  Widget home, {
  Size screenSize = galaxyNote10Portrait,
  double textScale = enlargedTextScale,
  List<Override> overrides = const [],
  ProviderContainer? container,
}) async {
  tester.view.devicePixelRatio = 2;
  tester.view.physicalSize = screenSize * 2;
  addTearDown(tester.view.reset);

  final app = MaterialApp(
    theme: AppTheme.light(),
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(textScaler: TextScaler.linear(textScale)),
      child: child!,
    ),
    home: home,
  );
  await tester.pumpWidget(
    container != null
        ? UncontrolledProviderScope(container: container, child: app)
        : ProviderScope(overrides: overrides, child: app),
  );
}

/// Déclare un test par écran de [screens] : [buildHome] y est affiché à la
/// police agrandie, [arrange] l'amène dans l'état voulu (attente du
/// chargement, état en pause…), puis aucun débordement ne doit avoir eu lieu.
///
/// ```dart
/// testNoOverflow('affiche les réglages', () => const FlashcardPage());
/// ```
void testNoOverflow(
  String description,
  Widget Function() buildHome, {
  List<Override> Function()? overrides,
  Future<void> Function(WidgetTester tester)? arrange,
  List<(String, Size)> screens = galaxyNote10Screens,
}) {
  for (final (orientation, screenSize) in screens) {
    testWidgets(
      '$description, sans dépassement sur un Galaxy Note 10 en $orientation, '
      'police agrandie à 130 %',
      (tester) async {
        //arrange
        await pumpOnScreen(
          tester,
          buildHome(),
          screenSize: screenSize,
          overrides: overrides?.call() ?? const [],
        );

        //act
        await (arrange?.call(tester) ?? tester.pump());

        //assert
        expect(tester.takeException(), isNull);
      },
    );
  }
}
