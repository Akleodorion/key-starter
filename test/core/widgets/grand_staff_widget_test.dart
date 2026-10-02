import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:key_starter/core/enums/clef_mode.dart';
import 'package:key_starter/core/enums/note_state.dart';
import 'package:key_starter/core/models/two_staff_event.dart';
import 'package:key_starter/core/theme/app_theme.dart';
import 'package:key_starter/core/widgets/grand_staff_widget.dart';

class _FixedGrandStaffWidget extends GrandStaffWidget {
  const _FixedGrandStaffWidget();

  @override
  TwoStaffEvent event(WidgetRef ref) =>
      const TwoStaffEvent(trebleSteps: [0], bassSteps: [-7, -5, -3]);

  @override
  NoteState noteState(WidgetRef ref, ClefMode clef) =>
      clef == ClefMode.treble ? NoteState.wrong : NoteState.correct;
}

void main() {
  group('GrandStaffWidget', () {
    testWidgets('dessine l\'événement fourni avec l\'état de chaque portée', (
      tester,
    ) async {
      //arrange
      //act
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.light(),
            home: const Scaffold(body: _FixedGrandStaffWidget()),
          ),
        ),
      );

      //assert
      final sut = tester
          .widgetList<CustomPaint>(find.byType(CustomPaint))
          .map((customPaint) => customPaint.painter)
          .whereType<GrandStaffPainter>()
          .single;
      expect(sut.trebleSteps, [0]);
      expect(sut.bassSteps, [-7, -5, -3]);
      expect(sut.trebleState, NoteState.wrong);
      expect(sut.bassState, NoteState.correct);
    });
  });
}
