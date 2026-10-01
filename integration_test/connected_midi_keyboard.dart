import 'package:key_starter/core/input/input_source_kind.dart';
import 'package:key_starter/core/input/input_source_provider.dart';
import 'package:key_starter/core/input/microphone_permission.dart';

/// Les exercices sont pilotés par les boutons « Juste » / « Faux » : on simule
/// un clavier MIDI connecté, sans jamais demander le micro.
final connectedMidiKeyboardOverrides = [
  activeInputSourceKindProvider.overrideWithValue(InputSourceKind.midi),
  microphonePermissionAccessProvider.overrideWithValue(
    _NeverAskedMicrophonePermission(),
  ),
];

class _NeverAskedMicrophonePermission implements MicrophonePermission {
  @override
  Future<bool> isGranted() async => false;

  @override
  Future<bool> requestOnFirstLaunch() async => false;

  @override
  Future<void> openSettings() async {}
}
