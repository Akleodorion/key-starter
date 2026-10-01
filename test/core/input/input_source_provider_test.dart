import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:key_starter/core/input/input_source_kind.dart';
import 'package:key_starter/core/input/input_source_provider.dart';
import 'package:key_starter/core/input/microphone_permission.dart';
import 'package:key_starter/core/providers/midi_connection_provider.dart';

class FakeMicrophonePermission implements MicrophonePermission {
  bool granted;
  int requestCount = 0;

  FakeMicrophonePermission({required this.granted});

  @override
  Future<bool> isGranted() async => granted;

  @override
  Future<bool> requestOnFirstLaunch() async {
    requestCount++;
    return granted;
  }

  @override
  Future<void> openSettings() async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<InputSourceKind> activeKindWith({
    required String? midiDeviceName,
    required bool microphoneGranted,
  }) async {
    final container = ProviderContainer(
      overrides: [
        midiConnectionProvider.overrideWith(
          (ref) => Stream.value(midiDeviceName),
        ),
        microphonePermissionAccessProvider.overrideWithValue(
          FakeMicrophonePermission(granted: microphoneGranted),
        ),
      ],
    );
    addTearDown(container.dispose);
    container.listen(activeInputSourceKindProvider, (_, _) {});
    await pumpEventQueue();
    return container.read(activeInputSourceKindProvider);
  }

  group('activeInputSourceKindProvider', () {
    test('choisit le MIDI dès qu\'un clavier est connecté', () async {
      //arrange

      //act
      final kind = await activeKindWith(
        midiDeviceName: 'Synthé',
        microphoneGranted: true,
      );

      //assert
      expect(kind, InputSourceKind.midi);
    });

    test('se replie sur le micro sans clavier connecté', () async {
      //arrange

      //act
      final kind = await activeKindWith(
        midiDeviceName: null,
        microphoneGranted: true,
      );

      //assert
      expect(kind, InputSourceKind.microphone);
    });

    test('n\'a aucune entrée sans clavier ni micro autorisé', () async {
      //arrange

      //act
      final kind = await activeKindWith(
        midiDeviceName: null,
        microphoneGranted: false,
      );

      //assert
      expect(kind, InputSourceKind.none);
    });
  });

  group('MicrophonePermissionNotifier', () {
    test('requestOnFirstLaunch met à jour l\'autorisation obtenue', () async {
      //arrange
      final permission = FakeMicrophonePermission(granted: false);
      final container = ProviderContainer(
        overrides: [
          microphonePermissionAccessProvider.overrideWithValue(permission),
        ],
      );
      addTearDown(container.dispose);
      container.listen(microphonePermissionProvider, (_, _) {});
      await pumpEventQueue();
      permission.granted = true;

      //act
      await container
          .read(microphonePermissionProvider.notifier)
          .requestOnFirstLaunch();

      //assert
      expect(container.read(microphonePermissionProvider), isTrue);
      expect(permission.requestCount, 1);
    });
  });
}
