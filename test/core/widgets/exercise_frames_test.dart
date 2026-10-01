import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:key_starter/core/input/input_source_kind.dart';
import 'package:key_starter/core/input/input_source_provider.dart';
import 'package:key_starter/core/theme/app_theme.dart';
import 'package:key_starter/core/widgets/microphone_exercise_frame.dart';
import 'package:key_starter/core/widgets/midi_disconnected_overlay.dart';
import 'package:key_starter/core/widgets/midi_only_exercise_frame.dart';
import 'package:key_starter/core/widgets/no_input_source_banner.dart';

/// Source simulée : le test la fait basculer avec [ActiveKindForTest.set].
class ActiveKindForTest extends Notifier<InputSourceKind> {
  final InputSourceKind initialKind;

  ActiveKindForTest(this.initialKind);

  @override
  InputSourceKind build() => initialKind;

  void set(InputSourceKind kind) => state = kind;
}

void main() {
  late NotifierProvider<ActiveKindForTest, InputSourceKind> kindProvider;

  Future<ProviderContainer> pumpFrame(
    WidgetTester tester, {
    required InputSourceKind initialKind,
    required Widget Function(Widget child) frame,
  }) async {
    kindProvider = NotifierProvider<ActiveKindForTest, InputSourceKind>(
      () => ActiveKindForTest(initialKind),
    );
    final container = ProviderContainer(
      overrides: [
        activeInputSourceKindProvider.overrideWith(
          (ref) => ref.watch(kindProvider),
        ),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.light(),
          home: frame(const Scaffold(body: Text('exercice'))),
        ),
      ),
    );
    await tester.pump();
    return container;
  }

  group('MicrophoneExerciseFrame', () {
    Widget microphoneFrame(Widget child) =>
        MicrophoneExerciseFrame(child: child);

    testWidgets('affiche le bandeau quand aucune source n\'est disponible', (
      tester,
    ) async {
      //arrange

      //act
      await pumpFrame(
        tester,
        initialKind: InputSourceKind.none,
        frame: microphoneFrame,
      );

      //assert
      expect(find.text(NoInputSourceBanner.message), findsOneWidget);
    });

    testWidgets('n\'affiche pas le bandeau avec le micro', (tester) async {
      //arrange

      //act
      await pumpFrame(
        tester,
        initialKind: InputSourceKind.microphone,
        frame: microphoneFrame,
      );

      //assert
      expect(find.text(NoInputSourceBanner.message), findsNothing);
    });

    testWidgets('prévient du passage au micro quand le clavier est débranché', (
      tester,
    ) async {
      //arrange
      final container = await pumpFrame(
        tester,
        initialKind: InputSourceKind.midi,
        frame: microphoneFrame,
      );

      //act
      container.read(kindProvider.notifier).set(InputSourceKind.microphone);
      await tester.pump();

      //assert
      expect(
        find.text(MicrophoneExerciseFrame.switchedToMicrophoneMessage),
        findsOneWidget,
      );

      //cleanup : laisse le toast terminer son cycle
      await tester.pump(const Duration(milliseconds: 2000));
    });
  });

  group('MidiOnlyExerciseFrame', () {
    testWidgets('met en pause sous un voile quand le clavier est débranché', (
      tester,
    ) async {
      //arrange
      var pauseCount = 0;
      final container = await pumpFrame(
        tester,
        initialKind: InputSourceKind.midi,
        frame: (child) =>
            MidiOnlyExerciseFrame(onPause: () => pauseCount++, child: child),
      );

      //act
      container.read(kindProvider.notifier).set(InputSourceKind.microphone);
      await tester.pump();

      //assert
      expect(find.text(MidiDisconnectedOverlay.message), findsOneWidget);
      expect(pauseCount, 1);
    });

    testWidgets('reprend et retire le voile au rebranchement', (tester) async {
      //arrange
      var resumeCount = 0;
      final container = await pumpFrame(
        tester,
        initialKind: InputSourceKind.none,
        frame: (child) =>
            MidiOnlyExerciseFrame(onResume: () => resumeCount++, child: child),
      );

      //act
      container.read(kindProvider.notifier).set(InputSourceKind.midi);
      await tester.pump();

      //assert
      expect(find.text(MidiDisconnectedOverlay.message), findsNothing);
      expect(resumeCount, 1);
    });
  });
}
